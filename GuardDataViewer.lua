require "GuardData"

local guard_data_enums = 
{
	["current_action"] = 
	{
		[0x1] = "standing",
		[0x2] = "ducking",
		[0x3] = "wasting time",
		[0x4] = "dying",
		[0x5] = "dead/fading",
		[0x6] = "injured",
		[0x8] = "shooting/aiming",
		[0x9] = "shooting + walking",
		[0xA] = "shooting + running/rolling",
		[0xB] = "sidestepping",
		[0xC] = "sidehopping",
		[0xD] = "running away",
		[0xE] = "walking along path",
		[0xF] = "moving",
		[0x10] = "surrendering",
		[0x12] = "looking around",
		[0x13] = "triggering alarm",
		[0x14] = "throwing grenade"		
	}
}

function format_guard_data_value(value, metadata)	
	if metadata.type == "hex" then
		return string.format("%s: 0x%X", metadata.name, value)
	elseif metadata.type == "unsigned" then
		return string.format("%s: %d", metadata.name, value)
	elseif metadata.type == "float" then
		return string.format("%s: %.4f", metadata.name, value)
	elseif metadata.type == "enum" then
		local mnemonic = guard_data_enums[metadata.name][value]
		
		if mnemonic == nil then
			mnemonic = string.format("unknown (0x%X)", value)
		end			
	
		return string.format("%s: %s", metadata.name, mnemonic)		
	else
		error("invalid guard value type")
	end
end

function write_guard_data(_slot)
	local guard_data_string = string.format("base_address: 0x%X\n\n", get_base_address(_slot))
	
	for index, metadata in ipairs(guard_data) do
		local guard_data_value = read_guard_data_value(_slot, metadata.name)	
		guard_data_string = guard_data_string .. format_guard_data_value(guard_data_value, metadata) .. "\n"
	end	
	
	forms.settext(guard_data_output_text, guard_data_string)
end

local current_slot = 1

function on_update()
	write_guard_data(current_slot)
end

function on_slot_changed()
	local slot_string = string.format("Slot %d / %d", current_slot, guard_data_slots)
	
	forms.settext(guard_data_slot_text, slot_string)
end

function on_prev_slot()
	current_slot = math.max((current_slot - 1), 1)
	
	on_slot_changed()
	on_update()
end

function on_next_slot()
	current_slot = math.min((current_slot + 1), guard_data_slots)
	
	on_slot_changed()
	on_update()
end

guard_data_button_size_x = 75
guard_data_button_size_y = 25

guard_data_dialog_size_x = 480
guard_data_dialog_size_y = 920

guard_data_prev_slot_button_pos_x = (guard_data_dialog_size_x / 2) - 5 - guard_data_button_size_x - 10
guard_data_prev_slot_button_pos_y = guard_data_dialog_size_y - 70

guard_data_next_slot_button_pos_x = (guard_data_dialog_size_x / 2) + 5 - 10
guard_data_next_slot_button_pos_y = guard_data_prev_slot_button_pos_y

guard_data_output_text_pos_x = 0
guard_data_output_text_pos_y = 0
guard_data_output_text_size_x = guard_data_dialog_size_x
guard_data_output_text_size_y = guard_data_dialog_size_y - 100

guard_data_slot_text_pos_x = 10
guard_data_slot_text_pos_y = guard_data_prev_slot_button_pos_y + 5

guard_data_dialog = forms.newform(guard_data_dialog_size_x, guard_data_dialog_size_y, "Guard Data Viewer")
guard_data_prev_slot_button = forms.button(guard_data_dialog, "Prev slot", on_prev_slot, guard_data_prev_slot_button_pos_x, guard_data_prev_slot_button_pos_y, guard_data_button_size_x, guard_data_button_size_y)
guard_data_next_slot_button = forms.button(guard_data_dialog, "Next slot", on_next_slot, guard_data_next_slot_button_pos_x, guard_data_next_slot_button_pos_y, guard_data_button_size_x, guard_data_button_size_y)
guard_data_output_text = forms.label(guard_data_dialog, "", guard_data_output_text_pos_x, guard_data_output_text_pos_y, guard_data_output_text_size_x, guard_data_output_text_size_y, true)
guard_data_slot_text = forms.label(guard_data_dialog, "", guard_data_slot_text_pos_x, guard_data_slot_text_pos_y)

on_slot_changed()
on_update()

event.onframeend(on_update)