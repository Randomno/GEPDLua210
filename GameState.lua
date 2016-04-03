GameState = {}

GameState.current_scene_address = 0x02A8C0
GameState.current_mission_address = 0x02A8FB
GameState.global_timer_address = 0x04837C
GameState.global_timer_divided_by_four_address = 0x079E80
GameState.mission_timer_address = 0x079A20
GameState.random_number_generator_address = 0x024464

GameState.scene_index_to_name = 
{
	"Twycross Classification",
	"Nintendo Logo",
	"Rareware Logo",
	"Bond Intro",
	"Goldeneye Logo",
	"File Select",
	"File Menu",
	"Mission Select",
	"Difficulty Select",
	"007 Settings",
	"Mission Briefing",
	"Mission Start",
	"Mission Status",
	"Mission Time"
}

GameState.mission_index_to_name =
{
	[0x01] = "Dam",
	[0x02] = "Facility",
	[0x03] = "Runway",
	[0x05] = "Surface 1",
	[0x06] = "Bunker 1",
	[0x08] = "Silo",
	[0x0A] = "Frigate",
	[0x0C] = "Surface 2",
	[0x0D] = "Bunker 2",
	[0x0F] = "Statue",
	[0x10] = "Archives",
	[0x11] = "Streets",
	[0x12] = "Depot",
	[0x13] = "Train",
	[0x15] = "Jungle",
	[0x16] = "Control",
	[0x17] = "Caverns",
	[0x18] = "Cradle",
	[0x1A] = "Aztec",
	[0x1C] = "Egyptian"
}

function GameState.get_current_scene()
	return mainmemory.read_u32_be(GameState.current_scene_address)
end

function GameState.get_current_mission()
	return mainmemory.read_u8(GameState.current_mission_address)
end

function GameState.get_scene_name(_scene)
	return GameState.scene_index_to_name[_scene]
end

function GameState.get_mission_name(_mission)
	return GameState.mission_index_to_name[_mission]
end

function GameState.get_global_time()
	return mainmemory.read_u32_be(GameState.global_timer_address)
end

function GameState.get_mission_time()
	return mainmemory.read_u32_be(GameState.mission_timer_address)
end

function GameState.get_global_time_divided_by_four()
	return mainmemory.readfloat(GameState.global_timer_divided_by_four_address, true)
end