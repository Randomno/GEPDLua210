require "Data\\Data"

GuardData = Data.create()

GuardData.start_pointer_address = 0x062988
GuardData.capacity_address = 0x06298C
GuardData.size = 0x368
GuardData.metadata =
{
	{["offset"] = 0x000, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "id"},
	{["offset"] = 0x006, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "head_model"},
	{["offset"] = 0x007, ["size"] = 0x1, ["type"] = "enum", 	["name"] = "current_action"},
	{["offset"] = 0x00A, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_near"},
	{["offset"] = 0x00B, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_hit"},
	{["offset"] = 0x00C, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "alpha"},	
	{["offset"] = 0x010, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "body_model"},
	{["offset"] = 0x01C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x020, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "model_data_pointer"},	
	{["offset"] = 0x024, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius"},	
	{["offset"] = 0x028, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_height"},		
	{["offset"] = 0x02C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "joanna_position"},
	{["offset"] = 0x03C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "path_target_position"},
	{["offset"] = 0x06C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "target_position"},
	{["offset"] = 0x070, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_coverage"},
	{["offset"] = 0x074, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_length"},
	{["offset"] = 0x0A0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_coverage"},
	{["offset"] = 0x0A4, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_length"},
	{["offset"] = 0x0B8, ["size"] = 0x4, ["type"] = "float", 	["name"] = "feet_height_x10"},
	{["offset"] = 0x0B8, ["size"] = 0x4, ["type"] = "float", 	["name"] = "feet_height"},	
	{["offset"] = 0x0B8, ["size"] = 0x4, ["type"] = "float", 	["name"] = "clipping_height"},
	{["offset"] = 0x0C8, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "position"},
	{["offset"] = 0x100, ["size"] = 0x4, ["type"] = "float", 	["name"] = "damage_received"},
	{["offset"] = 0x104, ["size"] = 0x4, ["type"] = "float", 	["name"] = "health"},
	{["offset"] = 0x108, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "action_block_pointer"},
	{["offset"] = 0x10C, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_offset"},
	{["offset"] = 0x10E, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_return"},
	{["offset"] = 0x110, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_subroutine"},
	{["offset"] = 0x120, ["size"] = 0x4, ["type"] = "unsigned",	["name"] = "timer"},
	{["offset"] = 0x124, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "random_value"},
	{["offset"] = 0x170, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "right_weapon_position_data_pointer"},
}

function GuardData.get_capacity()
	return mainmemory.read_u32_be(GuardData.capacity_address)
end

function GuardData.get_start_address()
	return (mainmemory.read_u32_be(GuardData.start_pointer_address) - 0x80000000)
end

function GuardData.is_empty(_slot_address)
	return (mainmemory.read_u32_be(_slot_address + 0x20) == 0x00000000)	
end

function GuardData.is_clone(_slot_address)
	return false -- TODO
end