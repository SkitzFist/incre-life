package main

import "core:fmt"
import "core:sys/posix"

MAX_BUF_SIZE :: 32_768

TMP_STR_BUF: [256]u8

get_u8 :: proc(str: string) -> []u8 {
	return transmute([]u8)str
}

CURSOR_HOME: []u8 = get_u8("\x1b[H")

Renderer :: struct {
	width:  int,
	height: int,
	buf:    [MAX_BUF_SIZE]u8,
}

set_new_size :: proc(renderer: ^Renderer, newWidth: int, newHeight: int) {
	renderer^.width = newWidth
	renderer^.height = newHeight

	if (newWidth * newHeight > MAX_BUF_SIZE) {
		fmt.println("ERROR: Size bigger then buf size")
	}

	clear(renderer)
}

clear :: proc(renderer: ^Renderer) {
	length := renderer^.width * renderer^.height

	// whitespace
	for i in 0 ..< length {
		renderer^.buf[i] = cast(u8)' '
	}
}

render :: proc(renderer: ^Renderer) {
	#no_bounds_check {
		posix.write(posix.FD(1), &CURSOR_HOME[0], len(CURSOR_HOME))
		length := cast(uint)(renderer^.width * renderer^.height)
		posix.write(posix.FD(1), &renderer^.buf[0], length)
	}
}

//---- Drawing ----//

draw_rune :: proc(renderer: ^Renderer, x: int, y: int, char: rune) {
	index := y * renderer^.width + x

	if index < 0 || index >= len(renderer^.buf) {
		return
	}

	renderer^.buf[index] = cast(u8)char
}

draw_str_plain :: proc(renderer: ^Renderer, x: int, y: int, str: string) {
	for r, i in str {
		draw_rune(renderer, x + i, y, r)
	}
}

draw_str_args :: proc(renderer: ^Renderer, x: int, y: int, args: ..any) {
	string := fmt.bprint(TMP_STR_BUF[:], args)
	draw_str_plain(renderer, x, y, string)
}


draw_str :: proc {
	draw_str_plain,
	draw_str_args,
}

draw_rect :: proc(
	renderer: ^Renderer,
	xPos: int,
	yPos: int,
	width: int,
	height: int,
	corner: rune = '+',
	borderH: rune = '-',
	borderV: rune = '|',
	fill: rune = ' ',
) {
	endX := xPos + width - 1
	endY := yPos + height - 1

	draw_line_h(renderer, xPos, yPos, width, borderH)
	draw_line_h(renderer, xPos, endY, width, borderH)

	draw_line_v(renderer, xPos, yPos, height, borderV)
	draw_line_v(renderer, endX, yPos, height, borderV)

	draw_rune(renderer, xPos, yPos, corner)
	draw_rune(renderer, endX, yPos, corner)
	draw_rune(renderer, xPos, endY, corner)
	draw_rune(renderer, endX, endY, corner)
}

draw_line_h :: proc(renderer: ^Renderer, xPos, yPos, length: int, fill: rune = '*') {
	for x := xPos; x < xPos + length; x += 1 {
		draw_rune(renderer, x, yPos, fill)
	}
}

draw_line_v :: proc(renderer: ^Renderer, xPos, yPos, length: int, fill: rune = '*') {
	for y := yPos; y < yPos + length; y += 1 {
		draw_rune(renderer, xPos, y, fill)
	}
}
