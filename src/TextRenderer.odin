package main

import "core:fmt"

RenderMaps :: struct {
	charMap:   [WIDTH * HEIGHT]u8,
	stringMap: [HEIGHT]string,
}

prepareRenderMaps :: proc(renderMaps: ^RenderMaps) {
	for &r in renderMaps^.charMap {
		r = ' '
	}

	for str, i in renderMaps^.stringMap {
		renderMaps^.stringMap[i] = string(renderMaps^.charMap[i * WIDTH:i * WIDTH + WIDTH])
	}
}

clearMap :: proc(charMap: []u8) {
	for &r in charMap {
		r = ' '
	}
}

//---- Drawing ----//

drawChar :: proc(charMap: []u8, x: int, y: int, char: rune) {
	index := y * WIDTH + x

	charMap[index] = cast(u8)char
}

drawStr :: proc(charMap: []u8, x: int, y: int, str: string) {
	startIndex := y * WIDTH + x

	for r, i in str {
		drawChar(charMap[:], x + i, y, r)
	}
}

drawRect :: proc(
	charMap: []u8,
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

			drawChar(charMap[:], x, y, r)
		}
	}
}

drawLineH :: proc(charMap: []u8, xPos, yPos, length: int, fill: rune = '*') {
	for x := xPos; x < xPos + length; x += 1 {
		drawChar(charMap[:], x, yPos, fill)
	}
}

drawLineV :: proc(charMap: []u8, xPos, yPos, length: int, fill: rune = '*') {
	for y := yPos; y < yPos + length; y += 1 {
		drawChar(charMap[:], xPos, y, fill)
	}
}
