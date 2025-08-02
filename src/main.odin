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

	terminal_utility.enable_alternate_screen()
	defer terminal_utility.disable_alternate_screen()

	terminal_utility.hide_cursor()
	defer terminal_utility.show_cursor()

	//get terminal size & set render maps size
	T_WIDTH, T_HEIGHT := terminal_utility.get_size()

	renderer: Renderer
	set_new_size(&renderer, T_WIDTH, T_HEIGHT)

	gameState := GameState.PLAY

	data := create_game_data()

	prevTime := time.now()
	dt: time.Duration

	lastInput: string // debug

	gameLoop: for gameState != .SHOULD_EXIT {

		//frametime		
		currentTime := time.now()
		dt = time.diff(prevTime, currentTime)
		prevTime = currentTime

		//clear prevFrame
		T_WIDTH, T_HEIGHT := terminal_utility.get_size()
		set_new_size(&renderer, T_WIDTH, T_HEIGHT)

		//input
		input, ok := terminal_utility.read_keypress()

		if (ok) {
			dir: int
			lastInput = input
			switch input {
			case "q":
				gameState = .SHOULD_EXIT
				break gameLoop
			case "w":
				set_scene_available(&data.scene, .WORK)
			}

			menu_handle_input(&data.scene, input)


			if data.sceneFuncs[data.scene.active].handleInput != nil {
				data.sceneFuncs[data.scene.active].handleInput(&data, input)
			}
		}

		// update
		if data.sceneFuncs[data.scene.active].update != nil {
			data.sceneFuncs[data.scene.active].update(&data, dt)
		}

		//debug
		draw_str(&renderer, 1, renderer.height - 2, "Input: ", lastInput)

		//draw calls
		draw_rect(&renderer, 0, 0, renderer.width, renderer.height) // game frame

		// Header
		draw_rect(&renderer, 0, 0, renderer.width, STAT_Y + 2) // header border
		draw_menu(&renderer, &data.scene, 0, 1)
		draw_stats(&renderer, &data.stats, 1, STAT_Y)

		if data.sceneFuncs[data.scene.active].render != nil {
			data.sceneFuncs[data.scene.active].render(&data, &renderer)
		}

		// render frame
		render(&renderer)

		time.sleep(DELAY)
	}
}
