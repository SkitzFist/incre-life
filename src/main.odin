package main

import "core:fmt"
import "core:time"
import "core:os"
import "core:terminal"

import "terminal_utility"

GameState :: enum {
	PLAY,
	SHOULD_EXIT,
}

WIDTH :: 139 - 1
HEIGHT :: 69 - 1

TARGET_FPS :: 60
DELAY :: time.Second / TARGET_FPS

main :: proc() {

	{
		tw, th, ok := terminal_utility.get_size()
	}	

	termios, ok := terminal_utility.enable_raw_mode()
	if !ok {
		fmt.println("Could not enable raw mode")
		return
	}
	defer terminal_utility.disable_raw_mode(&termios)
	
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

		clearMap(renderMaps.charMap[:])

		key, keyLen := terminal_utility.read_keypress()

		if key == 'd'{
			x += 1
		}

		fpsString := fmt.bprint(buf[:], "FPS:", dt)
		drawStr(renderMaps.charMap[:], 0, x, fpsString)

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
