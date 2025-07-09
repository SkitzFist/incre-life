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

main :: proc() {
	termios, ok := terminal_utility.enable_raw_mode()
	if !ok {
		fmt.println("Could not enable raw mode")
		return
	}
	defer terminal_utility.disable_raw_mode(&termios)

	//get terminal size & set render maps size
	T_WIDTH, T_HEIGHT := terminal_utility.get_size()

	renderer: Renderer;
	set_new_size(&renderer, T_WIDTH, T_HEIGHT)
	
	gameState := GameState.PLAY

	tmpStrBuf: [256]u8 // tmp string storage

	fmt.print("\033[?25l") // Hide cursor during animation
	defer fmt.println("\033[?25h") // Restore cursor at exit

	prevTime := time.now()
	dt: time.Duration
	elapsed: time.Duration

	for gameState != .SHOULD_EXIT {

		//frametime		
		currentTime := time.now()
		dt = time.diff(prevTime, currentTime)
		prevTime = currentTime
		elapsed += dt

		//clear prevFrame
		T_WIDTH, T_HEIGHT := terminal_utility.get_size()
		set_new_size(&renderer, T_WIDTH, T_HEIGHT)

		//input
		key, keyLen := terminal_utility.read_keypress()

		draw_rune(&renderer, 0, 0, key)

		
		//draw calls
		draw_rect(&renderer, 0, 0, renderer.width, renderer.height)

		fpsString := fmt.bprint(tmpStrBuf[:], "frameTime:", dt)
		draw_str(&renderer, 1, 1, fpsString)
		
		
		// render
		render(&renderer)
		time.sleep(DELAY)
	}
}
