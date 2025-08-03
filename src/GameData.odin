package main

MENU_Y :: 1
TIME_Y :: 3
STAT_Y :: TIME_Y + 1
HEADER_HEIGHT :: STAT_Y + 2
SCENE_Y :: HEADER_HEIGHT

GameData :: struct {
	scene:      Scene,
	sceneFuncs: [SceneType]SceneFunctions,
	stats:      Stats,
	school:     School,
	time:       Time,
}

create_game_data :: proc() -> GameData {
	return {
		scene = create_scene_full(),
		sceneFuncs = create_scene_funcs(),
		stats = create_stats_full(),
		school = create_school_default(),
		time = create_default_time(),
	}
}
