require "Data\\PD\\ObjectData"
require "Data\\PD\\ConditionData"

ObjectDataReader = {}
ObjectDataReader.__index = ObjectDataReader

function ObjectDataReader.create()
	local object_data_reader = {}
	
	setmetatable(object_data_reader, ObjectDataReader)
	
	object_data_reader.current_address = ObjectData.get_start_address()	
	object_data_reader.current_data = ObjectData.get_data(object_data_reader.current_address)
	
	return object_data_reader
end

function ObjectDataReader:clone()
	local clone = {}
	
	setmetatable(clone, ObjectDataReader)
	
	clone.current_address = self.current_address
	clone.current_data = self.current_data
	
	return clone
end

function ObjectDataReader:reached_end()
	return (not self.current_data and true or false)
end

function ObjectDataReader:next_object()
	if self:reached_end() then
		return
	end
	
	self.current_address = (self.current_address + self.current_data.size)
	
	-- Is this objective data?
	if (self.current_data.type == 0x17) then
		local condition_address = self.current_address
		local condition_data = ConditionData.get_data(condition_address)
		
		while condition_data do
			condition_address = (condition_address + condition_data.size)
			condition_data = ConditionData.get_data(condition_address)
		end
		
		self.current_address = (condition_address + 4)
	end
	
	self.current_data = ObjectData.get_data(self.current_address)
end

function ObjectDataReader:get_value(_name)
	return self.current_data:get_value(self.current_address, _name)
end

function ObjectDataReader.for_each(_function)
	local object_data_reader = ObjectDataReader.create()
	
	while not object_data_reader:reached_end() do
		_function(object_data_reader)
	
		object_data_reader:next_object()
	end
end