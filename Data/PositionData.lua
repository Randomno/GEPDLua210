PositionData = {}

PositionData.size = 0x34
PositionData.metadata = 
{
	{["offset"] = 0x00, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "object_type"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "object_data_pointer"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_x"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_y"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_z"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "room_pointer"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "float", 	["name"] = "rotation"},
	{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "prev_entry_pointer"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "next_entry_pointer"}
	--{["offset"] = 0x2C, ["size"] = 0x8, ["type"] = "hex", 		["name"] = "room_list"},
}

local metadata_by_name = {}

for index, metadata in ipairs(PositionData.metadata) do
	metadata_by_name[metadata.name] = metadata
end

function PositionData.get_value(_position_data_address, _name)
	local metadata = metadata_by_name[_name]

	if metadata.size == 1 then
		return mainmemory.read_u8(_position_data_address + metadata.offset)
	elseif metadata.size == 2 then
		return mainmemory.read_u16_be(_position_data_address + metadata.offset)
	elseif metadata.size == 4 then
		if metadata.type == "float" then
			return mainmemory.readfloat(_position_data_address + metadata.offset, true)
		else
			return mainmemory.read_u32_be(_position_data_address + metadata.offset)
		end
	else
		error("Invalid value size")
	end	
end