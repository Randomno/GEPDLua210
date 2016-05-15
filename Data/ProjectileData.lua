require "Data\\ObjectData"

ProjectileData = {}

ProjectileData.start_address = 0x071E80
ProjectileData.current_slot_address = 0x030AF8
ProjectileData.previous_entry_pointer_address = 0x073EA4
ProjectileData.size = WeaponData.size
ProjectileData.capacity = 30

function ProjectileData.is_empty(_projectile_address)
	local position_data_address = WeaponData:get_value(_projectile_address, "position_data_pointer")
	
	return (position_data_address == 0x00000000)
end

function ProjectileData.get_value(_projectile_address, _name)
	return WeaponData:get_value(_projectile_address, _name)
end