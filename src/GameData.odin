package main

HEADER_HEIGHT :: 5
STAT_Y :: 3
SCENE_Y :: HEADER_HEIGHT

GameData :: struct {
	scene:      Scene,
	sceneFuncs: [SceneType]SceneFunctions,
	stats:      Stats,
	school:     School,
}

create_game_data :: proc() -> GameData {
	return {
		scene = create_scene_partial(.SCHOOL),
		sceneFuncs = create_scene_funcs(),
		stats = create_stats_full(),
		school = create_school_default(),
	}
}
