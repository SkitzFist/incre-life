package main

import "core:time"

SceneType :: enum {
	NONE,
	SCHOOL,
	MARKET,
}

SceneFunctions :: struct {
	handleInput: proc(data: ^GameData, input: string),
	update:      proc(data: ^GameData, dt: time.Duration),
	render:      proc(data: ^GameData, renderer: ^Renderer),
}

create_scene_funcs :: proc() -> [SceneType]SceneFunctions {
	return {.NONE = {}, .SCHOOL = {school_handleInput, school_update, school_render}, .MARKET = {}}
}

Scene :: struct {
	active:    SceneType,
	available: bit_set[SceneType],
}

create_scene_full :: proc() -> Scene {
	return {active = .SCHOOL, available = ~bit_set[SceneType]{}}
}

create_scene_default :: proc() -> Scene {
	return {active = .NONE, available = {}}
}

create_scene_partial :: proc(types: ..SceneType) -> Scene {
	available: bit_set[SceneType]
	lowestIndex := len(SceneType)
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
	//Could trigger onActivated function
}

set_scene_unavailable :: proc(scene: ^Scene, type: SceneType) {
	scene^.available -= {type}
	//Could trigger onUnActivated function
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
