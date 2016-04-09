GuardData = {}

GuardData.start_address_pointer = 0x02CC64
GuardData.capacity_address = 0x2CC68
GuardData.slot_size = 0x1DC
GuardData.metadata =
{
	{["offset"] = 0x001, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "id"},
	{["offset"] = 0x004, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "rounds_fired_left"},
	{["offset"] = 0x005, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "rounds_fired_right"},
	{["offset"] = 0x006, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "head_model"},
	{["offset"] = 0x007, ["size"] = 0x1, ["type"] = "enum", 	["name"] = "current_action"},
	{["offset"] = 0x00A, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_near"},
	{["offset"] = 0x00B, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_hit"},
	{["offset"] = 0x00F, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "body_model"},
	{["offset"] = 0x010, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "belligerency"},
	{["offset"] = 0x018, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x01C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "model_data_pointer"},	
	{["offset"] = 0x024, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius"},
	{["offset"] = 0x028, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius_2"},	
	{["offset"] = 0x02C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "bond_x"},
	{["offset"] = 0x030, ["size"] = 0x4, ["type"] = "float", 	["name"] = "bond_y"},
	{["offset"] = 0x034, ["size"] = 0x4, ["type"] = "float", 	["name"] = "bond_z"},
	{["offset"] = 0x03C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_target_position_x"},
	{["offset"] = 0x040, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_target_position_y"},
	{["offset"] = 0x044, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_target_position_z"},	
	{["offset"] = 0x060, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_position_x"},
	{["offset"] = 0x064, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_position_y"},
	{["offset"] = 0x068, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_position_z"},	
	{["offset"] = 0x070, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_coverage"},
	{["offset"] = 0x074, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_length"},	
	--{["offset"] = 0x088, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_position_x_copy"},
	--{["offset"] = 0x08C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_position_y_copy"},
	--{["offset"] = 0x090, ["size"] = 0x4, ["type"] = "float", 	["name"] = "target_position_z_copy"},	
	{["offset"] = 0x094, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_coverage"},
	{["offset"] = 0x098, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_length"},
	{["offset"] = 0x0AC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "clipping_height"},
	{["offset"] = 0x0BC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_x"},
	{["offset"] = 0x0C0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_y"},
	{["offset"] = 0x0C4, ["size"] = 0x4, ["type"] = "float", 	["name"] = "position_z"},
	{["offset"] = 0x0D0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "reaction_time"},	
	{["offset"] = 0x0D4, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "last_bond_detection_time"},		
	{["offset"] = 0x0EC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "hearing_ability"},	
	{["offset"] = 0x0FC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "damage_received"},
	{["offset"] = 0x100, ["size"] = 0x4, ["type"] = "float", 	["name"] = "health"},
	{["offset"] = 0x104, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "action_block_pointer"},
	{["offset"] = 0x108, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_offset"},
	{["offset"] = 0x10A, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_return"},
	{["offset"] = 0x10C, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "user_byte_1"},
	{["offset"] = 0x10D, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "user_byte_2"},
	{["offset"] = 0x10F, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "random_value"},
	{["offset"] = 0x110, ["size"] = 0x1, ["type"] = "unsigned",	["name"] = "timer"},
	{["offset"] = 0x114, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "2328_preset"}
}

local metadata_by_name = {}

for index, metadata in ipairs(GuardData.metadata) do
	metadata_by_name[metadata.name] = metadata
end

function GuardData.get_capacity()
	return mainmemory.read_u32_be(GuardData.capacity_address)
end

function GuardData.get_slot_address(_slot)
	_slot = (_slot or 1)
	
	if (_slot > GuardData.get_capacity()) then
		return nil
	end

	local start_address = mainmemory.read_u32_be(GuardData.start_address_pointer)
	
	if (start_address == 0x00000000) then
		return nil
	end
	
	start_address = (start_address - 0x80000000)

	return (start_address + ((_slot - 1) * GuardData.slot_size))
end

function GuardData.get_metadata(_name)
	return metadata_by_name[_name]
end

function GuardData.get_value(_slot_address, _name)
	local metadata = GuardData.get_metadata(_name)

	if metadata.size == 1 then
		return mainmemory.read_u8(_slot_address + metadata.offset)
	elseif metadata.size == 2 then
		return mainmemory.read_u16_be(_slot_address + metadata.offset)
	elseif metadata.size == 4 then
		if metadata.type == "float" then
			return mainmemory.readfloat(_slot_address + metadata.offset, true)
		else
			return mainmemory.read_u32_be(_slot_address + metadata.offset)
		end
	else
		error("Invalid value size")
	end	
end

function GuardData.is_empty(_slot_address)
	local metadata = GuardData.get_metadata("model_data_pointer")

	return (mainmemory.read_u8(_slot_address + metadata.offset) == 0x00)
end