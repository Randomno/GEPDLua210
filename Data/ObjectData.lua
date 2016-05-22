require "Data\\Data"

DoorData = Data.create()

DoorData.type = 0x01
DoorData.size = 0x80
DoorData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_displacement_percentage"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "walkthrough_distance"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "acceleration"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "rate"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_speed"},
	{["offset"] = 0x1C, ["size"] = 0x4, ["type"] = "bitfield", 	["name"] = "lock"},
	{["offset"] = 0x20, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "max_open_time"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_displacement"},
	{["offset"] = 0x34, ["size"] = 0x4, ["type"] = "float", 	["name"] = "displacement_percentage"},
	{["offset"] = 0x38, ["size"] = 0x4, ["type"] = "float", 	["name"] = "speed_percentage"},
	{["offset"] = 0x3C, ["size"] = 0x1, ["type"] = "enum", 		["name"] = "state"},
	{["offset"] = 0x6C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "opened_time"},
	{["offset"] = 0x7C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "timer"}
}

DoorThicknessData = Data.create()

DoorThicknessData.type = 0x02
DoorThicknessData.size = 0x08
DoorThicknessData.metadata = 
{
}

PhysicalObjectData = Data.create()

PhysicalObjectData.type = 0x03
PhysicalObjectData.size = 0x80
PhysicalObjectData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x02, ["type"] = "hex", 		["name"] = "image"},
	{["offset"] = 0x06, ["size"] = 0x02, ["type"] = "hex", 		["name"] = "preset"},
	{["offset"] = 0x08, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_1"},
	{["offset"] = 0x0C, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_2"},
	{["offset"] = 0x10, ["size"] = 0x04, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x18, ["size"] = 0x40, ["type"] = "matrix", 	["name"] = "transform"},
	{["offset"] = 0x58, ["size"] = 0x10, ["type"] = "vector",	["name"] = "position"},
	{["offset"] = 0x68, ["size"] = 0x04, ["type"] = "hex",		["name"] = "collision_data_pointer"},
	{["offset"] = 0x70, ["size"] = 0x04, ["type"] = "float",	["name"] = "damage_received"},
	{["offset"] = 0x74, ["size"] = 0x04, ["type"] = "float",	["name"] = "health"},
	{["offset"] = 0x78, ["size"] = 0x04, ["type"] = "color",	["name"] = "current_color"},
	{["offset"] = 0x7C, ["size"] = 0x04, ["type"] = "color",	["name"] = "target_color"}
}

KeyData = Data.create()

KeyData.type = 0x04
KeyData.size = 0x04
KeyData.metadata =
{
}

AlarmData = Data.create()

AlarmData.type = 0x05
AlarmData.size = 0x00
AlarmData.metadata = nil

CameraData = Data.create()

CameraData.type = 0x06
CameraData.size = 0x6C
CameraData.metadata =
{
}

AmmoClipData = Data.create()

AmmoClipData.type = 0x07
AmmoClipData.size = 0x04
AmmoClipData.metadata =
{
}

WeaponData = Data.create()

WeaponData.type = 0x08
WeaponData.size = 0x08
WeaponData.metadata =
{
}

CharacterData = Data.create()

CharacterData.type = 0x09
CharacterData.size = 0x1C
CharacterData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "id"},
	{["offset"] = 0x06, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "preset"},
	{["offset"] = 0x08, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "body"},
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "action_block"},
	{["offset"] = 0x0C, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "default_2328_preset"},	
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "guard_data_pointer"}	
}

SingleScreenMonitorData = Data.create()

SingleScreenMonitorData.type = 0x0A
SingleScreenMonitorData.size = 0x80
SingleScreenMonitorData.metadata =
{
}

MultiScreenMonitorData = Data.create()

MultiScreenMonitorData.type = 0x0B
MultiScreenMonitorData.size = 0x1D4
MultiScreenMonitorData.metadata =
{
}

CeilingMonitorsData = Data.create()

CeilingMonitorsData.type = 0x0C
CeilingMonitorsData.size = 0x00
CeilingMonitorsData.metadata = nil

DroneData = Data.create()

DroneData.type = 0x0D
DroneData.size = 0x58
DroneData.metadata =
{
}

CollectibleLinkData = Data.create()

CollectibleLinkData.type = 0x0E
CollectibleLinkData.size = 0x0C
CollectibleLinkData.metadata =
{
}

HatData = Data.create()

HatData.type = 0x11
HatData.size = 0x00
HatData.metadata = nil

GrenadeProbabilityData = Data.create()

GrenadeProbabilityData.type = 0x12
GrenadeProbabilityData.size = 0x0C
GrenadeProbabilityData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "id"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "probability"}
}

ObjectLinkData = Data.create()

ObjectLinkData.type = 0x13
ObjectLinkData.size = 0x10
ObjectLinkData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "position_data_pointer_1"},	
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "position_data_pointer_2"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "previous_entry_pointer"}
}

AmmoBoxData = Data.create()

AmmoBoxData.type = 0x14
AmmoBoxData.size = 0x34
AmmoBoxData.metadata =
{
}

BodyArmorData = Data.create()

BodyArmorData.type = 0x15
BodyArmorData.size = 0x08
BodyArmorData.metadata =
{
}

TagData = Data.create()

TagData.type = 0x16
TagData.size = 0x10
TagData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "object_number"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "previous_entry_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "tagged_object_pointer"}	
}

ObjectiveData = Data.create()

ObjectiveData.type = 0x17
ObjectiveData.size = nil
ObjectiveData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "objective_number"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "text_preset"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "difficulty"},	
	{["offset"] = 0x10, ["size"] = nil, ["type"] = "list", 		["name"] = "condition_list"},
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

GasContainerData = Data.create()

GasContainerData.type = 0x24
GasContainerData.size = 0x00
GasContainerData.metadata = nil

ItemInfoData = Data.create()

ItemInfoData.type = 0x25
ItemInfoData.size = 0x28
ItemInfoData.metadata = 
{
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "hex",	["name"] = "item"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex",	["name"] = "watch_top_text_preset"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "hex",	["name"] = "watch_bottom_text_preset"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex",	["name"] = "inventory_text_preset"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "hex",	["name"] = "weapon_of_choice_text_preset"},
	{["offset"] = 0x1C, ["size"] = 0x4, ["type"] = "hex",	["name"] = "interaction_text_preset"}	
}

LockData = Data.create()

LockData.type = 0x26
LockData.size = 0x10
LockData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "door_data_pointer"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "object_data_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "previous_entry_pointer"}
}

VehicleData = Data.create()

VehicleData.type = 0x27
VehicleData.size = 0x30
VehicleData.metadata =
{
}

AircraftData = Data.create()

AircraftData.type = 0x28
AircraftData.size = 0x34
AircraftData.metadata =
{
}

GlassData = Data.create()

GlassData.type = 0x2A
GlassData.size = 0x00
GlassData.metadata = nil

SafeData = Data.create()

SafeData.type = 0x2B
SafeData.size = 0x00
SafeData.metadata = nil

SafeObjectData = Data.create()

SafeObjectData.type = 0x2C
SafeObjectData.size = 0x14
SafeObjectData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "object_pointer"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", ["name"] = "safe_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", ["name"] = "door_pointer"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "hex", ["name"] = "previous_entry_pointer"}
}

TankData = Data.create()

TankData.type = 0x2D
TankData.size = 0x60
TankData.metadata = 
{
	{["offset"] = 0x58, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "shell_count"}
}

ViewpointData = Data.create()

ViewpointData.type = 0x2E
ViewpointData.size = 0x1C
ViewpointData.metadata = 
{
	{["offset"] = 0x1A, ["size"] = 0x2, ["type"] = "hex", ["name"] = "preset"}
}

TintedGlassData = Data.create()

TintedGlassData.type = 0x2F
TintedGlassData.size = 0x14
TintedGlassData.metadata = 
{
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "opaque_distance"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "transparent_distance"}
}

-- Append data common for all physical objects
DoorData = 					PhysicalObjectData .. DoorData
KeyData = 					PhysicalObjectData .. KeyData
AlarmData = 				PhysicalObjectData .. AlarmData
CameraData = 				PhysicalObjectData .. CameraData
AmmoClipData = 				PhysicalObjectData .. AmmoClipData
WeaponData = 				PhysicalObjectData .. WeaponData
SingleScreenMonitorData = 	PhysicalObjectData .. SingleScreenMonitorData
MultiScreenMonitorData = 	PhysicalObjectData .. MultiScreenMonitorData
CeilingMonitorsData = 		PhysicalObjectData .. CeilingMonitorsData
DroneData = 				PhysicalObjectData .. DroneData
HatData = 					PhysicalObjectData .. HatData
AmmoBoxData = 				PhysicalObjectData .. AmmoBoxData
BodyArmorData = 			PhysicalObjectData .. BodyArmorData
GasContainerData = 			PhysicalObjectData .. GasContainerData
VehicleData = 				PhysicalObjectData .. VehicleData
AircraftData = 				PhysicalObjectData .. AircraftData
GlassData = 				PhysicalObjectData .. GlassData
SafeData = 					PhysicalObjectData .. SafeData
TankData = 					PhysicalObjectData .. TankData
TintedGlassData = 			PhysicalObjectData .. TintedGlassData

ObjectData = {}

ObjectData.start_pointer_address = 0x075D0C
ObjectData.data_types =
{
	[0x01] = DoorData,
	[0x02] = DoorThicknessData,
	[0x03] = PhysicalObjectData,
	[0x04] = KeyData,
	[0x05] = AlarmData,
	[0x06] = CameraData,
	[0x07] = AmmoClipData,
	[0x08] = WeaponData,
	[0x09] = CharacterData,
	[0x0A] = SingleScreenMonitorData,
	[0x0B] = MultiScreenMonitorData,
	[0x0C] = CeilingMonitorsData,
	[0x0D] = DroneData,
	[0x0E] = CollectibleLinkData,
	[0x11] = HatData,
	[0x12] = GrenadeProbabilityData,
	[0x13] = ObjectLinkData,
	[0x14] = AmmoBoxData,
	[0x15] = BodyArmorData,
	[0x16] = TagData,
	[0x17] = ObjectiveData,
	[0x23] = BriefingData,
	[0x24] = GasContainerData,
	[0x25] = ItemInfoData,
	[0x26] = LockData,
	[0x27] = VehicleData,
	[0x28] = AircraftData,
	[0x2A] = GlassData,
	[0x2B] = SafeData,
	[0x2C] = SafeObjectData,
	[0x2D] = TankData,
	[0x2E] = ViewpointData,
	[0x2F] = TintedGlassData
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