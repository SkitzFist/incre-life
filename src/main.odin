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

TARGET_FPS :: 60_000
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

	for gameState != .SHOULD_EXIT {

		//frametime		
		currentTime := time.now()
		dt = time.diff(prevTime, currentTime)
		prevTime = currentTime
		elapsed += dt

		//clear prevFrame
		//T_WIDTH, T_HEIGHT := terminal_utility.get_size()
		//set_new_size(&renderer, T_WIDTH, T_HEIGHT)

		//input
		key, keyLen := terminal_utility.read_keypress()

		if (keyLen > 0) {
			dir: int
			switch key {
			case 'A':
				dir = -1
			case 'B':
				dir = 1
			}

			newIndex := menu.activeIndex + dir
			if newIndex >= 0 && newIndex < menu.itemLength {
				menu.activeIndex = newIndex
			}
		}

		//draw calls
		draw_rect(&renderer, 0, 0, renderer.width, renderer.height) // game frame

		draw_str(&renderer, 1, 1, "dt:", dt)
		draw_str(&renderer, 1, 2, "fps:", f64(time.Second) / f64(dt))
		
		draw_menu(&renderer, &menu, 10, 10)


		// render
		render(&renderer)
		
		//time.sleep(DELAY)
	}
}
