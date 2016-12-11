require "Data\\Data"

PolygonData = Data.create()

PolygonData.size = 0x40
PolygonData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x2, ["type"] = "bitfield",  ["name"] = "flags"},
	{["offset"] = 0x06, ["size"] = 0x1, ["type"] = "unsigned",  ["name"] = "min_x_index"},
	{["offset"] = 0x07, ["size"] = 0x1, ["type"] = "unsigned",  ["name"] = "min_y_index"},
	{["offset"] = 0x08, ["size"] = 0x1, ["type"] = "unsigned",  ["name"] = "min_z_index"},
	{["offset"] = 0x09, ["size"] = 0x1, ["type"] = "unsigned",  ["name"] = "max_x_index"},
	{["offset"] = 0x0A, ["size"] = 0x1, ["type"] = "unsigned",  ["name"] = "max_y_index"},
	{["offset"] = 0x0B, ["size"] = 0x1, ["type"] = "unsigned",  ["name"] = "max_z_index"},
	{["offset"] = 0x10, ["size"] = 0xC, ["type"] = "vector",  	["name"] = "vertex_1"},
	{["offset"] = 0x1C, ["size"] = 0xC, ["type"] = "vector",  	["name"] = "vertex_2"},
	{["offset"] = 0x28, ["size"] = 0xC, ["type"] = "vector",  	["name"] = "vertex_3"},
	{["offset"] = 0x34, ["size"] = 0xC, ["type"] = "vector",  	["name"] = "vertex_4"}
}

PrismData = Data.create()

PrismData.size = 0x48
PrismData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x04, ["type"] = "float", 	["name"] = "top"},
	{["offset"] = 0x08, ["size"] = 0x04, ["type"] = "float", 	["name"] = "bottom"},
	{["offset"] = 0x0C, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_1"},	
	{["offset"] = 0x14, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_2"},
	{["offset"] = 0x1C, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_3"},
	{["offset"] = 0x24, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_4"},
	{["offset"] = 0x2C, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_5"},
	{["offset"] = 0x34, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_6"},
	{["offset"] = 0x3C, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_7"},
	{["offset"] = 0x44, ["size"] = 0x08, ["type"] = "vector",  	["name"] = "vertex_8"}
}

CylinderData = Data.create()

CylinderData.size = 0x18
CylinderData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x04, ["type"] = "float", 	["name"] = "top"},
	{["offset"] = 0x08, ["size"] = 0x04, ["type"] = "float", 	["name"] = "bottom"},
	{["offset"] = 0x0C, ["size"] = 0x08, ["type"] = "vector",	["name"] = "center"},
	{["offset"] = 0x14, ["size"] = 0x04, ["type"] = "float",	["name"] = "radius"}	
}

CollisionData = {}

CollisionData.data_types =
{
	[0x1] = PolygonData,
	[0x2] = PrismData,
	[0x3] = CylinderData
}

function CollisionData.get_type(_address)
	return mainmemory.read_u8(_address)
end

function CollisionData.get_vertex_count(_address)
	return mainmemory.read_u8(_address + 0x01)
end

function CollisionData.get_data(_address)
	local collision_type = CollisionData.get_type(_address)
	
	return CollisionData.data_types[collision_type]
end