package main

MENU_Y :: 1
TIME_Y :: 3
STAT_Y :: TIME_Y + 1
HEADER_HEIGHT :: STAT_Y + 2
SCENE_Y :: HEADER_HEIGHT

GameData :: struct {
	eventQueue:       EventQueue,
	activeEventIndex: int,
	eventChoiceMap:   EventChoiceMap,
	scene:            Scene,
	sceneFuncs:       [SceneType]SceneFunctions,
	stats:            Stats,
	time:             Time,
	school:           School,
}

create_game_data :: proc() -> GameData {
	return {
		eventQueue = create_event_queue_default(),
		activeEventIndex = -1,
		scene = create_scene_default(),
		sceneFuncs = create_scene_funcs(),
		stats = create_stats_full(),
		time = create_default_time(),
		school = create_school_default(),
	}
}
