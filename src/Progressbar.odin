package main

import "core:math"

draw_progress_bar :: proc(renderer: ^Renderer, x: int, y: int, width: int, progress: f64) {
	draw_rune(renderer, x, y, '|')
	draw_rune(renderer, x + width, y, '|')

	maxFillWidth := width
	fillLength := math.floor(cast(f64)width * progress)

	for fillX := x + 1; fillX < x + cast(int)fillLength; fillX += 1 {
		draw_rune(renderer, fillX, y, '*')
	}

}
