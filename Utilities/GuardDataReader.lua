require "Data\\GuardData"
require "Data\\PositionData"

GuardDataReader = {}
GuardDataReader.__index = GuardDataReader

function GuardDataReader.create(_slot)
	local guard_data_reader = {}
	
   setmetatable(guard_data_reader, GuardDataReader)
   
   _slot = (_slot or 1)
   
   local slot_address = GuardData.get_slot_address(_slot)
   
   guard_data_reader.slot = _slot
   guard_data_reader.slot_address = slot_address
   guard_data_reader.is_empty = (not slot_address or GuardData.is_empty(slot_address))
   
   return guard_data_reader
end

function GuardDataReader:next_slot()
	local slot_address = GuardData.get_slot_address(self.slot + 1)

	if not slot_address then
		return false
	end
	
	self.slot = (self.slot + 1)
	self.slot_address = slot_address
	self.is_empty = GuardData.is_empty(slot_address)
	
	return true
end

function GuardDataReader:next_non_empty_slot()
	while self:next_slot() do
		if not self.is_empty then
			return true
		end
	end
	
	return false
end

function GuardDataReader:is_empty()
	return self.is_empty
end

function GuardDataReader:get_value(_name)
	return GuardData:get_value(self.slot_address, _name)
end

function GuardDataReader:get_position()
	local position_data_address = (self:get_value("position_data_pointer") - 0x80000000)
	
	return PositionData:get_value(position_data_address, "position")
end

local function get_path_prefix(_is_path)
	return (_is_path and "path_" or "")
end

function GuardDataReader:get_segment_info(_is_path)
	local path_prefix = get_path_prefix(_is_path)
	local segment_info = {}	
	
	segment_info.coverage = self:get_value(path_prefix .. "segment_coverage")
	segment_info.length = self:get_value(path_prefix .. "segment_length")
	
	return segment_info
end

function GuardDataReader:get_target_position(_is_path)
	local path_prefix = get_path_prefix(_is_path)
	
	return self:get_value(path_prefix .. "target_position")
end