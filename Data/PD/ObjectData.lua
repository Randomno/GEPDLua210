require "Data\\Data"

DoorData = Data.create()

DoorData.type = 0x01
DoorData.size = 0x80
DoorData.metadata =
{
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_displacement_percentage"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "float", 	["name"] = "walkthrough_distance"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "acceleration"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "rate"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_speed"},	
	{["offset"] = 0x20, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "max_open_time"},
	{["offset"] = 0x28, ["size"] = 0x1, ["type"] = "enum", 		["name"] = "state"},
	{["offset"] = 0x64, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "opened_time"},
	{["offset"] = 0x6C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "timer"}
}

DoorScaleData = Data.create()

DoorScaleData.type = 0x02
DoorScaleData.size = 0x08
DoorScaleData.metadata = 
{
}

PhysicalObjectData = Data.create()

PhysicalObjectData.type = 0x03
PhysicalObjectData.size = 0x5C
PhysicalObjectData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x02, ["type"] = "hex", 		["name"] = "image"},
	{["offset"] = 0x06, ["size"] = 0x02, ["type"] = "hex", 		["name"] = "preset"},
	{["offset"] = 0x08, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_1"},
	{["offset"] = 0x0C, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_2"},
	{["offset"] = 0x10, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_3"},
	{["offset"] = 0x14, ["size"] = 0x04, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x1C, ["size"] = 0x24, ["type"] = "matrix", 	["name"] = "transform"},
	{["offset"] = 0x44, ["size"] = 0x04, ["type"] = "hex",		["name"] = "collision_data_pointer"},
	--{["offset"] = 0x48, ["size"] = 0x04, ["type"] = "hex",		["name"] = "motion_data_pointer"},
	{["offset"] = 0x4C, ["size"] = 0x02, ["type"] = "unsigned",	["name"] = "damage_received"},	
	{["offset"] = 0x4E, ["size"] = 0x02, ["type"] = "unsigned",	["name"] = "health"},	
	{["offset"] = 0x50, ["size"] = 0x04, ["type"] = "color",	["name"] = "color"}
}

KeyData = Data.create()

KeyData.type = 0x04
KeyData.size = 0x04
KeyData.metadata =
{
}

CameraData = Data.create()

CameraData.type = 0x06
CameraData.size = 0x68
CameraData.metadata =
{
}

AmmoClipData = Data.create()

AmmoClipData.type = 0x07
AmmoClipData.size = 0x04
AmmoClipData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "ammo_type"}
}

WeaponData = Data.create()

WeaponData.type = 0x08
WeaponData.size = 0x0C
WeaponData.metadata =
{
}

CharacterData = Data.create()

CharacterData.type = 0x09
CharacterData.size = 0x2C
CharacterData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "bitfield", 	["name"] = "flags"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "id"},
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "preset"},
	{["offset"] = 0x0C, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "body"},
	{["offset"] = 0x0D, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "head"},	
	{["offset"] = 0x0E, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block"},
	--{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "float", 	["name"] = "health"}
}

SingleScreenMonitorData = Data.create()

SingleScreenMonitorData.type = 0x0A
SingleScreenMonitorData.size = 0x78
SingleScreenMonitorData.metadata =
{
}

MultiScreenMonitorData = Data.create()

MultiScreenMonitorData.type = 0x0B
MultiScreenMonitorData.size = 0x1D4
MultiScreenMonitorData.metadata =
{
}

DroneData = Data.create()

DroneData.type = 0x0D
DroneData.size = 0x50
DroneData.metadata =
{
}

CollectibleLinkData = Data.create()

CollectibleLinkData.type = 0x0E
CollectibleLinkData.size = 0x08
CollectibleLinkData.metadata =
{
}

BreakableObjectData = Data.create()

BreakableObjectData.type = 0x0F
BreakableObjectData.size = 0x00
BreakableObjectData.metadata = nil

ObjectLinkData = Data.create()

ObjectLinkData.type = 0x13
ObjectLinkData.size = 0x14
ObjectLinkData.metadata =
{
}

ShieldData = Data.create()

ShieldData.type = 0x15
ShieldData.size = 0x0C
ShieldData.metadata =
{
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "amount"}
}

TagData = Data.create()

TagData.type = 0x16
TagData.size = 0x10
TagData.metadata =
{
}

ObjectiveData = Data.create()

ObjectiveData.type = 0x17
ObjectiveData.size = 0x10
ObjectiveData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "objective_number"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "text_preset"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "flags", 	["name"] = "difficulty_flags"}
}

HolographData = Data.create()

HolographData.type = 0x1E
HolographData.size = 0x10
HolographData.metadata =
{
}

BriefingData = Data.create()

BriefingData.type = 0x23
BriefingData.size = 0x10
BriefingData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "enum", 	["name"] = "briefing_type"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex",  	["name"] = "text_preset"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex",  	["name"] = "previous_entry_pointer"}
}

ItemInfoData = Data.create()

ItemInfoData.type = 0x25
ItemInfoData.size = 0x28
ItemInfoData.metadata = 
{
	{["offset"] = 0x08, ["size"] = 0x2, ["type"] = "hex",	["name"] = "item"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex",	["name"] = "inventory_text_preset"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "hex",	["name"] = "weapon_of_choice_text_preset"},
	{["offset"] = 0x20, ["size"] = 0x4, ["type"] = "hex",	["name"] = "interaction_text_preset"},
	{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "hex",	["name"] = "previous_entry_pointer"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "hex",	["name"] = "item_data_pointer"}
}

GlassData = Data.create()

GlassData.type = 0x2A
GlassData.size = 0x04
GlassData.metadata =
{
}

ViewpointData = Data.create()

ViewpointData.type = 0x2E
ViewpointData.size = 0x1C
ViewpointData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "offset"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "azimuth_angle"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_angle"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "preset"}
}

TintedGlassData = Data.create()

TintedGlassData.type = 0x2F
TintedGlassData.size = 0x0C
TintedGlassData.metadata = 
{
	{["offset"] = 0x00, ["size"] = 0x2, ["type"] = "unsigned", ["name"] = "opaque_distance"},
	{["offset"] = 0x02, ["size"] = 0x2, ["type"] = "unsigned", ["name"] = "transparent_distance"}
}

ElevatorData = Data.create()

ElevatorData.type = 0x30
ElevatorData.size = 0x38
ElevatorData.metadata = 
{
}

DestructibleLinkData = Data.create()

DestructibleLinkData.type = 0x31
DestructibleLinkData.size = 0x14
DestructibleLinkData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "destructible_object_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", ["name"] = "linked_object_pointer"}
}

ConditionalPathData = Data.create()

ConditionalPathData.type = 0x32
ConditionalPathData.size = 0x10
ConditionalPathData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "destructible_object_pointer"},
	{["offset"] = 0x08, ["size"] = 0x2, ["type"] = "hex", ["name"] = "source_preset"},
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "hex", ["name"] = "destination_preset"},
	--{["offset"] = 0x0C, ["size"] = 0x2, ["type"] = "hex", ["name"] = "previous_entry_pointer"} -- TODO: Confirm
}

HoverbikeData = Data.create()

HoverbikeData.type = 0x33
HoverbikeData.size = 0x84
HoverbikeData.metadata = 
{
}

HoveringObjectData = Data.create()

HoveringObjectData.type = 0x35
HoveringObjectData.size = 0x40
HoveringObjectData.metadata = 
{
}

RotatingObjectData = Data.create()

RotatingObjectData.type = 0x36
RotatingObjectData.size = 0x18
RotatingObjectData.metadata = 
{
}

HoveringVehicleData = Data.create()

HoveringVehicleData.type = 0x37
HoveringVehicleData.size = 0x3C
HoveringVehicleData.metadata = 
{
}

EffectData = Data.create()

EffectData.type = 0x38
EffectData.size = 0x0C
EffectData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "type"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", ["name"] = "preset"},
}

ArmedVehicleData = Data.create()

ArmedVehicleData.type = 0x39
ArmedVehicleData.size = 0x8C
ArmedVehicleData.metadata =
{
}

EscalatorData = Data.create()

EscalatorData.type = 0x3B
EscalatorData.size = 0x10
EscalatorData.metadata =
{
}

-- Append data common for all physical objects
DoorData = 					PhysicalObjectData .. DoorData
KeyData = 					PhysicalObjectData .. KeyData
CameraData = 				PhysicalObjectData .. CameraData
AmmoClipData = 				PhysicalObjectData .. AmmoClipData
WeaponData = 				PhysicalObjectData .. WeaponData
SingleScreenMonitorData = 	PhysicalObjectData .. SingleScreenMonitorData
MultiScreenMonitorData = 	PhysicalObjectData .. MultiScreenMonitorData
DroneData = 				PhysicalObjectData .. DroneData
BreakableObjectData =		PhysicalObjectData .. BreakableObjectData
ShieldData = 				PhysicalObjectData .. ShieldData
GlassData = 				PhysicalObjectData .. GlassData
TintedGlassData = 			PhysicalObjectData .. TintedGlassData
ElevatorData =				PhysicalObjectData .. ElevatorData
HoverbikeData =				PhysicalObjectData .. HoverbikeData
HoveringObjectData =		PhysicalObjectData .. HoveringObjectData
RotatingObjectData =		PhysicalObjectData .. RotatingObjectData
HoveringVehicleData =		PhysicalObjectData .. HoveringVehicleData
ArmedVehicleData =			PhysicalObjectData .. ArmedVehicleData
EscalatorData =				PhysicalObjectData .. EscalatorData

ObjectData = {}

ObjectData.start_pointer_address = 0x09D040
ObjectData.data_types =
{
	[0x01] = DoorData,
	[0x02] = DoorScaleData,
	[0x03] = PhysicalObjectData,
	[0x04] = KeyData,
	[0x06] = CameraData,
	[0x07] = AmmoClipData,
	[0x08] = WeaponData,
	[0x09] = CharacterData,
	[0x0A] = SingleScreenMonitorData,
	[0x0B] = MultiScreenMonitorData,
	[0x0D] = DroneData,
	[0x0E] = CollectibleLinkData,
	[0x0F] = BreakableObjectData,
	[0x13] = ObjectLinkData,
	[0x15] = ShieldData,
	[0x16] = TagData,
	[0x17] = ObjectiveData,
	[0x1E] = HolographData,
	[0x23] = BriefingData,
	[0x25] = ItemInfoData,
	[0x2A] = GlassData,
	[0x2E] = ViewpointData,
	[0x2F] = TintedGlassData,
	[0x30] = ElevatorData,
	[0x31] = DestructibleLinkData,
	[0x32] = ConditionalPathData,
	[0x33] = HoverbikeData,
	[0x35] = HoveringObjectData,
	[0x36] = RotatingObjectData,
	[0x37] = HoveringVehicleData,
	[0x38] = EffectData,
	[0x39] = ArmedVehicleData,
	[0x3B] = EscalatorData
}

function ObjectData.get_start_address()	
	return (mainmemory.read_u32_be(ObjectData.start_pointer_address) - 0x80000000)
end

function ObjectData.get_type(_object_address)
	return mainmemory.read_u8(_object_address + 0x03)
end

function ObjectData.get_data(_object_address)
	local object_type = ObjectData.get_type(_object_address)
	
	return ObjectData.data_types[object_type]
end