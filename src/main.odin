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

TARGET_FPS :: 60
DELAY :: time.Second / TARGET_FPS

WIDTH:int
HEIGHT:int

main :: proc() {
	termios, ok := terminal_utility.enable_raw_mode()
	if !ok {
		fmt.println("Could not enable raw mode")
		return
	}
	defer terminal_utility.disable_raw_mode(&termios)

	//get terminal size & set render maps size
	T_WIDTH, T_HEIGHT := terminal_utility.get_size()
	renderMaps:RenderMaps
	defer {delete_renderMaps(&renderMaps)}
	prepareRenderMaps(&renderMaps, T_WIDTH, T_HEIGHT)
	WIDTH = T_WIDTH - 1
	HEIGHT = T_HEIGHT - 1
	
	gameState := GameState.PLAY

	buf: [256]u8

	fmt.print("\033[?25l") // Hide cursor during animation
	defer fmt.println("\033[?25h") // Restore cursor at exit

	prevTime := time.now()
	dt: time.Duration
	elapsed: time.Duration

	perc: f64 = 1.0
	x: int = 0

	for gameState != .SHOULD_EXIT {

		tw, th := terminal_utility.get_size()

		if tw != T_WIDTH || th != T_HEIGHT{
			prepareRenderMaps(&renderMaps, tw, th)
			T_WIDTH, T_HEIGHT = tw, th
			WIDTH = T_WIDTH - 1
			HEIGHT = T_HEIGHT - 1
		}
		
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
		drawStr(renderMaps.charMap[:], 1, 1, fpsString)

		elapsedString := fmt.bprint(buf[:], "Elapsed:", elapsed)
		drawStr(renderMaps.charMap[:], 1, 2, elapsedString)

		sizeStr := fmt.bprint(buf[:], "TerminalSize: ", tw, th)
		drawStr(renderMaps.charMap[:], 1, 4, sizeStr)

		drawLineH(renderMaps.charMap[:], 0, 0, WIDTH)
		drawLineH(renderMaps.charMap[:], 0, HEIGHT - 1, WIDTH)
		
		drawLineV(renderMaps.charMap[:], 0, 0, HEIGHT - 1)
		drawLineV(renderMaps.charMap[:], WIDTH - 1, 0, HEIGHT)


		render(renderMaps.stringMap[:])
		time.sleep(DELAY)
	}
}

render :: proc(stringMap: []string) {
	//fmt.print("\033[2J\033[H") // clear 
	fmt.print("\x1b[H") // move cursor to top-left
	for line in stringMap {
		fmt.println(line, flush = false)
	}
	
	//flush
	fmt.print("")
}
