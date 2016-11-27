require "Data\\Data"

local DestroyObjectData = Data.create()

DestroyObjectData.type = 0x19
DestroyObjectData.size = 0x08
DestroyObjectData.metadata = 
{
}

local TruifyFlagsData = Data.create()

TruifyFlagsData.type = 0x1A
TruifyFlagsData.size = 0x08
TruifyFlagsData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "flags", ["name"] = "flags"}
}

local FalsifyFlagsData = Data.create()

FalsifyFlagsData.type = 0x1B
FalsifyFlagsData.size = 0x08
FalsifyFlagsData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "flags", ["name"] = "flags"}
}

local CollectObjectData = Data.create()

CollectObjectData.type = 0x1C
CollectObjectData.size = 0x08
CollectObjectData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "object_tag"}
}

local DiscardObjectData = Data.create()

DiscardObjectData.type = 0x1D
DiscardObjectData.size = 0x08
DiscardObjectData.metadata = 
{
}

local HolographObjectData = Data.create()

HolographObjectData.type = 0x1E
HolographObjectData.size = 0x10
HolographObjectData.metadata = 
{
}

local EnterRoomData = Data.create()

EnterRoomData.type = 0x20
EnterRoomData.size = 0x10
EnterRoomData.metadata = 
{
}

local DepositObjectData = Data.create()

DepositObjectData.type = 0x21
DepositObjectData.size = 0x14
DepositObjectData.metadata = 
{
}

ConditionData = {}

ConditionData.data_types =
{
	[0x19] = DestroyObjectData,
	[0x1A] = TruifyFlagsData,
	[0x1B] = FalsifyFlagsData,
	[0x1C] = CollectObjectData,
	[0x1D] = DiscardObjectData,
	[0x1E] = HolographObjectData,
	[0x20] = EnterRoomData,
	[0x21] = DepositObjectData
}

function ConditionData.get_type(_condition_address)
	return mainmemory.read_u32_be(_condition_address)
end

function ConditionData.get_data(_condition_address)
	local condition_type = ConditionData.get_type(_condition_address)

	return ConditionData.data_types[condition_type]
end