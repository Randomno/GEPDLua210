position_data_size = 0x34
position_data =
{
	{["offset"] = 0x00, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "object_type"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "object_data_pointer"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_x"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_y"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_z"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "room_pointer"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "float", 	["name"] = "rotation"},
	{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "prev_entry_pointer"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "next_entry_pointer"},
	--{["offset"] = 0x2C, ["size"] = 0x8, ["type"] = "hex", 		["name"] = "room_list"},
}

local position_data_by_name = {}

for index, value in ipairs(position_data) do
	position_data_by_name[value.name] = value
end

function read_position_data_value(_base_address, _name)
	local metadata = position_data_by_name[_name]

	if metadata.size == 1 then
		return mainmemory.read_u8(_base_address + metadata.offset)
	elseif metadata.size == 2 then
		return mainmemory.read_u16_be(_base_address + metadata.offset)
	elseif metadata.size == 4 then
		if metadata.type == "float" then
			return mainmemory.readfloat(_base_address + metadata.offset, true)
		else
			return mainmemory.read_u32_be(_base_address + metadata.offset)
		end
	else
		error("invalid position value size")
	end	
end