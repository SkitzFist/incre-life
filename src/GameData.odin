package main

HEADER_HEIGHT :: 5
STAT_Y :: 3
SCENE_Y :: HEADER_HEIGHT

GameData :: struct {
	scene:      Scene,
	sceneFuncs: [len(SceneType)]SceneFunctions,
	stats:      Stats,
}

create_game_data :: proc() -> GameData {
	return {
		scene = create_scene_partial(.HOUSE, .SCHOOL),
		sceneFuncs = create_scene_funcs(),
		stats = create_stats_full(),
	}
}
