package main

import "core:fmt"
import "core:os"
import "core:terminal"
import "core:time"

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

	fmt.print("\033[?25l") // Hide cursor during animation
	defer fmt.println("\033[?25h") // Restore cursor at exit)

	//get terminal size & set render maps size
	T_WIDTH, T_HEIGHT := terminal_utility.get_size()

	renderer: Renderer
	set_new_size(&renderer, T_WIDTH, T_HEIGHT)

	gameState := GameState.PLAY

	menu: Menu = create_full_menu()

	prevTime := time.now()
	dt: time.Duration
	elapsed: time.Duration

	
	lastInput:string // debug

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
		key, ok := terminal_utility.read_keypress()

		if (ok) {
			dir: int
			lastInput = key
			switch key {
				case "\x1B[A":
					dir = -1
				case "\x1B[B":
					dir = 1
			}

			newIndex := menu.activeIndex + dir
			if newIndex >= 0 && newIndex < menu.itemLength {
				menu.activeIndex = newIndex
			}
		}

		draw_str(&renderer,1,20, "Input: ", lastInput)

		//draw calls
		draw_rect(&renderer, 0, 0, renderer.width, renderer.height) // game frame
		draw_menu(&renderer, &menu, 0, 0)

		render(&renderer)
				
		time.sleep(DELAY)
	}
}
