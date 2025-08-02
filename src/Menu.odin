package main

import "core:fmt"

menu_handle_input :: proc(scene: ^Scene, input: string) {

	switch input {
	case "\e[Z":
		scene^.active = get_prev_available_scene(scene)
	case "\t":
		scene^.active = get_next_available_scene(scene)
	}

}

draw_menu :: proc(renderer: ^Renderer, scene: ^Scene, xPos: int, yPos: int) {
	spacing :: 2
	totalWidth := 0
	length := 0

	for type in SceneType {
		if type in scene^.available {
			length += 1
			enumStr := fmt.enum_value_to_string(type) or_continue
			totalWidth += len(enumStr)
		}
	}

	totalWidth += length * spacing + 1
	x := renderer^.width / 2 - totalWidth / 2

	for type in SceneType {
		if type in scene^.available {
			enumStr := fmt.enum_value_to_string(type) or_continue
			enumLen := len(enumStr)
			draw_str(renderer, x, yPos, enumStr)

			if type == scene^.active {
				//draw marker
				draw_rect(renderer, x - 1, yPos - 1, enumLen + 2, 3)
			}

			x += enumLen + spacing
		}
	}
}
