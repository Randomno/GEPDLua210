require "Data\\Data"

PlayerData = Data.create()

PlayerData.start_pointer_address = 0x079EE0
PlayerData.metadata = 
{
	{["offset"] = 0x074, ["size"] = 0x4, ["type"] = "float", 	["name"] = "clipping_height"},
	{["offset"] = 0x0A0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "ducking_height_offset"},
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
	{["offset"] = 0x48C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "position"},
	{["offset"] = 0x4B0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius"},
	{["offset"] = 0x4FC, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "scaled_speed"},
	{["offset"] = 0x520, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "speed"},
	{["offset"] = 0x550, ["size"] = 0x4, ["type"] = "float",	["name"] = "stationary_ground_offset"},
	{["offset"] = 0xA80, ["size"] = 0x4, ["type"] = "float", 	["name"] = "noise"}
}

function PlayerData.get_start_address()
	return (mainmemory.read_u32_be(PlayerData.start_pointer_address) - 0x80000000)
end

function PlayerData.get_value(_name)
	local start_address = PlayerData.get_start_address()
	
	return PlayerData.__index.get_value(PlayerData, start_address, _name)
end
