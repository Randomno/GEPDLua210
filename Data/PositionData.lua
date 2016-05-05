require "Data\\Data"

PositionData = Data.create()

PositionData.size = 0x34
PositionData.metadata = 
{
	{["offset"] = 0x00, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "object_type"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "object_data_pointer"},
	{["offset"] = 0x08, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "position"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "room_pointer"},
	{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "prev_entry_pointer"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "next_entry_pointer"}
	--{["offset"] = 0x2C, ["size"] = 0x8, ["type"] = "hex", 		["name"] = "room_list"},
}