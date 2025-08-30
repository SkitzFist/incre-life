package main

import "core:math"

import rl "vendor:raylib"

@(private = "file")
MAX_BUF_SIZE :: 200 * 200

RayminalData :: struct {
	cols, rows:     i32,
	length:         i32,
	scale:          f32,
	baseGlyphSize:  rl.Vector2,
	glyphSize:      rl.Vector2,
	terminalSizePx: rl.Vector2,
	buf:            [MAX_BUF_SIZE]u8,
}

create_rayminal_data_default :: proc(cols, rows: i32, glyphSize: rl.Vector2) -> RayminalData {
	return {
		cols = cols,
		rows = rows,
		length = cols * rows,
		scale = 1.0,
		baseGlyphSize = glyphSize,
		glyphSize = glyphSize,
		terminalSizePx = rl.Vector2{f32(cols) * glyphSize.x, f32(rows) * glyphSize.y},
	}
}

create_rayminal_data_full :: proc(glyphSize: rl.Vector2, width, height: int) -> RayminalData {
	cols := i32(math.floor(f32(width) / glyphSize.x))
	rows := i32(math.floor(f32(height) / glyphSize.y))
	length := cols * rows
	scale: f32 = 1.0
	terminalSizePx: rl.Vector2 = {f32(width), f32(height)}

	return {
		cols = cols,
		rows = rows,
		length = length,
		scale = scale,
		glyphSize = glyphSize,
		baseGlyphSize = glyphSize,
		terminalSizePx = terminalSizePx,
	}

}

RayminalGraphics :: struct {
	shader:           rl.Shader,
	fontImage:        rl.Image,
	fontTexture:      rl.Texture2D,
	bufferImage:      rl.Image,
	bufferTexture:    rl.Texture2D,

	//locs
	fontTextureLoc:   i32,
	bufferTextureLoc: i32,
	posLoc:           i32,
	sizeLoc:          i32,
	windowHeightLoc:  i32,
	atlasColsLoc:     i32,
	scaleLoc:         i32,
}

create_rayminal_graphics :: proc(
	vertexShaderPath: cstring,
	fragmentShaderPath: cstring,
	fontPath: cstring,
	rayminal: ^RayminalData,
) -> RayminalGraphics {

	//font
	fontImage := rl.LoadImage(fontPath)
	fontTexture := rl.LoadTextureFromImage(fontImage)
	rl.SetTextureFilter(fontTexture, rl.TextureFilter.POINT)
	rl.SetTextureWrap(fontTexture, rl.TextureWrap.CLAMP)

	// buffer
	bufferImage: rl.Image = {
		data    = raw_data(rayminal.buf[:rayminal.length]),
		width   = i32(rayminal.cols),
		height  = i32(rayminal.rows),
		mipmaps = 1,
		format  = rl.PixelFormat.UNCOMPRESSED_GRAYSCALE,
	}
	bufferTexture := rl.LoadTextureFromImage(bufferImage)
	rl.SetTextureFilter(bufferTexture, rl.TextureFilter.POINT)
	rl.SetTextureWrap(bufferTexture, rl.TextureWrap.CLAMP)

	shader := rl.LoadShader(vertexShaderPath, fragmentShaderPath)

	fontTextureLoc := rl.GetShaderLocation(shader, "fontTexture")
	bufTextureLoc := rl.GetShaderLocation(shader, "bufTexture")
	rl.SetShaderValueTexture(shader, fontTextureLoc, fontTexture)
	rl.SetShaderValueTexture(shader, bufTextureLoc, bufferTexture)

	posLoc := rl.GetShaderLocation(shader, "rectPos")
	sizeLoc := rl.GetShaderLocation(shader, "rectSize")
	windowHeightLoc := rl.GetShaderLocation(shader, "windowHeight")
	atlasColsLoc := rl.GetShaderLocation(shader, "atlasCols")
	scaleLoc := rl.GetShaderLocation(shader, "scale")

	atlasCols := i32(fontTexture.width) / i32(rayminal.glyphSize.x)
	rl.SetShaderValue(shader, atlasColsLoc, &atlasCols, rl.ShaderUniformDataType.INT)

	windowHeight := f32(rl.GetScreenHeight())
	rl.SetShaderValue(shader, windowHeightLoc, &windowHeight, rl.ShaderUniformDataType.FLOAT)

	rl.SetShaderValue(shader, scaleLoc, &rayminal.scale, rl.ShaderUniformDataType.FLOAT)

	return {
		shader = shader,
		fontImage = fontImage,
		fontTexture = fontTexture,
		bufferImage = bufferImage,
		bufferTexture = bufferTexture,
		fontTextureLoc = fontTextureLoc,
		bufferTextureLoc = bufTextureLoc,
		posLoc = posLoc,
		sizeLoc = sizeLoc,
		windowHeightLoc = windowHeightLoc,
		atlasColsLoc = atlasColsLoc,
		scaleLoc = scaleLoc,
	}
}

rayminal_on_resize :: proc(data: ^RayminalData, graphics: ^RayminalGraphics) {
	//todo recompute
	windowHeight := f32(rl.GetScreenHeight())
	rl.SetShaderValue(
		graphics.shader,
		graphics.windowHeightLoc,
		&windowHeight,
		rl.ShaderUniformDataType.FLOAT,
	)
}

rayminal_set_scale :: proc(data: ^RayminalData, graphics: ^RayminalGraphics, scale: f32) {
	//reset default
	data.glyphSize.xy = scale * data.baseGlyphSize

	data.scale = scale

	data.cols = i32(math.floor(data.terminalSizePx.x / data.glyphSize.x))
	data.rows = i32(math.floor(data.terminalSizePx.y / data.glyphSize.y))
	data.length = data.cols * data.rows

	// 
	graphics.bufferImage.data = raw_data(data.buf[:data.length])
	graphics.bufferImage.width = i32(data.cols)
	graphics.bufferImage.height = i32(data.rows)

	rl.UnloadTexture(graphics.bufferTexture)

	graphics.bufferTexture = rl.LoadTextureFromImage(graphics.bufferImage)
	rl.SetShaderValueTexture(graphics.shader, graphics.bufferTextureLoc, graphics.bufferTexture)

	rl.SetShaderValue(
		graphics.shader,
		graphics.scaleLoc,
		&data.scale,
		rl.ShaderUniformDataType.FLOAT,
	)
}

rayminal_use_shader :: proc(data: ^RayminalData, graphics: ^RayminalGraphics, x, y: i32) {
	rl.BeginShaderMode(graphics.shader)
	pos: [2]f32 = {f32(x), f32(y)}
	size: [2]f32 = {data.terminalSizePx.x, data.terminalSizePx.y}

	rl.SetShaderValueTexture(graphics.shader, graphics.fontTextureLoc, graphics.fontTexture)
	rl.SetShaderValueTexture(graphics.shader, graphics.bufferTextureLoc, graphics.bufferTexture)
	rl.SetShaderValue(graphics.shader, graphics.posLoc, &pos, rl.ShaderUniformDataType.VEC2)
	rl.SetShaderValue(graphics.shader, graphics.sizeLoc, &size, rl.ShaderUniformDataType.VEC2)
	rl.DrawRectangle(x, y, i32(data.terminalSizePx.x), i32(data.terminalSizePx.y), rl.BLACK)
	rl.EndShaderMode()
}

rayminal_update_buffer_texture :: proc(data: ^RayminalData, gfx: ^RayminalGraphics) {
	rl.UpdateTexture(gfx.bufferTexture, raw_data(data.buf[:data.length]))
}
