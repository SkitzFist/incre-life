package main

import "core:time"

Scene :: enum {
	SCHOOL,
	WORK,
	TRAINING,
	SHOP,
	HOUSE,
}

SceneFunctions :: struct {
	handleInput: proc(input: rune),
	update:      proc(dt: time.Duration),
	render:      proc(renderer: ^Renderer),
}

testHandleInput :: proc(input: rune) {

}

testUpdate :: proc(dt: time.Duration) {

}

testRender :: proc(renderer: ^Renderer) {
	draw_str(renderer, 1, 2, "Test Scene")
}
