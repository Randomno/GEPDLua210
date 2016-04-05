require "GameState"
require "PlayerData"
require "PositionData"
require "Utilities\\QuadTree"
require "Utilities\\GuardDataReader"

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
map.units_per_pixel = nil

local level = {}

level.bounds = nil
level.scale = nil

local camera = {}

camera.modes = {"Manual", "Follow"}
camera.mode = 2
camera.pos_x = 0.0
camera.pos_z = 0.0
camera.zoom = 2.0
camera.zoom_min = 1.0
camera.zoom_max = 10.0
camera.zoom_step = 0.5
camera.switch_mode_key = "M"
camera.zoom_in_key = "NumberPadPlus"
camera.zoom_out_key = "NumberPadMinus"

local target = {}

target.id = 0xFF
target.scale = 3.0
target.pick_radius = 5.0

function make_color(r, g, b, a)
	local a_hex = bit.band(math.floor((a * 255) + 0.5), 0xFF)
	local r_hex = bit.band(math.floor((r * 255) + 0.5), 0xFF)
	local g_hex = bit.band(math.floor((g * 255) + 0.5), 0xFF)
	local b_hex = bit.band(math.floor((b * 255) + 0.5), 0xFF)
	
	a_hex = bit.lshift(a_hex, (8 * 3))
	r_hex = bit.lshift(r_hex, (8 * 2))
	g_hex = bit.lshift(g_hex, (8 * 1))
	b_hex = bit.lshift(b_hex, (8 * 0))
	
	return (a_hex + r_hex + g_hex + b_hex)
end

local colors = {}

colors.loaded_alpha = make_color(0.0, 0.0, 0.0, 0.6)
colors.unloaded_alpha = make_color(0.0, 0.0, 0.0, 0.2)

colors.guard_default = make_color(0.0, 1.0, 0.0, 0.0)
colors.guard_dying = make_color(0.5, 0.0, 0.0, 0.0)
colors.guard_injured = make_color(1.0, 0.3, 0.3, 0.0)
colors.guard_shooting = make_color(1.0, 1.0, 0.0, 0.0)
colors.guard_throwing_grenade = make_color(0.0, 0.5, 0.0, 0.0)

colors.bond_default = make_color(0.0, 1.0, 1.0, 0.0)
colors.map_default = make_color(1.0, 1.0, 1.0, 0.0)

colors.target = make_color(1.0, 0.0, 0.0, 0.0)

function parse_map_file(filename)
	local file = io.open(filename, "r")
	
	io.input(file)
	
	local scale = io.read("*n")
	local bounds = {}
	local edges = {}
	
	bounds.min_x, bounds.min_z, bounds.max_x, bounds.max_z = io.read("*n", "*n", "*n", "*n")	
	
	while true do
		local x1, z1, x2, z2 = io.read("*n", "*n", "*n", "*n")
		
		if not x1 then
			break
		end
		
		x1 = (x1 / scale)
		z1 = (z1 / scale)
		x2 = (x2 / scale)
		z2 = (z2 / scale)
		
		edges[#edges + 1] = {['x1'] = x1, ['z1'] = z1, ['x2'] = x2, ['z2'] = z2}
	end
	
	io.close(file)
	
	-- return scale, bounds, edges
	return {["scale"] = scale, ["bounds"] = bounds, ["edges"] = edges}
end

local quadtree = {}

function init_quadtree(bounds, edges)
	quadtree = QuadTree.create(bounds.x, bounds.z, bounds.width, bounds.height, 1)	
	
	for index, edge in ipairs(edges) do
		quadtree:insert(edge)
	end
end

local level_name_to_data = {}

function load_level_data()
	level_name_to_data["Facility"] = parse_map_file("Maps/Facility.map")
	level_name_to_data["Bunker 2"] = parse_map_file("Maps/Bunker 2.map")
	level_name_to_data["Streets"] = parse_map_file("Maps/Streets.map")
	level_name_to_data["Aztec"] = parse_map_file("Maps/Aztec.map")
end

function load_level(name)
	--local scale, bounds, edges = parse_map_file("Maps/" .. name .. ".map")
	local level_data = level_name_to_data[name]
	
	level_data.bounds.width = (level_data.bounds.max_x - level_data.bounds.min_x)
	level_data.bounds.height = (level_data.bounds.max_z - level_data.bounds.min_z)
	
	local scaled_bounds = {}
	
	scaled_bounds.x = (level_data.bounds.min_x / level_data.scale)
	scaled_bounds.z = (level_data.bounds.min_z / level_data.scale)
	scaled_bounds.width = (level_data.bounds.width / level_data.scale)
	scaled_bounds.height = (level_data.bounds.height / level_data.scale)
	
	init_quadtree(scaled_bounds, level_data.edges)
	
	map.units_per_pixel = (level_data.bounds.width / map.width)
	
	level.scale = level_data.scale
	level.bounds = level_data.bounds
end

function units_to_pixels(units)
	return ((units * (level.scale * camera.zoom)) / map.units_per_pixel)
end

function pixels_to_units(pixels)
	return ((pixels * map.units_per_pixel) / (level.scale * camera.zoom))
end

function level_to_screen(x, z)
	local diff_x = units_to_pixels(x - camera.pos_x)
	local diff_z = units_to_pixels(z - camera.pos_z)
	
	local screen_x = (map.center_x + diff_x)
	local screen_y = (map.center_y + diff_z)
	
	return screen_x, screen_y
end

function screen_to_level(x, y)	
	local diff_x = (x - map.center_x)
	local diff_y = (y - map.center_y)
	
	local level_x = pixels_to_units(diff_x) + camera.pos_x
	local level_z = pixels_to_units(diff_y) + camera.pos_z
	
	return level_x, level_z
end

function draw_map()	
	local bounds = {}
	local collisions = {}
	
	bounds.x1, bounds.z1 = screen_to_level(0, 0)
	bounds.x2, bounds.z2 = screen_to_level(screen.width, screen.height)		
	
	quadtree:findcollisions(bounds, collisions)
	
	local map_color = (colors.map_default + colors.loaded_alpha)
	
	for key, object in pairs(collisions) do	
		local screen_x1, screen_y1 = level_to_screen(object.x1, object.z1)
		local screen_x2, screen_y2 = level_to_screen(object.x2, object.z2)
		
		if (((screen_x1 > map.min_x) and (screen_x1 < map.max_x)) and
			((screen_y1 > map.min_y) and (screen_y1 < map.max_y))) or
			(((screen_x2 > map.min_x) and (screen_x2 < map.max_x)) and
			((screen_y2 > map.min_y) and (screen_y2 < map.max_y))) then				
			screen_x1 = math.max(screen_x1, map.min_x)
			screen_x1 = math.min(screen_x1, map.max_x)
			screen_y1 = math.max(screen_y1, map.min_y)
			screen_y1 = math.min(screen_y1, map.max_y)
			screen_x2 = math.max(screen_x2, map.min_x)
			screen_x2 = math.min(screen_x2, map.max_x)
			screen_y2 = math.max(screen_y2, map.min_y)
			screen_y2 = math.min(screen_y2, map.max_y)
			
			gui.drawLine(screen_x1, screen_y1, screen_x2, screen_y2, map_color)	
		end
	end
end

function draw_character(x, z, radius, color, is_target)	
	local screen_x, screen_y = level_to_screen(x, z)
	local screen_radius = units_to_pixels(radius)
	local screen_diameter = (screen_radius * 2)
		
	if (((screen_x + screen_radius) > map.min_x) and
		((screen_y + screen_radius) > map.min_y) and
		((screen_x - screen_radius) < map.max_x) and
		((screen_y - screen_radius) < map.max_y)) then	
		gui.drawEllipse((screen_x - screen_radius), (screen_y - screen_radius), screen_diameter, screen_diameter, color, color)	
		
		if (is_target) then
			local target_color = (colors.target + colors.loaded_alpha)
			local target_radius = (screen_radius * target.scale)
			local target_diameter = (target_radius * 2)
		
			gui.drawEllipse((screen_x - target_radius), (screen_y - target_radius), target_diameter, target_diameter, target_color)
		end
	end
end

function draw_line(_start, _end, _color)
	local x1, y1 = level_to_screen(_start.x, _start.z)
	local x2, y2 = level_to_screen(_end.x, _end.z)
	
	gui.drawLine(x1, y1, x2, y2, _color)
end

function get_distance(_p1, _p2)
	local diff_x = (_p1.x - _p2.x)
	local diff_y = (_p1.y - _p2.y)
	local diff_z = (_p1.z - _p2.z)
	
	return math.sqrt((diff_x * diff_x) + (diff_y * diff_y) + (diff_z * diff_z))
end

local id_to_loaded_status = {}

function check_loaded_status(_id, _position, _segment_info)	
	if not id_to_loaded_status[_id] then
		id_to_loaded_status[_id] = 
		{
			["is_loaded"] = true,
			["position"] = _position,
			["segment_info"] = _segment_info
		}
	end
	
	local loaded_status = id_to_loaded_status[_id]	

	if ((_segment_info.coverage ~= loaded_status.segment_info.coverage) or
		(_segment_info.length ~= loaded_status.segment_info.length)) then
		if ((_segment_info.coverage >= 0.0) and 
			(_segment_info.coverage <= _segment_info.length)) then
			local diff = (_segment_info.coverage - loaded_status.segment_info.coverage)
			
			if ((_segment_info.coverage == 0.0) or 
				((diff >= 0.0) and (diff <= 20.0))) then
				loaded_status.is_loaded = false
			end
		end
		
		loaded_status.segment_info = _segment_info
	end	
	
	if ((_position.x ~= loaded_status.position.x) or
		(_position.y ~= loaded_status.position.y) or 
		(_position.z ~= loaded_status.position.z)) then		
		local distance = get_distance(_position, loaded_status.position)
		
		if (distance <= 20.0) then
			loaded_status.is_loaded = true
		end
		
		loaded_status.position = _position		
	end	
	
	return loaded_status.is_loaded
end

function draw_guard(_slot)
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
	
	local guard_data_reader = GuardDataReader.create(_slot)
	
	local id = guard_data_reader:get_value("id")
	
	if (id == 0xFF) then
		return
	end	
	
	local is_loaded = true	
	local is_target = (id == target.id)	
	
	local current_action = guard_data_reader:get_value("current_action")
	local collision_radius = guard_data_reader:get_value("collision_radius")
	
	local position = guard_data_reader:get_position()	
	
	local color = (guard_action_colors[current_action] or colors.guard_default)
	
	-- Is the guard moving?
	if ((current_action == 0xF) or (current_action == 0xE)) then
		local is_path = (current_action == 0xE)
		
		local segment_info = guard_data_reader:get_segment_info(is_path)		
		local target_position = guard_data_reader:get_target_position(is_path)
		
		draw_line(position, target_position, (color + colors.unloaded_alpha))
		
		is_loaded = check_loaded_status(id, position, segment_info)
		
		if not is_loaded then
			local dir_x = ((target_position.x - position.x) / segment_info.length)
			local dir_z = ((target_position.z - position.z) / segment_info.length)
			
			local unloaded_position_x = (position.x + (dir_x * segment_info.coverage))
			local unloaded_position_z = (position.z + (dir_z * segment_info.coverage))
			
			draw_character(unloaded_position_x, unloaded_position_z, collision_radius, (color + colors.unloaded_alpha), false)
		end
	end
	
	if is_loaded then
		color = (color + colors.loaded_alpha)
	else
		color = (color + colors.unloaded_alpha)
	end	
	
	draw_character(position.x, position.z, collision_radius, color, is_target)
end

function draw_guards()
	for slot = 1, 38, 1 do
		draw_guard(slot)
	end
end

function draw_bond()
	local bond_x = read_player_data_value("position_x")
	local bond_z = read_player_data_value("position_z")
	local bond_radius = read_player_data_value("collision_radius")
	local bond_color = (colors.bond_default + colors.loaded_alpha)
	
	draw_character(bond_x, bond_z, bond_radius, bond_color, (target.id == 0xFF))
end

function get_position_of_id(_id)
	local x = 0.0
	local z = 0.0

	if (_id == 0xFF) then
		x = read_player_data_value("position_x")
		z = read_player_data_value("position_z")
	else
		for slot = 1, 38, 1 do	
			local guard_data_reader = GuardDataReader.create(slot)		
			local id = guard_data_reader:get_value("id")
			
			if (id == _id) then
				local position = guard_data_reader:get_position()
				
				x = position.x
				z = position.z
			end			
		end
	end
	
	return x, z
end

function find_nearest_target(x, y)
	local ids = {0xFF}
	
	for slot = 1, 38, 1 do
		local guard_data_reader = GuardDataReader.create(slot)	
		
		table.insert(ids, guard_data_reader:get_value("id"))
	end
	
	local ids_and_distances = {}
	
	for index, id in ipairs(ids) do
		local level_x, level_z = get_position_of_id(id)
		local screen_x, screen_y = level_to_screen(level_x, level_z)
		
		local diff_x = (screen_x - x)
		local diff_y = (screen_y - y)
		
		local distance = math.sqrt((diff_x * diff_x) + (diff_y * diff_y))
		
		table.insert(ids_and_distances, {["id"] = id, ["distance"] = distance})
	end
	
	table.sort(ids_and_distances, (function(a, b) return a.distance < b.distance end))
	
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
		 camera.pos_x = (camera.pos_x - pixels_to_units(diff_x))
		 camera.pos_z = (camera.pos_z - pixels_to_units(diff_y))
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
			(current_mouse.X < client.screenwidth()) and
			(current_mouse.Y < client.screenheight()) then			
			on_mouse_button_down(current_mouse.X, current_mouse.Y)
		else
			current_mouse.Left = false
		end
	end
	
	previous_mouse = current_mouse
end

function on_keyboard_button_down(key)
	if (key == camera.switch_mode_key) then
		camera.mode = (math.mod(camera.mode, #camera.modes) + 1)
	elseif (key == camera.zoom_in_key) then
		camera.zoom = math.min((camera.zoom + camera.zoom_step), camera.zoom_max)
	elseif (key == camera.zoom_out_key) then
		camera.zoom = math.max((camera.zoom - camera.zoom_step), camera.zoom_min)
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
			camera.pos_x, camera.pos_z = get_position_of_id(target.id)
		end	
	end
	
	gui.drawText(10, (client.screenheight() - 20), "Camera mode: " .. camera.modes[camera.mode])
	gui.drawText((client.screenwidth() - 85), (client.screenheight() - 20), "Zoom: " .. camera.zoom .. "x")
	
	local target_id_string = "None"
	
	if target.id then
		if target.id == 0xFF then
			target_id_string = "Bond"
		else
			target_id_string = string.format("Guard (0x%X)", target.id)
		end
	end
	
	gui.drawText(175, (client.screenheight() - 20), "Target: " .. target_id_string)
end

local previous_mission = 0xFF

function on_update()	
	if GameState.get_current_scene() ~= 0xB then
		return
	end
	
	if GameState.get_global_time_divided_by_four() == 0 then
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
	draw_guards()
	draw_bond()
end

load_level_data()

event.onframeend(on_update)