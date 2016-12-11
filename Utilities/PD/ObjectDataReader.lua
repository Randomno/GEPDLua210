require "Data\\PD\\ObjectData"
require "Data\\PD\\ConditionData"
require "Data\\PD\\CollisionData"
require "Data\\PD\\PositionData"

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

function ObjectDataReader:has_value(_name)
	return self.current_data:has_value(_name)
end

function ObjectDataReader:get_value(_name)
	return self.current_data:get_value(self.current_address, _name)
end

function ObjectDataReader:check_bits(_name, _mask)
	return self.current_data:check_bits(self.current_address, _name, _mask)
end

function ObjectDataReader:is_collidable()
	if not self:has_value("flags_1") or not self:check_bits("flags_1", 0x00000100) then
		return false
	end
	
	local position_data_address = self:get_value("position_data_pointer")
	local collision_data_address = self:get_value("collision_data_pointer")
	
	if ((position_data_address == 0x00000000) or	
		(collision_data_address == 0x00000000)) then
		return false
	end

	return (CollisionData.get_data(collision_data_address - 0x80000000) ~= nil)
end

function ObjectDataReader:get_bounding_type()
	local collision_data_address = (self:get_value("collision_data_pointer") - 0x80000000)	
	
	return CollisionData.get_type(collision_data_address)
end

function ObjectDataReader:get_bounding_volume()
	local collision_address = (self:get_value("collision_data_pointer") - 0x80000000)
	local collision_type = CollisionData.get_type(collision_address)
	local collision_data = CollisionData.get_data(collision_address)
	
	local bounding_volume = {}
	
	bounding_volume.type = collision_type
	
	-- Polygon or Prism?
	if ((collision_type == 0x1) or (collision_type == 0x2)) then	
		local vertices = {}		
		local count = CollisionData.get_vertex_count(collision_address)
		
		for i = 1, count, 1 do
			vertices[i] = collision_data:get_value(collision_address, "vertex_" .. i)
		end
		
		bounding_volume.vertices = vertices
	end
	
	-- Prism or Cylinder?
	if ((collision_type == 0x2) or (collision_type == 3)) then
		bounding_volume.top = collision_data:get_value(collision_address, "top")
		bounding_volume.bottom = collision_data:get_value(collision_address, "bottom")
	end
	
	-- Cylinder?
	if (collision_type == 0x3) then
		bounding_volume.center = collision_data:get_value(collision_address, "center")
		bounding_volume.radius = collision_data:get_value(collision_address, "radius")
	end
	
	return bounding_volume
end

function ObjectDataReader:get_position()
	local position_data_address = (self:get_value("position_data_pointer") - 0x80000000)
	
	return PositionData:get_value(position_data_address, "position")
end

function ObjectDataReader.for_each(_function)
	local object_data_reader = ObjectDataReader.create()
	
	while not object_data_reader:reached_end() do
		_function(object_data_reader)
	
		object_data_reader:next_object()
	end
end