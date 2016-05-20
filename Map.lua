require "Data\\GameData"
require "Data\\PlayerData"
require "Utilities\\QuadTree"
require "Utilities\\GuardDataReader"
require "Utilities\\ObjectDataReader"
require "Utilities\\ProjectileDataReader"
require "Utilities\\ExplosionDataReader"

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
camera.position_x = 0.0
camera.position_z = 0.0
camera.floor = 0
camera.zoom = 5.0
camera.zoom_min = 1.0
camera.zoom_max = 10.0
camera.zoom_step = 0.5
camera.switch_mode_key = "M"
camera.switch_floor_key = "F"
camera.zoom_in_key = "NumberPadPlus"
camera.zoom_out_key = "NumberPadMinus"

local target = {}

target.type = "Bond"
target.data = nil

local constants = {}

constants.default_alpha = 0.6
constants.inactive_alpha_factor = 0.3
constants.view_cone_scale = 4.0
constants.target_circle_scale = 3.0
constants.target_pick_radius = 5.0
constants.projectile_radius = 8.0
constants.shockwave_to_damage_interval_ratio = 0.25
constants.shockwave_intensity = 0.3
constants.max_fadeout_intensity = 0.8

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

function make_inactive_alpha(_a)
	return make_alpha(constants.inactive_alpha_factor * _a)
end

function make_alpha_pair(_a)
	return {["active"] = make_alpha(_a), ["inactive"] = make_inactive_alpha(_a)}
end

local colors = {}

colors.default_alpha = make_alpha_pair(constants.default_alpha)

colors.level_color = make_rgb(1.0, 1.0, 1.0)
colors.object_color = make_rgb(1.0, 1.0, 1.0)

colors.view_cone_color = make_rgb(1.0, 1.0, 1.0)
colors.view_cone_alpha = make_alpha_pair(0.2)
colors.velocity_color = make_rgb(0.2, 0.8, 0.4)
colors.target_color = make_rgb(1.0, 0.0, 0.0)

colors.bond_default_color = make_rgb(0.0, 1.0, 1.0)
colors.bond_invincible_color = make_rgb(0.6, 1.0, 1.0)

colors.guard_default_color = make_rgb(0.0, 1.0, 0.0)
colors.guard_dying_color = make_rgb(0.5, 0.0, 0.0)
colors.guard_injured_color = make_rgb(1.0, 0.3, 0.3)
colors.guard_shooting_color = make_rgb(1.0, 1.0, 0.0)
colors.guard_throwing_grenade_color = make_rgb(0.0, 0.5, 0.0)
colors.guard_unloaded_alpha = make_alpha_pair(0.3)

colors.projectile_default_color = make_rgb(0.6, 0.6, 0.6)
colors.projectile_grenade_color = make_rgb(0.0, 0.6, 0.0)
colors.projectile_remote_mine_color = make_rgb(0.8, 0.4, 0.4)
colors.projectile_proximity_mine_color = make_rgb(0.4, 1.0, 0.4)
colors.projectile_timed_mine_color = make_rgb(1.0, 1.0, 0.4)

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
		
		table.insert(edges, {["x1"] = x1, ["y1"] = y1, ["z1"] = z1, ["x2"] = x2, ["y2"] = y2, ["z2"] = z2})
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

function init_quadtree(_bounds, _edges)
	local quadtree = QuadTree.create(_bounds.min_x, _bounds.min_z, _bounds.width, _bounds.height, 1)
	
	if _edges then
		append_quadtree(quadtree, _edges)
	end
	
	return quadtree
end

function append_quadtree(_quadtree, _edges)
	for index, edge in ipairs(_edges) do
		_quadtree:insert(edge)
	end
end

local level_data = {}

-- TODO: Use GameData.mission_index_to_name instead (when all maps are available)
function load_level_data()
	level_data["Dam"] = parse_map_file("Maps/Dam.map")
	level_data["Facility"] = parse_map_file("Maps/Facility.map")
	level_data["Runway"] = parse_map_file("Maps/Runway.map")
	level_data["Surface 1"] = parse_map_file("Maps/Surface 1.map")
	level_data["Bunker 1"] = parse_map_file("Maps/Bunker 1.map")
	level_data["Silo"] = parse_map_file("Maps/Silo.map")
	level_data["Frigate"] = parse_map_file("Maps/Frigate.map")
	level_data["Bunker 2"] = parse_map_file("Maps/Bunker 2.map")
	
	for name, data in pairs(level_data) do
		for index, edge in ipairs(data.edges) do
			edge.color = colors.level_color
		end
	end
end

local level = {}

function load_level(_name)
	--local scale, bounds, edges = parse_map_file("Maps/" .. _name .. ".map")
	level = level_data[_name]
	
	level.bounds.width = (level.bounds.max_x - level.bounds.min_x)
	level.bounds.height = (level.bounds.max_z - level.bounds.min_z)
	
	level.quadtree = init_quadtree(level.bounds, level.edges)
end

function get_distance_2d(_x1, _y1, _x2, _y2)
	local diff_x = (_x1 - _x2)
	local diff_y = (_y1 - _y2)
	
	return math.sqrt((diff_x * diff_x) + (diff_y * diff_y))
end

function get_distance_3d(_x1, _y1, _z1, _x2, _y2, _z2)
	local diff_x = (_x1 - _x2)
	local diff_y = (_y1 - _y2)
	local diff_z = (_z1 - _z2)
	
	return math.sqrt((diff_x * diff_x) + (diff_y * diff_y) + (diff_z * diff_z))
end

local objects = {}

function get_object_edges(_object_data_reader)
	local edges = {}	
	local points, min_y, max_y = _object_data_reader:get_collision_data()
	
	for i = 1, #points, 1 do
		local j = ((i % #points) + 1)
		
		local edge = {}
		
		edge.x1 = points[i].x
		edge.y1 = min_y
		edge.z1 = points[i].y			
		edge.x2 = points[j].x
		edge.y2 = max_y
		edge.z2 = points[j].y	
		
		edge.color = colors.object_color
		
		table.insert(edges, edge)
	end
	
	return edges
end

function load_static_object(_object_data_reader)	
	local static_object = {}
	
	static_object.edges = get_object_edges(_object_data_reader)
	static_object.data_reader = _object_data_reader:clone()
	
	append_quadtree(objects.quadtree, static_object.edges)

	table.insert(objects.static, static_object)
end

function load_dynamic_object(_object_data_reader)
	local dynamic_object = {}
	
	-- TODO: Handle door displacement
	local position = _object_data_reader:get_value("position")	
	local edges = get_object_edges(_object_data_reader)
	
	local max_distance = 0.0
	
	for index, edge in ipairs(edges) do
		local distance = get_distance_2d(edge.x1, edge.z1, position.x, position.z)
		
		max_distance = math.max(max_distance, distance)
	end
	
	dynamic_object.bounding_radius = max_distance
	dynamic_object.data_reader = _object_data_reader:clone()

	table.insert(objects.dynamic, dynamic_object)
end

function load_object(_object_data_reader)
	local is_door = (_object_data_reader.current_data.type == 0x01)
	local is_vehicle = (_object_data_reader.current_data.type == 0x27)
	local is_tank = (_object_data_reader.current_data.type == 0x2D)
	
	if is_door then
		local state = _object_data_reader:get_value("state")
	
		-- Is the door opening or closing?
		if (state == 0x01) or (state == 0x02) then
			load_dynamic_object(_object_data_reader)
		else
			load_static_object(_object_data_reader)
		end	
	elseif is_vehicle or is_tank then
		load_dynamic_object(_object_data_reader)	
	else
		load_static_object(_object_data_reader)
	end
end

function load_objects()	
	objects.static = {}
	objects.dynamic = {}	
	objects.quadtree = init_quadtree(level.bounds)
	
	ObjectDataReader.for_each(function(_object_data_reader)
		if _object_data_reader:check_flag("force_collisions") then
			load_object(_object_data_reader)
		end
	end)
end

function units_to_pixels(_units)
	return ((_units * camera.zoom) / map.units_per_pixel)
end

function pixels_to_units(_pixels)
	return ((_pixels * map.units_per_pixel) / camera.zoom)
end

function level_to_screen(_x, _z)
	local diff_x = units_to_pixels(_x - camera.position_x)
	local diff_z = units_to_pixels(_z - camera.position_z)
	
	local screen_x = (map.center_x + diff_x)
	local screen_y = (map.center_y + diff_z)
	
	return screen_x, screen_y
end

function screen_to_level(_x, _y)	
	local diff_x = (_x - map.center_x)
	local diff_y = (_y - map.center_y)
	
	local level_x = (pixels_to_units(diff_x) + camera.position_x)
	local level_z = (pixels_to_units(diff_y) + camera.position_z)
	
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

function get_current_alpha(_alpha, _is_active)
	local alpha = (_alpha or colors.default_alpha)
	
	return (_is_active and alpha.active or alpha.inactive)
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

function draw_line(_line)
	local line = {}

	line.x1, line.y1 = level_to_screen(_line.x1, _line.z1)
	line.x2, line.y2 = level_to_screen(_line.x2, _line.z2)
	
	if (((line.x1 < map.min_x) or (line.x1 > map.max_x)) or
		((line.y1 < map.min_y) or (line.y1 > map.max_y)) or
		((line.x2 < map.min_x) or (line.x2 > map.max_x)) or
		((line.y2 < map.min_y) or (line.y2 > map.max_y))) then
		line = clip_line(line, map)
		
		if not line then
			return
		end
	end	
	
	local min_height, max_height = _line.y1, _line.y2
	
	if (max_height < min_height) then
		min_height, max_height = max_height, min_height
	end
	
	local is_active = ((get_floor(min_height) <= camera.floor) and 
					   (get_floor(max_height) >= camera.floor))						   
	local color = (_line.color + get_current_alpha(_line.alpha, is_active))

	gui.drawLine(line.x1, line.y1, line.x2, line.y2, color)	
end

function draw_circle(_circle)
	local screen_x, screen_y = level_to_screen(_circle.x, _circle.z)
	local screen_radius = units_to_pixels(_circle.radius)
	local screen_diameter = (screen_radius * 2)
	
	local ellipse = {}
	
	ellipse.x = (screen_x - screen_radius)
	ellipse.y = (screen_y - screen_radius)
	ellipse.width = screen_diameter
	ellipse.height = screen_diameter
	
	if ((ellipse.x < map.min_x) or
		(ellipse.y < map.min_y) or
		((ellipse.x + ellipse.width) > map.max_x) or
		((ellipse.y + ellipse.height) > map.max_y)) then
		return
	end
			
	local is_active = is_active_floor(_circle.y)	
	local color = (_circle.color + get_current_alpha(_circle.alpha, is_active))
	
	if _circle.is_hollow then
		gui.drawEllipse(ellipse.x, ellipse.y, ellipse.width, ellipse.height, color)	
	else
		gui.drawEllipse(ellipse.x, ellipse.y, ellipse.width, ellipse.height, color, color)		
	end			
end

function draw_cone(_cone)
	local screen_x, screen_y = level_to_screen(_cone.x, _cone.z)
	local screen_radius = units_to_pixels(_cone.radius)
	local screen_diameter = (screen_radius * 2)

	local pie = {}
	
	pie.x = (screen_x - screen_radius)
	pie.y = (screen_y - screen_radius)
	pie.width = screen_diameter
	pie.height = screen_diameter
	pie.start_angle = _cone.start_angle
	pie.sweep_angle = _cone.sweep_angle
	
	if ((pie.x < map.min_x) or
		(pie.y < map.min_y) or
		((pie.x + pie.width) > map.max_x) or
		((pie.y + pie.height) > map.max_y)) then	
		return
	end
	
	local is_active = is_active_floor(_cone.y)
	local color = (_cone.color + get_current_alpha(_cone.alpha, is_active))

	gui.drawPie(pie.x, pie.y, pie.width, pie.height, pie.start_angle, pie.sweep_angle, color, color)		
end

function draw_rectangle(_rectangle)
	local box = {}
	
	box.x1, box.y1 = level_to_screen(_rectangle.x1, _rectangle.z1)
	box.x2, box.y2 = level_to_screen(_rectangle.x2, _rectangle.z2)
	
	if ((box.x1 > map.max_x) or
		(box.y1 > map.max_y) or
		(box.x2 < map.min_x) or
		(box.y2 < map.min_y)) then
		return
	end
	
	box.x1 = math.max(box.x1, map.min_x)
	box.y1 = math.max(box.y1, map.min_y)
	box.x2 = math.min(box.x2, map.max_x)
	box.y2 = math.min(box.y2, map.max_y)
	
	local min_height, max_height = _rectangle.y1, _rectangle.y2
	
	if (max_height < min_height) then
		min_height, max_height = max_height, min_height
	end
	
	local is_active = ((get_floor(min_height) <= camera.floor) and
					   (get_floor(max_height) >= camera.floor))					   
	local color = (_rectangle.color + get_current_alpha(_rectangle.alpha, is_active))
	
	gui.drawBox(box.x1, box.y1, box.x2, box.y2, color, color)
end

function draw_level()	
	local bounds = {}
	local collisions = {}
	
	bounds.x1, bounds.z1 = screen_to_level(map.min_x, map.min_y)
	bounds.x2, bounds.z2 = screen_to_level(map.max_x, map.max_y)
	
	level.quadtree:find_collisions(bounds, collisions)
	
	for key, edge in pairs(collisions) do	
		draw_line(edge)
	end
end

function draw_static_objects(_bounds)
	local collisions = {}
	
	objects.quadtree:find_collisions(_bounds, collisions)
	
	for key, edge in pairs(collisions) do
		draw_line(edge)
	end
end

function draw_dynamic_objects(_bounds)
	for index, object in ipairs(objects.dynamic) do
		local position = object.data_reader:get_value("position")
		
		if (((position.x + object.bounding_radius) > _bounds.x1) and
			((position.z + object.bounding_radius) > _bounds.z1) and
			((position.x - object.bounding_radius) < _bounds.x2) and
			((position.z - object.bounding_radius) < _bounds.z2)) then
			local edges = get_object_edges(object.data_reader)
			
			for index, edge in ipairs(edges) do
				draw_line(edge)
			end
		end
	end
end

function draw_objects()
	local bounds = {}
	
	bounds.x1, bounds.z1 = screen_to_level(map.min_x, map.min_y)
	bounds.x2, bounds.z2 = screen_to_level(map.max_x, map.max_y)

	draw_static_objects(bounds)
	draw_dynamic_objects(bounds)
end

function draw_character(_character)
	draw_circle(_character)
	
	if _character.view_angle then
		local view_cone = {}
		
		view_cone.x = _character.x
		view_cone.y = _character.y
		view_cone.z = _character.z
		view_cone.radius = (_character.radius * constants.view_cone_scale)
		view_cone.start_angle = (_character.view_angle - 45.0)
		view_cone.sweep_angle = 90.0
		view_cone.color = colors.view_cone_color
		view_cone.alpha = colors.view_cone_alpha
		
		draw_cone(view_cone)
	
		if _character.velocity then
			local view_angle_radians = math.rad(_character.view_angle)
			local view_angle_cosine = math.cos(view_angle_radians)
			local view_angle_sine = math.sin(view_angle_radians)
			
			local velocity_x = ((view_angle_cosine * _character.velocity.z) - (view_angle_sine * _character.velocity.x))
			local velocity_z = ((view_angle_cosine * _character.velocity.x) + (view_angle_sine * _character.velocity.z))
			
			local velocity_line = {}
			
			velocity_line.x1 = _character.x
			velocity_line.y1 = _character.y
			velocity_line.z1 = _character.z
			
			velocity_line.x2 = (_character.x + velocity_x)
			velocity_line.y2 = _character.y
			velocity_line.z2 = (_character.z + velocity_z)
			
			velocity_line.color = colors.velocity_color
			
			draw_line(velocity_line)
		end
	end
	
	if _character.is_target then
		local target_circle = {}
		
		target_circle.x = _character.x
		target_circle.y = _character.y
		target_circle.z = _character.z
		target_circle.radius = (_character.radius * constants.target_circle_scale)
		target_circle.color = colors.target_color
		target_circle.alpha = colors.target_alpha
		target_circle.is_hollow = true
		
		draw_circle(target_circle)
	end
end

local loaded_states = {}

function check_loaded_state(_id, _position, _segment_coverage, _segment_length)
	if not loaded_states[_id] then
		local loaded_state = {}
		
		loaded_state.is_loaded = true
		loaded_state.position = _position
		loaded_state.segment_coverage = _segment_coverage
		loaded_state.segment_length = _segment_length
		
		loaded_states[_id] = loaded_state
	end
	
	local loaded_state = loaded_states[_id]

	if ((_segment_coverage ~= loaded_state.segment_coverage) or
		(_segment_length ~= loaded_state.segment_length)) then
		if ((_segment_coverage >= 0.0) and 
			(_segment_coverage <= _segment_length)) then
			local diff = (_segment_coverage - loaded_state.segment_coverage)
			
			if ((_segment_coverage == 0.0) or 
				((diff >= 0.0) and (diff <= 20.0))) then
				loaded_state.is_loaded = false
			end
		end
		
		loaded_state.segment_coverage = _segment_coverage
		loaded_state.segment_length = _segment_length
	end	
	
	if ((_position.x ~= loaded_state.position.x) or
		(_position.y ~= loaded_state.position.y) or 
		(_position.z ~= loaded_state.position.z)) then
		local distance = get_distance_3d(_position.x, _position.y, _position.z, loaded_state.position.x, loaded_state.position.y, loaded_state.position.z)
		
		if (distance <= 20.0) then
			loaded_state.is_loaded = true
		end
		
		loaded_state.position = _position
	end	
	
	return loaded_state.is_loaded
end

function draw_guard(_guard_data_reader)
	local action_to_color = 
	{
		[0x04] = colors.guard_dying_color,
		[0x05] = colors.guard_dying_color,
		[0x06] = colors.guard_injured_color,
		[0x08] = colors.guard_shooting_color,
		[0x09] = colors.guard_shooting_color,
		[0x0A] = colors.guard_shooting_color,
		[0x14] = colors.guard_throwing_grenade_color
	}
	
	local id = _guard_data_reader:get_value("id")
	
	if (id == 0xFF) then
		return
	end	
	
	local position = _guard_data_reader:get_position()
	local collision_radius = _guard_data_reader:get_value("collision_radius")
	local clipping_height = _guard_data_reader:get_value("clipping_height")		
	local current_action = _guard_data_reader:get_value("current_action")
	local color = (action_to_color[current_action] or colors.guard_default_color)
	local alpha = colors.default_alpha
	
	local is_loaded = true
	
	-- Is the guard fading?
	if (current_action == 0x05) then
		alpha = make_alpha_pair(constants.default_alpha * (_guard_data_reader:get_value("alpha") / 255.0))
	-- Is the guard moving?
	elseif ((current_action == 0xF) or (current_action == 0xE)) then
		local target_position = nil
		local segment_coverage = nil
		local segment_length = nil
	
		if (current_action == 0xE) then
			target_position = _guard_data_reader:get_value("path_target_position")
			segment_coverage = _guard_data_reader:get_value("path_segment_coverage")
			segment_length = _guard_data_reader:get_value("path_segment_length")			
		else
			target_position = _guard_data_reader:get_value("target_position")
			segment_coverage = _guard_data_reader:get_value("segment_coverage")		
			segment_length = _guard_data_reader:get_value("segment_length")	
		end
		
		is_loaded = check_loaded_state(id, position, segment_coverage, segment_length)
		
		if not is_loaded then
			local dir_x = ((target_position.x - position.x) / segment_length)
			local dir_z = ((target_position.z - position.z) / segment_length)
			
			local unloaded_character = {}
			
			unloaded_character.x = (position.x + (dir_x * segment_coverage))
			unloaded_character.y = clipping_height
			unloaded_character.z = (position.z + (dir_z * segment_coverage))
			unloaded_character.radius = collision_radius
			unloaded_character.color = color
			unloaded_character.alpha = colors.guard_unloaded_alpha
			
			draw_character(unloaded_character)
		end
		
		local segment_line = {}
		
		segment_line.x1 = position.x
		segment_line.y1 = clipping_height
		segment_line.z1 = position.z
		
		segment_line.x2 = target_position.x
		segment_line.y2 = clipping_height
		segment_line.z2 = target_position.z		
		
		segment_line.color = color
		segment_line.alpha = (not is_loaded and colors.guard_unloaded_alpha)
		
		draw_line(segment_line)	
	end
	
	local loaded_character = {}
	
	loaded_character.x = position.x
	loaded_character.y = clipping_height
	loaded_character.z = position.z
	loaded_character.radius = collision_radius
	loaded_character.is_target = ((target.type == "Guard") and (target.data == id))
	loaded_character.color = color
	loaded_character.alpha = alpha
	
	draw_character(loaded_character)
end

function draw_guards()
	GuardDataReader.for_each(draw_guard)
end

function draw_bond()	
	local position = PlayerData.get_value("position")
	local collision_radius = PlayerData.get_value("collision_radius")
	local clipping_height = PlayerData.get_value("clipping_height")
	local azimuth_angle = PlayerData.get_value("azimuth_angle")
	local velocity = PlayerData.get_value("velocity")
	local invincibility_timer = PlayerData.get_value("invincibility_timer")	
	
	local is_invincible = (invincibility_timer ~= 0xFFFFFFFF)

	local character = {}
	
	character.x = position.x
	character.y = clipping_height
	character.z = position.z
	character.radius = collision_radius
	character.view_angle = (azimuth_angle + 90)
	character.velocity = velocity
	character.is_target = (target.type == "Bond")
	character.color = (is_invincible and colors.bond_invincible_color or colors.bond_default_color)
	
	draw_character(character)		
end

function draw_projectile(_projectile_data_reader)
	local image_to_color = 
	{
		[0xC4] = colors.projectile_grenade_color,
		[0xC7] = colors.projectile_remote_mine_color,
		[0xC8] = colors.projectile_proximity_mine_color,
		[0xC9] = colors.projectile_timed_mine_color
	}

	local position = _projectile_data_reader:get_value("position")
	local image = _projectile_data_reader:get_value("image")
	
	local projectile_circle = {}
	
	projectile_circle.x = position.x
	projectile_circle.y = position.y
	projectile_circle.z = position.z
	projectile_circle.radius = constants.projectile_radius
	projectile_circle.color = (image_to_color[image] or colors.projectile_default_color)
	
	draw_circle(projectile_circle)	
	
	local target_circle = {}
	
	target_circle.x = position.x
	target_circle.y = position.y
	target_circle.z = position.z
	target_circle.radius = (constants.projectile_radius * constants.target_circle_scale)
	target_circle.color = colors.target_color
	target_circle.alpha = colors.target_alpha
	target_circle.is_hollow = true
	
	draw_circle(target_circle)
end

function draw_projectiles()
	ProjectileDataReader.for_each(draw_projectile)
end

function draw_explosion(_explosion_data_reader)	
	local position = _explosion_data_reader:get_position()
	
	local animation_frame = _explosion_data_reader:get_value("animation_frame")
	local animation_length = _explosion_data_reader:get_type_value("animation_length")
	
	local min_damage_radius = _explosion_data_reader:get_type_value("min_damage_radius")
	local max_damage_radius = _explosion_data_reader:get_type_value("max_damage_radius")
	
	local next_damage_frame = _explosion_data_reader:get_value("next_damage_frame")
	
	local damage_interval = (animation_length / 4)
	local damage_speed = ((max_damage_radius - min_damage_radius) / animation_length)	
	local damage_radius = (min_damage_radius + (animation_frame * damage_speed))	
	
	local shockwave_length = (constants.shockwave_to_damage_interval_ratio * damage_interval)
	local fadeout_length = (damage_interval - shockwave_length)
	
	local intensity = constants.shockwave_intensity
	
	if (animation_frame <= ExplosionData.no_damage_frame_count) then
		damage_radius = (animation_frame * (damage_radius / ExplosionData.no_damage_frame_count))
	else
		local damage_frame = (animation_frame - (next_damage_frame - damage_interval))

		if (next_damage_frame < animation_length) then
			if (damage_frame > fadeout_length) then
				local shockwave_frame = (damage_frame - fadeout_length)
				local shockwave_speed = (damage_radius / shockwave_length)
		
				damage_radius = (shockwave_frame * shockwave_speed)
			else			
				intensity = (constants.max_fadeout_intensity * math.max((1.0 - (damage_frame / fadeout_length)), 0.0))
			end
		else				
			intensity = (constants.max_fadeout_intensity * math.max((1.0 - (damage_frame / damage_interval)), 0.0))
		end		
	end

	local rectangle = {}
	
	rectangle.x1 = (position.x - damage_radius)
	rectangle.y1 = (position.y - damage_radius)
	rectangle.z1 = (position.z - damage_radius)	
	rectangle.x2 = (position.x + damage_radius)
	rectangle.y2 = (position.y + damage_radius)
	rectangle.z2 = (position.z + damage_radius)
	
	rectangle.color = make_rgb(1.0, intensity, 0.0)
	rectangle.alpha = make_alpha_pair(intensity)
	
	draw_rectangle(rectangle)
end

function draw_explosions()
	ExplosionDataReader.for_each(draw_explosion)
end

function pick_target(_x, _y)
	local target_to_position_map = {}	

	target_to_position_map[{["type"] = "Bond"}] = PlayerData.get_value("position")
	
	GuardDataReader.for_each(function(_guard_data_reader)
		local id = _guard_data_reader:get_value("id")
		local position = _guard_data_reader:get_position()
		
		target_to_position_map[{["type"] = "Guard", ["data"] = id}] = position
	end)
	
	local targets_and_distances = {}
	
	for target, position in pairs(target_to_position_map) do
		local distance = get_distance_2d(_x, _y, level_to_screen(position.x, position.z))
		
		table.insert(targets_and_distances, {["target"] = target, ["distance"] = distance})	
	end

	table.sort(targets_and_distances, (function(a, b) return (a.distance < b.distance) end))
	
	local closest_target_and_distance = targets_and_distances[1]
	
	if (closest_target_and_distance.distance > (constants.target_pick_radius * camera.zoom)) then
		return {["type"] = "None"}
	end
	
	return closest_target_and_distance.target
end

function on_mouse_button_down(_x, _y)
	target = pick_target(_x, _y)
end

function on_mouse_button_up(_x, _y)
end

function on_mouse_drag(_diff_x, _diff_y)	
	 if (camera.mode == 1) then
		 camera.position_x = (camera.position_x - pixels_to_units(_diff_x))
		 camera.position_z = (camera.position_z - pixels_to_units(_diff_y))
		 
		 camera.position_x = math.max(camera.position_x, level.bounds.min_x)
		 camera.position_x = math.min(camera.position_x, level.bounds.max_x)
		 camera.position_z = math.max(camera.position_z, level.bounds.min_z)
		 camera.position_z = math.min(camera.position_z, level.bounds.max_z)
	 end
end

local previous_mouse =  nil

function update_mouse()
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

function update_keyboard()
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

function get_target_position()
	local target_position = nil
	local target_height = nil

	if (target.type == "Bond") then
		target_position = PlayerData.get_value("position")
		target_height = PlayerData.get_value("clipping_height")
	elseif (target.type == "Guard") then
		GuardDataReader.for_each(function(_guard_data_reader)
			if (_guard_data_reader:get_value("id") == target.data) then
				target_position = _guard_data_reader:get_position()
				target_height = _guard_data_reader:get_value("clipping_height")
			end
		end)
	end
	
	if not target_position or not target_height then
		return nil
	end
	
	return {["x"] = target_position.x, ["y"] = target_height, ["z"] = target_position.z}
end

function update_camera()	
	if (camera.mode == 2) then
		local target_position = get_target_position()	
		
		if target_position then
			camera.position_x = target_position.x
			camera.position_z = target_position.z
			
			camera.floor = get_floor(target_position.y)
		end
	end
	
	local output_y = (screen.height - 19)
	
	gui.drawText(10, output_y, "Mode: " .. camera.modes[camera.mode])
	gui.drawText(394, output_y, string.format("X: %d Z: %d", camera.position_x, camera.position_z))
	gui.drawText((screen.width - 85), output_y, "Zoom: " .. camera.zoom .. "x")
	
	local floor_suffixes = {"%dst", "%dnd", "%drd", "%dth"}		
	
	local floor_number = ((camera.floor < 0) and math.abs(camera.floor) or (camera.floor + 1))
	local floor_type = ((camera.floor < 0) and "basement" or "floor")	
	local floor_suffix = floor_suffixes[math.min(math.mod(floor_number, 10), 4)]
	local floor_string = string.format(floor_suffix .. " " .. floor_type, floor_number)
	
	gui.drawText(284, output_y, floor_string)
	
	local target_string = target.type
	
	if (target.type == "Guard") then
		target_string = (target_string .. string.format(" (0x%X)", target.data))
	end
	
	gui.drawText(120, output_y, "Target: " .. target_string)
end

function update_static_objects()
	local count = #objects.static

	for i = count, 1, -1 do
		local static_object = objects.static[i]
		
		-- Is this a door?
		if (static_object.data_reader.current_data.type == 0x01) then
			local state = static_object.data_reader:get_value("state")
			
			-- Is the door opening or closing?
			if (state == 0x01) or (state == 0x02) then
				load_dynamic_object(static_object.data_reader)

				table.remove(objects.static, i)
			end
		elseif not static_object.data_reader:check_flag("force_collisions") then
			table.remove(objects.static, i)
		end
	end
	
	-- Rebuild quadtree (if needed)
	if #objects.static ~= count then 
		objects.quadtree = init_quadtree(level.bounds)
	
		for index, object in ipairs(objects.static) do
			append_quadtree(objects.quadtree, object.edges)
		end
	end
end

function update_dynamic_objects()
	for i = #objects.dynamic, 1, -1 do
		local dynamic_object = objects.dynamic[i]
		
		-- Is this a door?
		if (dynamic_object.data_reader.current_data.type == 0x01) then
			local state = dynamic_object.data_reader:get_value("state")
			
			-- Is the door not opening or closing?
			if (state ~= 0x01) and (state ~= 0x02) then			
				load_static_object(dynamic_object.data_reader)
				
				table.remove(objects.dynamic, i)
			end
		end	
	end
end

function update_objects()
	update_static_objects()
	update_dynamic_objects()
end

function on_load_state()
	load_objects()
end

local previous_mission = 0xFF

function on_update()
	if (GameData.get_current_scene() ~= 0xB) then
		return
	end
	
	if (GameData.get_global_time_divided_by_four() == 0) then
		return
	end
	
	local current_mission = GameData.get_current_mission()
	
	if (current_mission ~= previous_mission) then	
		local mission_name = GameData.get_mission_name(current_mission)
	
		load_level(mission_name)
		load_objects()
		
		previous_mission = current_mission
	end

	update_mouse()
	update_keyboard()
	update_camera()	
	update_objects()
	
	draw_level()
	draw_objects()
	draw_guards()
	draw_bond()
	draw_projectiles()
	draw_explosions()
end

load_level_data()

event.onloadstate(on_load_state)
event.onframeend(on_update)