require "Data\\ObjectData"
require "Data\\ConditionData"
require "Data\\CollisionData"

ObjectDataReader = {}
ObjectDataReader.__index = ObjectDataReader

function ObjectDataReader.create()
	local object_data_reader = {}
	
	setmetatable(object_data_reader, ObjectDataReader)
	
	object_data_reader.current_address = ObjectData.get_start_address()
	object_data_reader.current_data = ObjectData.get_data(object_data_reader.current_address)
	
	return object_data_reader
end

function ObjectDataReader:reached_end()
	return (not self.current_data and true or false)
end

function ObjectDataReader:next_object()	
	if (self.current_data.type == 0x17) then
		local condition_address = (self.current_address + self.current_data:get_metadata("condition_list").offset)
		local condition_data = ConditionData.get_data(condition_address)
		
		while condition_data do
			condition_address = (condition_address + condition_data.size)
			condition_data = ConditionData.get_data(condition_address)
		end
		
		self.current_address = (condition_address + 4)
	else
		self.current_address = (self.current_address + self.current_data.size)
	end
	
	self.current_data = ObjectData.get_data(self.current_address)

	return not self:reached_end()
end

function ObjectDataReader:get_value(_name)
	return self.current_data:get_value(self.current_address, _name)
end

-- TODO: Fix
function ObjectDataReader:check_flag(_name)
	local flags = self:get_value("flags_1")

	return flags and bit.check(flags, 8) or false
end

function ObjectDataReader:get_collision_data()
	local collision_data_address = (self:get_value("collision_data_pointer") - 0x80000000)
	
	local points = {}
	local count = CollisionData:get_value(collision_data_address, "point_count")
	
	for i = 1, count, 1 do
		local point = CollisionData:get_value(collision_data_address, "point_" .. i)
		
		table.insert(points, {["x"] = point[1], ["z"] = point[2]})
	end
	
	local y_min = CollisionData:get_value(collision_data_address, "y_min")
	local y_max = CollisionData:get_value(collision_data_address, "y_max")
	
	return points, y_min, y_max
end