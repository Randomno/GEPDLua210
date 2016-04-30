Data = {}
Data.__index = Data
Data.__concat = function(_lhs, _rhs)
	local concat = Data.create()
	
	concat.type = _rhs.type
	concat.size = (_lhs.size + _rhs.size)
	concat.metadata = {}
	
	if _lhs.metadata then
		for index, metadata in ipairs(_lhs.metadata) do
			table.insert(concat.metadata, metadata)
		end
	end
	
	if _rhs.metadata then
		for index, metadata in ipairs(_rhs.metadata) do
			metadata.offset = (metadata.offset + _lhs.size)
		
			table.insert(concat.metadata, metadata)
		end
	end
	
	return concat
end

function Data.create()
	local data = {}
	
	setmetatable(data, Data)
	
	return data
end

function Data:get_metadata(_name)
	if not self.metadata_by_name then
		self.metadata_by_name = {}

		for index, metadata in ipairs(self.metadata) do
			self.metadata_by_name[metadata.name] = metadata
		end
	end

	return self.metadata_by_name[_name]
end

local function get_vector(_address, _metadata, _dimensions)
	if (_metadata.size ~= (_dimensions * 0x04)) then
		error("Invalid vector size")
	end
	
	local vector = {}

	for i = 1, _dimensions, 1 do
		local offset = (_metadata.offset + ((i - 1) * 0x04))
		
		table.insert(vector, mainmemory.readfloat((_address + offset), true))
	end
	
	return vector
end

function Data:get_value(_address, _name)
	local metadata = self:get_metadata(_name)
	
	if not metadata then
		return nil
	end
	
	if (metadata.size == 0x01) then
		return mainmemory.read_u8(_address + metadata.offset)
	elseif (metadata.size == 0x02) then
		return mainmemory.read_u16_be(_address + metadata.offset)
	elseif (metadata.size == 0x04) then
		if (metadata.type == "float") then
			return mainmemory.readfloat((_address + metadata.offset), true)
		else
			return mainmemory.read_u32_be(_address + metadata.offset)
		end
	else
		if (bizstring.startswith(metadata.type, "vector")) then		
			local dimensions = tonumber(string.sub(metadata.type, 7, 7))
		
			return get_vector(_address, metadata, dimensions)
		else	
			error("Invalid size value")
		end
	end
end