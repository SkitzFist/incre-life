package main

import "core:sys/posix"
import "core:fmt"

RENDER_WIDTH : int

MAX_BUF_SIZE :: 32_768

Renderer :: struct {
	width : int,
	height : int,
	buf : [MAX_BUF_SIZE]u8,
}

set_new_size :: proc(renderer:^Renderer, newWidth: int, newHeight: int) {
	renderer^.width = newWidth
	renderer^.height = newHeight

	clear(renderer)
}

clear :: proc(renderer:^Renderer){
	length := renderer^.width * renderer^.height

	// whitespace
	for i in 0..<length{
		renderer^.buf[i] = cast(u8)' '
	}
}

render :: proc(renderer:^Renderer) {
	fmt.print("\x1b[H") // move cursor to top left
	length := cast(uint)(renderer^.width * renderer^.height)
	posix.write(posix.FD(1), &renderer^.buf[0], length)
}

//---- Drawing ----//

draw_rune :: proc(renderer:^Renderer, x: int, y: int, char: rune) {
	index := y * renderer^.width + x

	if index >= len(renderer^.buf) {
		return
	}

	renderer^.buf[index] = cast(u8)char
}

draw_str :: proc(renderer:^Renderer, x: int, y: int, str: string) {
	for r, i in str {
		draw_rune(renderer, x + i, y, r)
	}
}

draw_rect :: proc(
	renderer:^Renderer,
	xPos: int,
	yPos: int,
	width: int,
	height: int,
	corner: rune = '+',
	borderH: rune = '-',
	borderV: rune = '|',
	fill: rune = ' ',
) {
	endX := xPos + width
	endY := yPos + height

	for y := yPos; y < endY; y += 1 {
		for x := xPos; x < endX; x += 1 {
			r: rune

			if (x == xPos || x == endX - 1) && (y == yPos || y == endY - 1) {
				r = corner
			} else if y == yPos || y == endY - 1 {
				r = borderH
			} else if x == xPos || x == endX - 1 {
				r = borderV
			} else {
				r = fill
			}

			draw_rune(renderer, x, y, r)
		}
	}
}

draw_line_h :: proc(renderer:^Renderer, xPos, yPos, length: int, fill: rune = '*') {
	for x := xPos; x < xPos + length; x += 1 {
		draw_rune(renderer, x, yPos, fill)
	}
}

draw_line_v :: proc(renderer:^Renderer, xPos, yPos, length: int, fill: rune = '*') {
	for y := yPos; y < yPos + length; y += 1 {
		draw_rune(renderer, xPos, y, fill)
	}
}
