package main

import "core:math"

//debug
import "core:fmt"

Menu :: struct {
	items:       [len(Scene)]Scene,
	itemLength:  int,
	activeIndex: int,
}

create_full_menu :: proc() -> Menu {
	items := [len(Scene)]Scene{}
	for i in 0 ..< len(Scene) {
		items[i] = Scene(i)
	}

	return Menu{items = items, itemLength = len(Scene), activeIndex = 0}
}

add_menu_item :: proc(menu: ^Menu, item: Scene) {
	if cap(menu^.items) == menu^.itemLength {
		return
	}

	menu^.items[menu^.itemLength] = item

	menu^.itemLength += 1
}

get_menu_longest_item_length :: proc(menu: ^Menu) -> int {
	longest: int

	for i := 0; i < menu^.itemLength; i += 1 {
		enumStr := fmt.enum_value_to_string(menu^.items[i]) or_continue

		wordLength := len(enumStr)
		if (longest < wordLength) {
			longest = wordLength
		}
	}

	return longest
}


/*
	TODO: should calculate the entire string when an menu item has been added,
		  draw the entire screen, and only update marker dynamically
*/
draw_menu :: proc(renderer: ^Renderer, menu: ^Menu, xPos: int, yPos: int) {
	spacing :: 2

	totalWidth := 0

	for scene in menu^.items {
		enumStr := fmt.enum_value_to_string(scene) or_continue

		totalWidth += len(enumStr)
	}

	totalWidth += menu^.itemLength * spacing + 1

	startX := renderer^.width / 2 - totalWidth / 2
	x := startX
	for scene, i in menu^.items {
		enumStr := fmt.enum_value_to_string(scene) or_continue
		enumLen := len(enumStr)
		draw_str(renderer, x, yPos, enumStr)

		if i == menu^.activeIndex {
			//draw marker
			draw_rect(renderer, x - 1, yPos - 1, enumLen + 2, 3)
		}

		x += enumLen + spacing
	}
}
