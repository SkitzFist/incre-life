package main

import "core:fmt"

RENDER_WIDTH : int

RenderMaps :: struct {
	charMap: [dynamic]u8,
	stringMap:[dynamic]string,
}

delete_renderMaps :: proc(renderMaps:^RenderMaps){
	delete(renderMaps^.stringMap)
	delete(renderMaps^.charMap)
}

prepareRenderMaps :: proc(renderMaps: ^RenderMaps, width:int, height:int) {
	delete (renderMaps^.charMap)
	renderMaps^.charMap = nil
	
	delete (renderMaps^.stringMap)
	renderMaps^.stringMap = nil
	
	w := width - 1
	h := height - 1
	RENDER_WIDTH = w
	
	resize(&renderMaps^.charMap, w * h)
	clearMap(renderMaps^.charMap[:])
	
	resize(&renderMaps^.stringMap, h)
	for i in 0..<h {
    	renderMaps^.stringMap[i] = string(renderMaps^.charMap[i * w : i * w + w])
	}
}

clearMap :: proc(charMap: []u8) {
	for &r in charMap {
		r = ' '
	}
}

//---- Drawing ----//

drawChar :: proc(charMap: []u8, x: int, y: int, char: rune) {
	index := y * RENDER_WIDTH + x

	if index >= len(charMap) {
		return
	}

	charMap[index] = cast(u8)char
}

drawStr :: proc(charMap: []u8, x: int, y: int, str: string) {
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
