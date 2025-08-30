package main

import "core:bufio"
import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 600

DEBUG_WIDTH :: 150
FONTSIZE: i32 : 16
SECTION_PADDING :: 20

GLYPH_WIDTH :: 16
GLYPH_HEIGHT :: 24

ASCII_START: int : 33

ATLAS_COLS :: 3

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Incre-Life")
	rl.SetWindowState({rl.ConfigFlag.WINDOW_RESIZABLE})

	startX :: DEBUG_WIDTH + SECTION_PADDING
	startY :: SECTION_PADDING

	width := WINDOW_WIDTH - startX - SECTION_PADDING
	height := WINDOW_HEIGHT - startY - SECTION_PADDING

	rayminal := create_rayminal_data_full(
		rl.Vector2{f32(GLYPH_WIDTH), f32(GLYPH_HEIGHT)},
		width,
		height,
	)

	// BUF
	for i in 0 ..< rayminal.length {
		rayminal.buf[i] = u8(i % 9)
	}

	rayminalGraphics := create_rayminal_graphics(
		"shaders/TextShader.vs",
		"shaders/TextShader.fs",
		"assets/fonts/Skz-Font.png",
		&rayminal,
	)

	shaderMode := true

	for !rl.WindowShouldClose() {

		if rl.IsWindowResized() {
			rayminal_on_resize(&rayminal, &rayminalGraphics)
		}
		dt := rl.GetFrameTime()

		//input
		if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
			rl.CloseWindow()
			break
		} else if rl.IsKeyPressed(rl.KeyboardKey.TAB) {
			shaderMode = !shaderMode
		} else if rl.IsKeyPressed(rl.KeyboardKey.KP_ADD) {
			rayminal_set_scale(&rayminal, &rayminalGraphics, rayminal.scale + 0.05)
		} else if rl.IsKeyPressed(rl.KeyboardKey.KP_SUBTRACT) {
			rayminal_set_scale(&rayminal, &rayminalGraphics, rayminal.scale - 0.05)
		}

		//update

		//render
		rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		x: i32 = startX
		y: i32 = startY

		//terminal
		if shaderMode {
			rayminal_use_shader(&rayminal, &rayminalGraphics, x, y)
		} else {
			src: rl.Rectangle = {0, 0, GLYPH_WIDTH, GLYPH_HEIGHT}
			dst: rl.Rectangle = {0.0, 0.0, GLYPH_WIDTH, GLYPH_HEIGHT}
			origin: rl.Vector2 = {0.0, 0.0}

			atlasCols := i32(rayminalGraphics.fontTexture.width) / i32(rayminal.glyphSize.x)

			for c_y: i32 = 0; c_y < i32(rayminal.rows); c_y += 1 {
				for c_x: i32 = 0; c_x < i32(rayminal.cols); c_x += 1 {
					glyphIndex := rayminal.buf[c_y * i32(rayminal.cols) + c_x]

					glyphY := f32(glyphIndex / u8(ATLAS_COLS))
					glyphX := f32(glyphIndex % u8(ATLAS_COLS))

					src.x = f32(glyphX * rayminal.glyphSize.x)
					src.y = f32(glyphY * rayminal.glyphSize.y)

					cellX := x + c_x * i32(rayminal.glyphSize.x)
					cellY := y + c_y * i32(rayminal.glyphSize.y)
					dst.x = f32(cellX)
					dst.y = f32(cellY)
					rl.DrawRectangleLines(
						cellX,
						cellY,
						i32(rayminal.glyphSize.x),
						i32(rayminal.glyphSize.y),
						rl.BLACK,
					)
					rl.DrawTexturePro(
						rayminalGraphics.fontTexture,
						src,
						dst,
						origin,
						0.0,
						rl.BLACK,
					)
				}
			}
		}


		//terminal frame:
		rl.DrawRectangleLines(
			startX,
			startY,
			i32(rayminal.terminalSizePx.x),
			i32(rayminal.terminalSizePx.y),
			rl.GREEN,
		)

		//CPU built for debug purpose
		draw_debug_info(dt, shaderMode, &rayminal)

		rl.EndDrawing()
	}
}

convert_index :: proc(codepoint: rune) -> int {
	return int(u8(codepoint) - u8(ASCII_START))
}

convert_fake_index :: proc(codepoint: rune) -> u8 {
	switch codepoint {
	case ' ':
		return 0
	case '!':
		return 1
	case '"':
		return 2
	case '#':
		return 3
	case '$':
		return 4
	case '%':
		return 5
	case 'A':
		return 6
	case 'B':
		return 7
	case 'C':
		return 8
	}

	return 0
}

draw_debug_info :: proc(dt: f32, mode: bool, rayminal: ^RayminalData) {
	x: i32 = SECTION_PADDING / 2
	y: i32 = 1

	fpsText := fmt.ctprintf("FPS: %d", rl.GetFPS())
	rl.DrawText(fpsText, x, y, FONTSIZE, rl.BLACK)
	y += i32(rl.MeasureTextEx(rl.GetFontDefault(), fpsText, f32(FONTSIZE), 1).y)

	modeText: cstring
	if mode {
		modeText = fmt.ctprintf("mode: shader")
	} else {
		modeText = fmt.ctprintf("mode: cpu")
	}

	rl.DrawText(modeText, x, y, FONTSIZE, rl.BLACK)
	y += i32(rl.MeasureTextEx(rl.GetFontDefault(), modeText, f32(FONTSIZE), 1).y)

	gridText := fmt.ctprintf("Grid: %ix%i", rayminal.cols, rayminal.rows)
	rl.DrawText(gridText, x, y, FONTSIZE, rl.BLACK)
	y += i32(rl.MeasureTextEx(rl.GetFontDefault(), gridText, f32(FONTSIZE), 1).y)

	scaleText := fmt.ctprintf("Scale: %f", rayminal.scale)
	rl.DrawText(scaleText, x, y, FONTSIZE, rl.BLACK)
	y += i32(rl.MeasureTextEx(rl.GetFontDefault(), scaleText, f32(FONTSIZE), 1).y)


	glyphSizeText := fmt.ctprintf(
		"GlyphSize: %2.f:%2.f",
		rayminal.baseGlyphSize.x,
		rayminal.baseGlyphSize.y,
	)
	rl.DrawText(glyphSizeText, x, y, FONTSIZE, rl.BLACK)
	y += i32(rl.MeasureTextEx(rl.GetFontDefault(), glyphSizeText, f32(FONTSIZE), 1).y)

	x = DEBUG_WIDTH
	rl.DrawLine(x, 0, x, WINDOW_HEIGHT, rl.BLACK)
}
