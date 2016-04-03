player_data_pointer = 0x079EE0
player_data =
{
	{["offset"] = 0x070, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_height"},
	{["offset"] = 0x0DC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "current_health"},
	{["offset"] = 0x0E4, ["size"] = 0x4, ["type"] = "float", 	["name"] = "previous_health"},
	{["offset"] = 0x0F4, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "invincibility_frame_counter"},	
	{["offset"] = 0x118, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "look_ahead_flag"},
	{["offset"] = 0x124, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "aim_button_flag"},
	{["offset"] = 0x128, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "auto_aim_flag"},	
	{["offset"] = 0x148, ["size"] = 0x4, ["type"] = "float", 	["name"] = "azimuth_angle"},	
	{["offset"] = 0x14C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "azimuth_turning_direction"},
	{["offset"] = 0x150, ["size"] = 0x4, ["type"] = "float", 	["name"] = "azimuth_cosine"},
	{["offset"] = 0x154, ["size"] = 0x4, ["type"] = "float", 	["name"] = "azimuth_sine"},
	{["offset"] = 0x158, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_angle"},
	{["offset"] = 0x15C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_angle"},	
	{["offset"] = 0x160, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_turning_direction"},
	{["offset"] = 0x164, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_cosine"},
	{["offset"] = 0x168, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_sine"},
	{["offset"] = 0x16C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "strafe_speed_multiplier"},
	{["offset"] = 0x170, ["size"] = 0x4, ["type"] = "float", 	["name"] = "strafe_movement_direction"},
	{["offset"] = 0x174, ["size"] = 0x4, ["type"] = "float", 	["name"] = "forward_speed_multiplier"},
	{["offset"] = 0x178, ["size"] = 0x4, ["type"] = "float", 	["name"] = "forward_speed_multiplier_2"},	
	{["offset"] = 0x17C, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "forward_speed_frame_counter"},
	{["offset"] = 0x180, ["size"] = 0x4, ["type"] = "float", 	["name"] = "boost_factor_x"},
	{["offset"] = 0x188, ["size"] = 0x4, ["type"] = "float", 	["name"] = "boost_factor_z"},
	{["offset"] = 0x1C8, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "pause_animation_state"},
	{["offset"] = 0x1CC, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "paused_flag"},
	{["offset"] = 0x1DC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "pause_watch_position"},
	{["offset"] = 0x200, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "pausing_flag"},
	{["offset"] = 0x204, ["size"] = 0x4, ["type"] = "float", 	["name"] = "pause_starting_angle"},
	{["offset"] = 0x20C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "pause_target_angle"},
	{["offset"] = 0x224, ["size"] = 0x4, ["type"] = "float", 	["name"] = "pause_animation_counter"},
	{["offset"] = 0x48C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_x"},
	{["offset"] = 0x490, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_y"},
	{["offset"] = 0x494, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_z"},
	{["offset"] = 0x4B0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius"},
	{["offset"] = 0x520, ["size"] = 0x4, ["type"] = "float", 	["name"] = "speed_x"},
	{["offset"] = 0x524, ["size"] = 0x4, ["type"] = "float", 	["name"] = "speed_y"},
	{["offset"] = 0x528, ["size"] = 0x4, ["type"] = "float", 	["name"] = "speed_z"},
	{["offset"] = 0xA80, ["size"] = 0x4, ["type"] = "float", 	["name"] = "noise"}
}

local player_data_by_name = {}

for index, value in ipairs(player_data) do
	player_data_by_name[value.name] = value
end

function read_player_data_value(_name)
	local player_data_base = (mainmemory.read_u32_be(player_data_pointer) - 0x80000000)
	local metadata = player_data_by_name[_name]
	
	if (metadata.size == 1) then
		return mainmemory.read_u8(player_data_base + metadata.offset)
	elseif (metadata.size == 2) then
		return mainmemory.read_u16_be(player_data_base + metadata.offset)
	elseif (metadata.size == 4) then
		if (metadata.type == "float") then
			return mainmemory.readfloat(player_data_base + metadata.offset, true)
		else
			return mainmemory.read_u32_be(player_data_base + metadata.offset)
		end
	else
		error("invalid player data value size")
	end	
end