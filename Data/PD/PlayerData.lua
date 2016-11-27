require "Data\\Data"

PlayerData = Data.create()

PlayerData.start_pointer_address = 0x09A024
PlayerData.metadata = 
{
	{["offset"] = 0x0078, ["size"] = 0x4, ["type"] = "float", 		["name"] = "clipping_height"},
	{["offset"] = 0x00BC, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x0144, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_angle"},	
	{["offset"] = 0x0148, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_turning_direction"},
	{["offset"] = 0x014C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_cosine"},
	{["offset"] = 0x0150, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_sine"},
	{["offset"] = 0x0154, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_angle"},
	{["offset"] = 0x0158, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_angle"},	
	{["offset"] = 0x015C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_turning_direction"},
	{["offset"] = 0x0160, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_cosine"},
	{["offset"] = 0x0164, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_sine"},
	{["offset"] = 0x0310, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "position"},
	{["offset"] = 0x0378, ["size"] = 0x4, ["type"] = "float", 		["name"] = "collision_radius"},
	{["offset"] = 0x03C0, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "scaled_velocity"},
	{["offset"] = 0x03E4, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "velocity"}
}

function PlayerData.get_start_address()
	return (mainmemory.read_u32_be(PlayerData.start_pointer_address) - 0x80000000)
end

function PlayerData.get_value(_name)
	local start_address = PlayerData.get_start_address()
	
	return PlayerData.__index.get_value(PlayerData, start_address, _name)
end
