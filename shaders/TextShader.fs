#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D fontTexture;
uniform sampler2D bufTexture;

uniform vec2 rectPos;
uniform vec2 rectSize;
uniform float windowHeight;
uniform int terminalCols;
uniform int atlasCols;

 // todo receive glyph width/height as uniform
const float GLYPH_WIDTH = 16.0;
const float GLYPH_HEIGHT = 24.0;

out vec4 finalColor;

void main() {
    vec2 screenPos = vec2(gl_FragCoord.x, windowHeight - gl_FragCoord.y);
    vec2 localPos = screenPos - rectPos;

    if (any(lessThan(localPos, vec2(0.0))) || any(greaterThanEqual(localPos, rectSize))) discard;

    const vec2 cellSize = vec2(GLYPH_WIDTH, GLYPH_HEIGHT);
    vec2  cellIndex   = floor(localPos / cellSize);
    vec2  pixelInCell = mod(localPos, cellSize);

    int linearIndex = int(cellIndex.y * terminalCols + cellIndex.x);

    ivec2 bufSize = textureSize(bufTexture, 0);
    int cx = clamp(int(cellIndex.x), 0, bufSize.x - 1);
    int cy = clamp(int(cellIndex.y), 0, bufSize.y - 1);

    float val = texelFetch(bufTexture, ivec2(cx, cy), 0).r;
    int charIndex = int(round(val * 255.0));

    int atlasY =  int(floor(charIndex / atlasCols));
    int atlasX = charIndex % atlasCols;

    float cellOriginX = float(atlasX) * GLYPH_WIDTH;
    float cellOriginY = float(atlasY) * GLYPH_HEIGHT;

    float px = cellOriginX + pixelInCell.x;
    float py = cellOriginY + pixelInCell.y;

    vec2 texSize = vec2(textureSize(fontTexture, 0));

    vec2 uv = vec2(px, py) / texSize;

    vec4 glyph = texture(fontTexture, uv);
    finalColor = glyph * fragColor;
}
