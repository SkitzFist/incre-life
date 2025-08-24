package main

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 600


DEBUG_WIDTH :: 100
FONTSIZE: i32 : 16
SECTION_PADDING :: 20

GLYPH_WIDTH :: 16
GLYPH_HEIGHT :: 24

TERMINAL_COLS :: 200
TERMINAL_ROWS :: 100

TERMINAL_WIDTH :: GLYPH_WIDTH * TERMINAL_COLS
TERMINAL_HEIGHT :: GLYPH_HEIGHT * TERMINAL_ROWS

ASCII_START: int : 33

BUF: [TERMINAL_COLS * TERMINAL_HEIGHT]u8

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Incre-Life")
	rl.SetWindowState({rl.ConfigFlag.WINDOW_RESIZABLE})

	//font image
	fontImage: rl.Image = rl.LoadImage("assets/fonts/Skz-Font.png")
	defer rl.UnloadImage(fontImage)

	fontTexture: rl.Texture2D = rl.LoadTextureFromImage(fontImage)
	defer rl.UnloadTexture(fontTexture)

	rl.SetTextureFilter(fontTexture, rl.TextureFilter.POINT)
	rl.SetTextureWrap(fontTexture, rl.TextureWrap.CLAMP)

	// BUF
	for i in 0 ..< len(BUF) {
		BUF[i] = u8(i % 9)
	}

	bufImage: rl.Image = {
		data    = raw_data(BUF[:]),
		width   = TERMINAL_COLS,
		height  = TERMINAL_ROWS,
		mipmaps = 1,
		format  = rl.PixelFormat.UNCOMPRESSED_GRAYSCALE,
	}

	bufTexture := rl.LoadTextureFromImage(bufImage)
	defer rl.UnloadTexture(bufTexture)

	rl.SetTextureFilter(bufTexture, rl.TextureFilter.POINT)
	rl.SetTextureWrap(bufTexture, rl.TextureWrap.CLAMP)

	// shader
	textShader := rl.LoadShader("shaders/TextShader.vs", "shaders/TextShader.fs")
	defer rl.UnloadShader(textShader)

	fontTextureLoc := rl.GetShaderLocation(textShader, "fontTexture")
	bufTextureLoc := rl.GetShaderLocation(textShader, "bufTexture")
	rl.SetShaderValueTexture(textShader, fontTextureLoc, fontTexture)
	rl.SetShaderValueTexture(textShader, bufTextureLoc, bufTexture)

	rectPosLoc := rl.GetShaderLocation(textShader, "rectPos")
	rectSizeLoc := rl.GetShaderLocation(textShader, "rectSize")
	windowHeightLoc := rl.GetShaderLocation(textShader, "windowHeight")
	terminalColsLoc := rl.GetShaderLocation(textShader, "terminalCols")
	atlasColsLoc := rl.GetShaderLocation(textShader, "atlasCols")

	height := f32(WINDOW_HEIGHT)
	rl.SetShaderValue(textShader, windowHeightLoc, &height, rl.ShaderUniformDataType.FLOAT)

	terminalCols := int(TERMINAL_COLS)
	rl.SetShaderValue(textShader, terminalColsLoc, &terminalCols, rl.ShaderUniformDataType.INT)

	atlasCols := 3
	rl.SetShaderValue(textShader, atlasColsLoc, &atlasCols, rl.ShaderUniformDataType.INT)

	shaderMode := true

	for !rl.WindowShouldClose() {

		if rl.IsWindowResized() {
			height := f32(rl.GetScreenHeight())
			rl.SetShaderValue(textShader, windowHeightLoc, &height, rl.ShaderUniformDataType.FLOAT)
		}
		dt := rl.GetFrameTime()
		//input
		if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
			rl.CloseWindow()
			break
		} else if rl.IsKeyPressed(rl.KeyboardKey.TAB) {
			shaderMode = !shaderMode
		}

		//update

		//render
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)


		x: i32 = DEBUG_WIDTH + SECTION_PADDING * 2
		y: i32 = 10

		//font;texture
		rl.DrawTexture(fontTexture, x, y, rl.BLACK)
		x += fontTexture.width + SECTION_PADDING
		//x += rl.MeasureText(fontTextureText, FONTSIZE) + SECTION_PADDING
		rl.DrawLine(x, 0, x, WINDOW_HEIGHT, rl.BLACK)
		x += SECTION_PADDING

		//terminal
		if shaderMode {

			rl.BeginShaderMode(textShader)
			pos: [2]f32 = {f32(x), f32(y)}
			size: [2]f32 = {f32(TERMINAL_WIDTH), f32(TERMINAL_HEIGHT)}

			rl.SetShaderValueTexture(textShader, fontTextureLoc, fontTexture)
			rl.SetShaderValueTexture(textShader, bufTextureLoc, bufTexture)
			rl.SetShaderValue(textShader, rectPosLoc, &pos, rl.ShaderUniformDataType.VEC2)
			rl.SetShaderValue(textShader, rectSizeLoc, &size, rl.ShaderUniformDataType.VEC2)
			rl.DrawRectangle(x, y, TERMINAL_WIDTH, TERMINAL_HEIGHT, rl.BLACK)
			rl.EndShaderMode()

		} else {
			src: rl.Rectangle = {0, 0, GLYPH_WIDTH, GLYPH_HEIGHT}
			dst: rl.Rectangle = {0.0, 0.0, GLYPH_WIDTH, GLYPH_HEIGHT}
			origin: rl.Vector2 = {0.0, 0.0}

			for c_y: i32 = 0; c_y < TERMINAL_ROWS; c_y += 1 {
				for c_x: i32 = 0; c_x < TERMINAL_COLS; c_x += 1 {
					glyphIndex := BUF[c_y * TERMINAL_COLS + c_x]

					glyphY := glyphIndex / u8(atlasCols)
					glyphX := glyphIndex % u8(atlasCols)

					src.x = f32(glyphX * GLYPH_WIDTH)
					src.y = f32(glyphY * GLYPH_HEIGHT)

					cellX := x + c_x * i32(GLYPH_WIDTH)
					cellY := y + c_y * i32(GLYPH_HEIGHT)
					dst.x = f32(cellX)
					dst.y = f32(cellY)
					//rl.DrawRectangleLines(cellX, cellY, GLYPH_WIDTH, GLYPH_HEIGHT, rl.BLACK)
					rl.DrawTexturePro(fontTexture, src, dst, origin, 0.0, rl.BLACK)
				}
			}
		}

		//CPU built for debug purpose


		draw_debug_info(dt, shaderMode)
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

draw_debug_info :: proc(dt: f32, mode: bool) {
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

	gridText := fmt.ctprintf("Grid: %ix%i", TERMINAL_COLS, TERMINAL_ROWS)
	rl.DrawText(gridText, x, y, FONTSIZE, rl.BLACK)

	x = DEBUG_WIDTH + SECTION_PADDING
	rl.DrawLine(x, 0, x, WINDOW_HEIGHT, rl.BLACK)
}
