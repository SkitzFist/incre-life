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

draw_menu :: proc(renderer: ^Renderer, menu: ^Menu, xPos: int, yPos: int) {

	longest_word: int = get_menu_longest_item_length(menu)
	spacing := 2
	width: int = spacing * 2 + longest_word

	height := menu.itemLength * 2 + 1

	draw_rect(renderer, xPos, yPos, width, height)

	for i := 0; i < menu^.itemLength; i += 1 {
		str := fmt.enum_value_to_string(menu^.items[i]) or_continue

		x := (width / 2) - (len(str) / 2) + xPos
		y := 1 + (i * 2) + yPos
		draw_str(renderer, x, y, str)

		if (i == menu^.activeIndex) {
			//draw pointer
			//draw_str(renderer, xPos + 1, y, pointer)
			draw_rect(renderer, xPos, y - 1, width, 3, corner = '+', borderH = '*', borderV = '|')
		}

	}
}
