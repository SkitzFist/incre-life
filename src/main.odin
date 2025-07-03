package main

import "core:fmt"
import "core:time"

GameState :: enum {
	PLAY,
	SHOULD_EXIT,
}

WIDTH :: 100
HEIGHT :: 42

TARGET_FPS :: 60
DELAY :: time.Second / TARGET_FPS

main :: proc() {
	gameState := GameState.PLAY

	renderMaps: RenderMaps
	buf: [256]u8

	prepareRenderMaps(&renderMaps)

	fmt.print("\033[?25l") // Hide cursor during animation
	defer fmt.println("\033[?25h") // Restore cursor at exit

	prevTime := time.now()
	dt: time.Duration
	elapsed: time.Duration

	perc: f64 = 1.0
	x: int = 0

	for gameState != .SHOULD_EXIT {
		currentTime := time.now()
		dt = time.diff(prevTime, currentTime)
		prevTime = currentTime

		elapsed += dt

		if elapsed >= time.Millisecond * 200 {
			x += 1
			elapsed = 0
		}

		clearMap(renderMaps.charMap[:])

		fpsString := fmt.bprint(buf[:], "FPS:", dt)
		drawStr(renderMaps.charMap[:], 0, 0, fpsString)

		elapsedString := fmt.bprint(buf[:], "Elapsed:", elapsed)
		drawStr(renderMaps.charMap[:], 0, 1, elapsedString)

		drawLineH(renderMaps.charMap[:], 0, 0, WIDTH)
		drawLineV(renderMaps.charMap[:], 0, 0, HEIGHT)


		render(renderMaps.stringMap[:])
		time.sleep(DELAY)
	}
}

render :: proc(stringMap: []string) {
	fmt.print("\033[2J\033[H")
	for line in stringMap {
		fmt.println(line, flush = false)
	}
	//flush
	fmt.print("")
}
