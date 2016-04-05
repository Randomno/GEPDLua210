require "GuardData"
require "PositionData"

GuardDataReader = {}
GuardDataReader.__index = GuardDataReader

function GuardDataReader.create(_slot)
	local guard_data_reader = {}
	
   setmetatable(guard_data_reader, GuardDataReader)
   
   guard_data_reader.base_address = get_base_address(_slot)
   
   return guard_data_reader
end

function GuardDataReader:get_value(_name)
	return read_guard_data_value(self.base_address, _name)
end

function GuardDataReader:get_position()
	local position_data_pointer = (self:get_value("position_data_pointer") - 0x80000000)
	
	local position_x = read_position_data_value(position_data_pointer, "position_x")
	local position_y = read_position_data_value(position_data_pointer, "position_y")
	local position_z = read_position_data_value(position_data_pointer, "position_z")
	
	return {["x"] = position_x, ["y"] = position_y, ["z"] = position_z}
end

function get_prefix(_is_path)
	return (_is_path and "path_" or "")
end

function GuardDataReader:get_segment_info(_is_path)
	local prefix = get_prefix(_is_path)
	local segment_info = {}	
	
	segment_info.coverage = self:get_value(prefix .. "segment_coverage")
	segment_info.length = self:get_value(prefix .. "segment_length")
	
	return segment_info
end

function GuardDataReader:get_target_position(_is_path)
	local prefix = get_prefix(_is_path)

	local target_position_x = self:get_value(prefix .. "target_position_x")
	local target_position_y = self:get_value(prefix .. "target_position_y")
	local target_position_z = self:get_value(prefix .. "target_position_z")
	
	return {["x"] = target_position_x, ["y"] = target_position_y, ["z"] = target_position_z}
end