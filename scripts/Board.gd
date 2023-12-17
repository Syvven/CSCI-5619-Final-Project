extends RigidBody3D

class P:
	const EMPTY: int = 1;
	const BLUE: int = 2;
	const RED: int = 4;
	const KINGED: int = 8;

var board: PackedByteArray = [
	P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED,
	P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY,
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE,
	P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY,
]

var cell_dim: float = 0.125;
var half_cell_dim: float = cell_dim / 2;
var board_min: Vector3 = Vector3(-0.5 + half_cell_dim, 0, -0.5 + half_cell_dim);
var board_max: Vector3 = Vector3( 0.5 - half_cell_dim, 0,  0.5 - half_cell_dim);
var n_cols = 8; 
var n_rows = 8;

var red_pieces: Array;
var blue_pieces: Array;

func update_piece_meshes():
	var idx = 0;
	var curr_red = 0;
	var curr_blue = 0;
	for z in range(n_rows):
		for x in range(n_cols):
			var curr_cell = board[idx];
			idx += 1;

			if (curr_cell & P.EMPTY): continue;

			var curr_piece = null;
			if (curr_cell & P.RED):
				curr_piece = red_pieces[curr_red];
				curr_red += 1
			if (curr_cell & P.BLUE):
				curr_piece = blue_pieces[curr_blue];
				curr_blue += 1

			curr_piece.position.x = board_min.x + x*cell_dim
			curr_piece.position.z = board_min.z + z*cell_dim


func set_board(new_board: PackedByteArray):
	board = new_board;
	update_piece_meshes();


func setup_board(new_board = null):
	blue_pieces = $BluePieces.get_children();
	red_pieces = $RedPieces.get_children();

	if new_board != null: board = new_board;

	update_piece_meshes();


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_board()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
