require "GameState"
require "PlayerData"
require "PositionData"
require "Utilities\\QuadTree"
require "Utilities\\GuardDataReader"
require "Utilities\\ObjectDataReader"

local screen = {}

screen.width = client.screenwidth()
screen.height = client.screenheight()

local map = {}

map.center_x = (screen.width / 2)
map.center_y = (screen.height / 2)
map.width = screen.width
map.height = screen.height - 40 -- IMPROVE?
map.min_x = map.center_x - (map.width / 2)
map.min_y = map.center_y - (map.height / 2)
map.max_x = (map.min_x + map.width)
map.max_y = (map.min_y + map.height)
map.units_per_pixel = 20.0

local camera = {}

camera.modes = {"Manual", "Follow"}
camera.mode = 2
camera.position = {["x"] = 0.0, ["z"] = 0.0}
camera.floor = 0
camera.zoom = 4.0
camera.zoom_min = 1.0
camera.zoom_max = 10.0
camera.zoom_step = 0.5
camera.switch_mode_key = "M"
camera.switch_floor_key = "F"
camera.zoom_in_key = "NumberPadPlus"
camera.zoom_out_key = "NumberPadMinus"

local target = {}

target.id = 0xFF
target.scale = 3.0
target.pick_radius = 5.0

local view_cone = {}

view_cone.scale = 4.0

function make_color(_r, _g, _b, _a)
	local a_hex = bit.band(math.floor((_a * 255) + 0.5), 0xFF)
	local r_hex = bit.band(math.floor((_r * 255) + 0.5), 0xFF)
	local g_hex = bit.band(math.floor((_g * 255) + 0.5), 0xFF)
	local b_hex = bit.band(math.floor((_b * 255) + 0.5), 0xFF)
	
	a_hex = bit.lshift(a_hex, (8 * 3))
	r_hex = bit.lshift(r_hex, (8 * 2))
	g_hex = bit.lshift(g_hex, (8 * 1))
	b_hex = bit.lshift(b_hex, (8 * 0))
	
	return (a_hex + r_hex + g_hex + b_hex)
end

function make_rgb(_r, _g, _b)
	return make_color(_r, _g, _b, 0.0)
end

function make_alpha(_a)
	return make_color(0.0, 0.0, 0.0, _a)
end

local colors = {}

colors.default_alpha = make_alpha(0.6)
colors.inactive_alpha = make_alpha(0.2)

colors.guard_default = make_rgb(0.0, 1.0, 0.0)
colors.guard_dying = make_rgb(0.5, 0.0, 0.0)
colors.guard_injured = make_rgb(1.0, 0.3, 0.3)
colors.guard_shooting = make_rgb(1.0, 1.0, 0.0)
colors.guard_throwing_grenade = make_rgb(0.0, 0.5, 0.0)
colors.guard_unloaded_alpha = make_alpha(0.3)
colors.guard_inactive_unloaded_alpha = make_alpha(0.1)

colors.map_default = make_rgb(1.0, 1.0, 1.0)
colors.map_inactive_alpha = make_alpha(0.1)

colors.object_default = make_rgb(1.0, 1.0, 1.0)
colors.object_inactive_alpha = make_alpha(0.2)

colors.view_cone_default = make_rgb(1.0, 1.0, 1.0)
colors.view_cone_default_alpha = make_alpha(0.2)
colors.view_cone_inactive_alpha = make_alpha(0.1)

colors.target_default = make_rgb(1.0, 0.0, 0.0)
colors.target_inactive_alpha = make_alpha(0.3)

colors.bond_default = make_rgb(0.0, 1.0, 1.0)

function parse_scale()	
	return io.read("*n", "*l")
end

function parse_bounds(_scale)
	local min_x, min_z, max_x, max_z = io.read("*n", "*n", "*n", "*n", "*l")
	
	min_x = (min_x / _scale)
	min_z = (min_z / _scale)
	max_x = (max_x / _scale)
	max_z = (max_z / _scale)
	
	return {["min_x"] = min_x, ["min_z"] = min_z, ["max_x"] = max_x, ["max_z"] = max_z}
end

function parse_floors(_scale)
	local floors = {}
	local start_number = io.read("*n")
	
	for height in string.gmatch(io.read("*l"), "%S+") do	
		-- Offset the floors by 1 unit to ensure characters end up above the floor
		table.insert(floors, {["height"] = ((tonumber(height) / _scale) - 1.0)})
	end
	
	table.sort(floors, (function(a, b) return (a.height < b.height) end))

	for index, floor in ipairs(floors) do
		floor["number"] = (start_number + index - 1)
	end
	
	return floors
end

function parse_edges(_scale)
	local edges = {}

	while true do
		local x1, y1, z1, x2, y2, z2 = io.read("*n", "*n", "*n", "*n", "*n", "*n", "*l")
		
		if not x1 then
			break
		end
		
		x1 = (x1 / _scale)
		y1 = (y1 / _scale)
		z1 = (z1 / _scale)
		x2 = (x2 / _scale)
		y2 = (y2 / _scale)
		z2 = (z2 / _scale)
		
		table.insert(edges, {['x1'] = x1, ['y1'] = y1, ['z1'] = z1, ['x2'] = x2, ['y2'] = y2, ['z2'] = z2})
	end
	
	return edges
end

function parse_map_file(_filename)
	local file = io.open(_filename, "r")
	
	if not file then
		error("Failed to open file: " .. _filename)
	end
	
	io.input(file)
	
	local output = {}
	
	while true do
		local group = io.read("*l")
		
		if not group then
			break
		end
			
		if (group == "[Scale]") then
			output["scale"] = parse_scale()
		elseif (group == "[Bounds]") then
			output["bounds"] = parse_bounds(output["scale"])
		elseif (group == "[Floors]") then
			output["floors"] = parse_floors(output["scale"])
		elseif (group == "[Edges]") then
			output["edges"] = parse_edges(output["scale"])
		else
			error("Invalid group type: " .. group)
		end
	end

	io.close(file)
	
	return output
end

local quadtree = nil

function init_quadtree(_bounds, _edges)
	quadtree = QuadTree.create(_bounds.min_x, _bounds.min_z, _bounds.width, _bounds.height, 1)
	
	for index, edge in ipairs(_edges) do
		quadtree:insert(edge)
	end
end

local level_data = {}

function load_level_data()
	level_data["Dam"] = parse_map_file("Maps/Dam.map")
	level_data["Facility"] = parse_map_file("Maps/Facility.map")
	level_data["Runway"] = parse_map_file("Maps/Runway.map")
	level_data["Surface 1"] = parse_map_file("Maps/Surface 1.map")
	level_data["Bunker 1"] = parse_map_file("Maps/Bunker 1.map")
	level_data["Silo"] = parse_map_file("Maps/Silo.map")
	level_data["Bunker 2"] = parse_map_file("Maps/Bunker 2.map")
end

local level = {}

function load_level(_name)
	--local scale, bounds, edges = parse_map_file("Maps/" .. _name .. ".map")
	level = level_data[_name]
	
	level.bounds.width = (level.bounds.max_x - level.bounds.min_x)
	level.bounds.height = (level.bounds.max_z - level.bounds.min_z)
	
	init_quadtree(level.bounds, level.edges)
end

function units_to_pixels(_units)
	return ((_units * camera.zoom) / map.units_per_pixel)
end

function pixels_to_units(_pixels)
	return ((_pixels * map.units_per_pixel) / camera.zoom)
end

function level_to_screen(_x, _z)
	local diff_x = units_to_pixels(_x - camera.position.x)
	local diff_z = units_to_pixels(_z - camera.position.z)
	
	local screen_x = (map.center_x + diff_x)
	local screen_y = (map.center_y + diff_z)
	
	return screen_x, screen_y
end

function screen_to_level(_x, _y)	
	local diff_x = (_x - map.center_x)
	local diff_y = (_y - map.center_y)
	
	local level_x = (pixels_to_units(diff_x) + camera.position.x)
	local level_z = (pixels_to_units(diff_y) + camera.position.z)
	
	return level_x, level_z
end

function get_floor(_height)
	for floor = 2, #level.floors, 1 do
		if (_height < (level.floors[floor].height)) then
			return level.floors[floor - 1].number
		end
	end
	
	return level.floors[#level.floors].number
end

function is_active_floor(_height)
	return (get_floor(_height) == camera.floor)
end

-- Liang-Barsky algorithm
function clip_line(_line, _bounds)
	local diff_x = (_line.x2 - _line.x1)
	local diff_y = (_line.y2 - _line.y1)
	
	local p = {-diff_x, diff_x, -diff_y, diff_y}
	local q = {(_line.x1 - _bounds.min_x), -(_line.x1 - _bounds.max_x), (_line.y1 - _bounds.min_y), -(_line.y1 - _bounds.max_y)}
	
	local t0 = 0.0
	local t1 = 1.0
	
	for i = 1, 4, 1 do
		if ((p[i] == 0.0) and (q[i] < 0.0)) then
			return nil
		end
		
		local r = (q[i] / p[i])
		
		if (p[i] < 0.0) then
			if (r > t1) then
				return nil
			elseif (r > t0) then
				t0 = r
			end
		elseif (p[i] > 0.0) then
			if (r < t0) then
				return nil
			elseif (r < t1) then
				t1 = r
			end
		end
	end
	
	local clipped_line = {}
	
	clipped_line.x1 = (_line.x1 + (t0 * diff_x))
	clipped_line.y1 = (_line.y1 + (t0 * diff_y))
	clipped_line.x2 = (_line.x1 + (t1 * diff_x))
	clipped_line.y2 = (_line.y1 + (t1 * diff_y))
	
	return clipped_line
end

function draw_line(_start, _end, _height, _color, _alpha_function)
	local line = {}

	line.x1, line.y1 = level_to_screen(_start.x, _start.z)
	line.x2, line.y2 = level_to_screen(_end.x, _end.z)
	
	if (((line.x1 < map.min_x) or (line.x1 > map.max_x)) or
		((line.y1 < map.min_y) or (line.y1 > map.max_y)) or
		((line.x2 < map.min_x) or (line.x2 > map.max_x)) or
		((line.y2 < map.min_y) or (line.y2 > map.max_y))) then
		line = clip_line(line, map)
	end
	
	if line then
		local is_active = is_active_floor(_height)
		local color = (_color + _alpha_function(is_active))
	
		gui.drawLine(line.x1, line.y1, line.x2, line.y2, color)	
	end	
end

function get_map_alpha(_is_active)
	return (_is_active and colors.default_alpha or colors.map_inactive_alpha)
end

function draw_map()	
	local bounds = {}
	local collisions = {}
	
	bounds.x1, bounds.z1 = screen_to_level(map.min_x, map.min_y)
	bounds.x2, bounds.z2 = screen_to_level(map.max_x, map.max_y)
	
	quadtree:find_collisions(bounds, collisions)
	
	for key, object in pairs(collisions) do
		local edge_start = {["x"] = object.x1, ["z"] = object.z1}
		local edge_end = {["x"] = object.x2, ["z"] = object.z2}
		
		draw_line(edge_start, edge_end, object.y1, colors.map_default, get_map_alpha)
	end
end

function get_object_alpha(_is_active)
	return (_is_active and colors.default_alpha or colors.object_inactive_alpha)
end

function draw_object(_object_data_reader)	
	local points, y_min, y_max = _object_data_reader:get_collision_data()
	
	for i = 1, #points, 1 do
		local j = ((i % #points) + 1)

		draw_line(points[i], points[j], y_min, colors.object_default, get_object_alpha)						
	end	
end

function draw_objects()
	local bounds = {}
	
	bounds.min_x, bounds.min_z = screen_to_level(map.min_x, map.min_y)
	bounds.max_x, bounds.max_z = screen_to_level(map.max_x, map.max_y)
	
	local object_data_reader = ObjectDataReader.create()	
			
	while not object_data_reader:reached_end() do		
		if object_data_reader:check_flag("force_collisions") then	
			local position = object_data_reader:get_value("position")
			
			if (((position[1] + 500.0) > bounds.min_x) and ((position[1] - 500.0) < bounds.max_x) and
				((position[3] + 500.0) > bounds.min_z) and ((position[3] - 500.0) < bounds.max_z)) then
				draw_object(object_data_reader)
			end
		end	
		
		object_data_reader:next_object()
	end
end

function get_view_cone_alpha(_is_active)
	return (_is_active and colors.view_cone_default_alpha or colors.view_cone_inactive_alpha)
end

function get_target_alpha(_is_active)
	return (_is_active and colors.default_alpha or colors.target_inactive_alpha)
end

function draw_character(_x, _z, _radius, _clipping_height, _view_angle, _id, _color, _alpha_function)
	local screen_x, screen_y = level_to_screen(_x, _z)
	local screen_radius = units_to_pixels(_radius)
	local screen_diameter = (screen_radius * 2)
		
	if (((screen_x - screen_radius) > map.min_x) and
		((screen_y - screen_radius) > map.min_y) and
		((screen_x + screen_radius) < map.max_x) and
		((screen_y + screen_radius) < map.max_y)) then	
		local is_target = (target.id and (target.id == _id) or false)
		local is_active = is_active_floor(_clipping_height)			
		local color = (_color + _alpha_function(is_active))
		
		gui.drawEllipse((screen_x - screen_radius), (screen_y - screen_radius), screen_diameter, screen_diameter, color, color)	
		
		if _view_angle then
			local view_cone_radius = (screen_radius * view_cone.scale)
			local view_cone_diameter = (view_cone_radius * 2)
			local view_cone_color = (colors.view_cone_default + get_view_cone_alpha(is_active))
			
			gui.drawPie((screen_x - view_cone_radius), (screen_y - view_cone_radius), view_cone_diameter, view_cone_diameter, (_view_angle - 45), 90, view_cone_color, view_cone_color)
		end
		
		if is_target then
			local target_radius = (screen_radius * target.scale)
			local target_diameter = (target_radius * 2)
			local target_color = (colors.target_default + get_target_alpha(is_active))
		
			gui.drawEllipse((screen_x - target_radius), (screen_y - target_radius), target_diameter, target_diameter, target_color)
		end
	end
end

function get_distance(_p1, _p2)
	local diff_x = (_p1.x - _p2.x)
	local diff_y = (_p1.y - _p2.y)
	local diff_z = (_p1.z - _p2.z)
	
	return math.sqrt((diff_x * diff_x) + (diff_y * diff_y) + (diff_z * diff_z))
end

local loaded_states = {}

function check_loaded_state(_id, _position, _segment_info)
	if not loaded_states[_id] then
		loaded_states[_id] = {["is_loaded"] = true, ["position"] = _position, ["segment_info"] = _segment_info}
	end
	
	local loaded_state = loaded_states[_id]

	if ((_segment_info.coverage ~= loaded_state.segment_info.coverage) or
		(_segment_info.length ~= loaded_state.segment_info.length)) then
		if ((_segment_info.coverage >= 0.0) and 
			(_segment_info.coverage <= _segment_info.length)) then
			local diff = (_segment_info.coverage - loaded_state.segment_info.coverage)
			
			if ((_segment_info.coverage == 0.0) or 
				((diff >= 0.0) and (diff <= 20.0))) then
				loaded_state.is_loaded = false
			end
		end
		
		loaded_state.segment_info = _segment_info
	end	
	
	if ((_position.x ~= loaded_state.position.x) or
		(_position.y ~= loaded_state.position.y) or 
		(_position.z ~= loaded_state.position.z)) then		
		local distance = get_distance(_position, loaded_state.position)
		
		if (distance <= 20.0) then
			loaded_state.is_loaded = true
		end
		
		loaded_state.position = _position
	end	
	
	return loaded_state.is_loaded
end

function get_default_alpha(_is_active)
	return (_is_active and colors.default_alpha or colors.inactive_alpha)
end

function get_unloaded_alpha(_is_active)
	return (_is_active and colors.guard_unloaded_alpha or colors.guard_inactive_unloaded_alpha)
end

function draw_guard(_guard_data_reader)
	local guard_action_colors = 
	{
		[0x4] = colors.guard_dying,
		[0x5] = colors.guard_dying,
		[0x6] = colors.guard_injured,
		[0x8] = colors.guard_shooting,
		[0x9] = colors.guard_shooting,
		[0xA] = colors.guard_shooting,
		[0x14] = colors.guard_throwing_grenade
	}
	
	local id = _guard_data_reader:get_value("id")
	
	if (id == 0xFF) then
		return
	end	
	
	local position = _guard_data_reader:get_position()
	local current_action = _guard_data_reader:get_value("current_action")
	local collision_radius = _guard_data_reader:get_value("collision_radius")
	local clipping_height = _guard_data_reader:get_value("clipping_height")		
	local color = (guard_action_colors[current_action] or colors.guard_default)
	
	local is_loaded = true
	
	-- Is the guard moving?
	if ((current_action == 0xF) or (current_action == 0xE)) then
		local is_path = (current_action == 0xE)
		
		local segment_info = _guard_data_reader:get_segment_info(is_path)		
		local target_position = _guard_data_reader:get_target_position(is_path)
		
		draw_line(position, target_position, clipping_height, color, get_unloaded_alpha)
		
		is_loaded = check_loaded_state(id, position, segment_info)
		
		if not is_loaded then
			local dir_x = ((target_position.x - position.x) / segment_info.length)
			local dir_z = ((target_position.z - position.z) / segment_info.length)
			
			local unloaded_position_x = (position.x + (dir_x * segment_info.coverage))
			local unloaded_position_z = (position.z + (dir_z * segment_info.coverage))
			
			draw_character(unloaded_position_x, unloaded_position_z, collision_radius, clipping_height, nil, nil, color, get_unloaded_alpha)
		end
	end
	
	local alpha_function = (is_loaded and get_default_alpha or get_unloaded_alpha)
	
	draw_character(position.x, position.z, collision_radius, clipping_height, nil, id, color, alpha_function)
end

function draw_guards()
	local guard_data_reader = GuardDataReader.create()

	repeat
		draw_guard(guard_data_reader)
	until not guard_data_reader:next_non_empty_slot()
end

function draw_bond()
	local x = PlayerData.get_value("position_x")
	local z = PlayerData.get_value("position_z")
	local radius = PlayerData.get_value("collision_radius")
	local clipping_height = PlayerData.get_value("clipping_height")
	local view_angle = (PlayerData.get_value("azimuth_angle") + 90)
	
	draw_character(x, z, radius, clipping_height, view_angle, 0xFF, colors.bond_default, get_default_alpha)
end

function get_position_of_id(_id)
	if (_id == 0xFF) then
		local x = PlayerData.get_value("position_x")
		local y = PlayerData.get_value("position_y")
		local z = PlayerData.get_value("position_z")
		
		return {["x"] = x, ["y"] = y, ["z"] = z}
	else
		local guard_data_reader = GuardDataReader.create()
		
		repeat
			local id = guard_data_reader:get_value("id")
			
			if (id == _id) then
				return guard_data_reader:get_position()
			end
		until not guard_data_reader:next_non_empty_slot()
	end
	
	return nil
end

function get_clipping_height_of_id(_id)
	if (_id == 0xFF) then
		return PlayerData.get_value("clipping_height")		
	else
		local guard_data_reader = GuardDataReader.create()
	
		repeat
			local id = guard_data_reader:get_value("id")
			
			if (id == _id) then
				return guard_data_reader:get_value("clipping_height")
			end
		until not guard_data_reader:next_non_empty_slot()
	end
	
	return nil
end

function find_nearest_target(x, y)
	local ids = {0xFF}	
	
	local guard_data_reader = GuardDataReader.create()
	
	repeat
		table.insert(ids, guard_data_reader:get_value("id"))
	until not guard_data_reader:next_non_empty_slot()
	
	local ids_and_distances = {}
	
	for index, id in ipairs(ids) do
		local position = get_position_of_id(id)
		
		local screen_x, screen_y = level_to_screen(position.x, position.z)
		
		local diff_x = (screen_x - x)
		local diff_y = (screen_y - y)
		
		local distance = math.sqrt((diff_x * diff_x) + (diff_y * diff_y))
		
		table.insert(ids_and_distances, {["id"] = id, ["distance"] = distance})
	end
	
	table.sort(ids_and_distances, (function(a, b) return (a.distance < b.distance) end))
	
	local nearest_id_and_distance = ids_and_distances[1]
	
	if (nearest_id_and_distance.distance > (target.pick_radius * camera.zoom)) then
		return nil
	end
	
	return nearest_id_and_distance.id
end

function on_mouse_button_down(x, y)
	target.id = find_nearest_target(x, y)
end

function on_mouse_button_up(x, y)
end

function on_mouse_drag(diff_x, diff_y)	
	 if (camera.mode == 1) then
		 camera.position.x = (camera.position.x - pixels_to_units(diff_x))
		 camera.position.z = (camera.position.z - pixels_to_units(diff_y))
		 
		 camera.position.x = math.max(camera.position.x, level.bounds.min_x)
		 camera.position.x = math.min(camera.position.x, level.bounds.max_x)
		 camera.position.z = math.max(camera.position.z, level.bounds.min_z)
		 camera.position.z = math.min(camera.position.z, level.bounds.max_z)
	 end
end

local previous_mouse =  nil

function on_update_mouse()
	current_mouse = input.getmouse()
	
	if (previous_mouse) and (previous_mouse.Left) then	
		if (current_mouse.Left) then
			local diff_x = (current_mouse.X - previous_mouse.X)
			local diff_y = (current_mouse.Y - previous_mouse.Y)		
		
			on_mouse_drag(diff_x, diff_y)
		else	
			on_mouse_button_up(current_mouse.X, current_mouse.Y)							
		end
	elseif (current_mouse.Left) then
		if (current_mouse.X >= 0) and
			(current_mouse.Y >= 0) and
			(current_mouse.X < screen.width) and
			(current_mouse.Y < screen.height) then			
			on_mouse_button_down(current_mouse.X, current_mouse.Y)
		else
			current_mouse.Left = false
		end
	end
	
	previous_mouse = current_mouse
end

function find_index(_array, _predicate)
	for index = 1, #_array, 1 do
		if _predicate(_array[index]) then
			return index
		end
	end
	
	return nil
end

function on_switch_mode()
	camera.mode = (math.mod(camera.mode, #camera.modes) + 1)
end

function on_switch_floor()
	if (camera.mode == 1) then	
		local index = find_index(level.floors, (function(floor) return (floor.number == camera.floor) end))
	
		camera.floor = level.floors[math.mod(index, #level.floors) + 1].number
	end
end

function on_zoom_in()
	camera.zoom = math.min((camera.zoom + camera.zoom_step), camera.zoom_max)
end

function on_zoom_out()
	camera.zoom = math.max((camera.zoom - camera.zoom_step), camera.zoom_min)
end

function on_keyboard_button_down(key)
	if (key == camera.switch_mode_key) then
		on_switch_mode()
	elseif (key == camera.switch_floor_key) then
		on_switch_floor()
	elseif (key == camera.zoom_in_key) then
		on_zoom_in()
	elseif (key == camera.zoom_out_key) then
		on_zoom_out()
	end
end

function on_keyboard_button_up(key)
end

local previous_keyboard = nil

function on_update_keyboard()
	local current_keyboard = input.get()
	
	if previous_keyboard then
		for key, state in pairs(previous_keyboard) do
			if not current_keyboard[key] then
				on_keyboard_button_up(key)
			end
		end
		
		for key, state in pairs(current_keyboard) do
			if not previous_keyboard[key] then
				on_keyboard_button_down(key)
			end
		end
	end	
	
	previous_keyboard = current_keyboard
end

function on_update_camera()	
	if (camera.mode == 2) then
		if target.id then
			local target_position = get_position_of_id(target.id)
			local target_clipping_height = get_clipping_height_of_id(target.id)
			
			if target_position and target_clipping_height then
				camera.position.x = target_position.x
				camera.position.z = target_position.z
				
				camera.floor = get_floor(target_clipping_height)
			end
		end	
	end
	
	local output_y = (screen.height - 19)
	
	gui.drawText(10, output_y, "Mode: " .. camera.modes[camera.mode])
	gui.drawText(394, output_y, string.format("X: %d Z: %d", camera.position.x, camera.position.z))
	gui.drawText((screen.width - 85), output_y, "Zoom: " .. camera.zoom .. "x")
	
	local floor_suffixes = {"%dst", "%dnd", "%drd", "%dth"}		
	
	local floor_number = ((camera.floor < 0) and math.abs(camera.floor) or (camera.floor + 1))
	local floor_type = ((camera.floor < 0) and "basement" or "floor")	
	local floor_suffix = floor_suffixes[math.min(math.mod(floor_number, 10), 4)]
	local floor_string = string.format(floor_suffix .. " " .. floor_type, floor_number)
	
	gui.drawText(284, output_y, floor_string)
	
	local target_id_string = "None"
	
	if target.id then
		if target.id == 0xFF then
			target_id_string = "Bond"
		else
			target_id_string = string.format("Guard (0x%X)", target.id)
		end
	end
	
	gui.drawText(120, output_y, "Target: " .. target_id_string)
end

local previous_mission = 0xFF

function on_update()
	if GameState.get_current_scene() ~= 0xB then
		return
	end
	
	if GameState.get_global_time_divided_by_four() == 0 then
		return
	end		
	
	if not GuardData.get_slot_address() then
		return
	end
	
	local current_mission = GameState.get_current_mission()
	
	if current_mission ~= previous_mission then					
		load_level(GameState.get_mission_name(current_mission))
		
		previous_mission = current_mission
	end

	on_update_mouse()
	on_update_keyboard()
	on_update_camera()	
	
	draw_map()
	draw_objects()
	draw_guards()
	draw_bond()
end

load_level_data()

event.onframeend(on_update)