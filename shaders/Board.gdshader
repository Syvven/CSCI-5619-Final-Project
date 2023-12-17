shader_type spatial;
render_mode unshaded;

const bool[64] board = bool[64](
	true, false, true, false, true, false, true, false,
	false, true, false, true, false, true, false, true,
	true, false, true, false, true, false, true, false,
	false, true, false, true, false, true, false, true,
	true, false, true, false, true, false, true, false,
	false, true, false, true, false, true, false, true,
	true, false, true, false, true, false, true, false,
	false, true, false, true, false, true, false, true
);

void fragment() {
	int xcell = int(floor(UV.x * 8.0));
	int ycell = int(floor(UV.y * 8.0));
	
	float color = float(board[ycell*8+xcell]);
	ALBEDO.rgb = vec3(color, color, color);
}
