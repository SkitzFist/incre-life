package main

import "core:time"

SceneType :: enum {
	SCHOOL,
	TRAINING,
	HOUSE,
	WORK,
	SHOP,
}

SceneFunctions :: struct {
	handleInput: proc(data: ^GameData, input: string),
	update:      proc(data: ^GameData, dt: time.Duration),
	render:      proc(data: ^GameData, renderer: ^Renderer),
}

create_scene_functions_empty :: proc() -> SceneFunctions {
	return {}
}

create_scene_funcs :: proc() -> [len(SceneType)]SceneFunctions {
	return {
		create_scene_functions_empty(),
		create_scene_functions_empty(),
		create_scene_functions_empty(),
		create_scene_functions_empty(),
		create_scene_functions_empty(),
	}
}

Scene :: struct {
	active:    SceneType,
	available: bit_set[SceneType],
}

create_scene_full :: proc() -> Scene {
	return {active = .SCHOOL, available = ~bit_set[SceneType]{}}
}

create_scene_default :: proc() -> Scene {
	return {active = .SCHOOL, available = {.SCHOOL}}
}

create_scene_partial :: proc(types: ..SceneType) -> Scene {
	available: bit_set[SceneType]
	lowestIndex := 99
	for type in types {
		if cast(int)type < lowestIndex {
			lowestIndex = cast(int)type
		}
		available += {type}
	}


	return {active = SceneType(lowestIndex), available = available}
}

set_scene_available :: proc(scene: ^Scene, type: SceneType) {
	scene^.available += {type}
}

set_scene_unavailable :: proc(scene: ^Scene, type: SceneType) {
	scene^.available -= {type}
}

get_next_available_scene :: proc(scene: ^Scene) -> SceneType {
	i := cast(int)scene^.active
	count := len(SceneType)

	for step in 1 ..< count {
		next := (i + step) % count
		if SceneType(next) in scene^.available {
			return SceneType(next)
		}
	}

	return scene^.active
}

get_prev_available_scene :: proc(scene: ^Scene) -> SceneType {
	i := cast(int)scene^.active
	count := len(SceneType)

	for step in 1 ..< count {
		prev := (i - step + count) % count
		if SceneType(prev) in scene^.available {
			return SceneType(prev)
		}
	}

	return scene^.active
}
