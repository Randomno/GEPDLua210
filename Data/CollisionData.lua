require "Data\\Data"

CollisionData = Data.create()

CollisionData.size = 0x60
CollisionData.metadata =
{
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "point_count"},	
	{["offset"] = 0x04, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_1"},
	{["offset"] = 0x0C, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_2"},
	{["offset"] = 0x14, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_3"},
	{["offset"] = 0x1C, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_4"},
	{["offset"] = 0x24, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_5"},
	{["offset"] = 0x2C, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_6"},
	{["offset"] = 0x34, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_7"}, -- TODO: Confirm
	{["offset"] = 0x3C, ["size"] = 0x8, ["type"] = "vector2", 	["name"] = "point_8"}, -- TODO: Confirm
	{["offset"] = 0x44, ["size"] = 0x4, ["type"] = "float", 	["name"] = "y_max"},	
	{["offset"] = 0x48, ["size"] = 0x4, ["type"] = "float", 	["name"] = "y_min"}	
}