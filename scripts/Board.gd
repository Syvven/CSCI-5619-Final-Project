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
var king_red_pieces: Array;
var king_blue_pieces: Array;

var parent_scene: RigidBody3D = null;
var next_scenes: Array = []
var cylinders: Array = []

var piece_height = 2 * 0.01;

func update_piece_meshes():
	# sets piece positions based on the provided board state
	var idx = 0;
	var curr_red = 0;
	var curr_blue = 0;

	for i in range(king_blue_pieces.size()):
		# assumes red and blue kings are same size (which they are)
		king_blue_pieces[i].visible = false;
		king_red_pieces[i].visible = false;

	for z in range(n_rows):
		for x in range(n_cols):
			var curr_cell = board[idx];
			idx += 1;

			if (curr_cell & P.EMPTY): continue;

			var curr_piece = null;
			var king_piece = null;
			if (curr_cell & P.RED):
				curr_piece = red_pieces[curr_red];
				if curr_cell & P.KINGED:
					king_piece = king_red_pieces[curr_red];
				curr_red += 1

			if (curr_cell & P.BLUE):
				curr_piece = blue_pieces[curr_blue];
				if curr_cell & P.KINGED:
					king_piece = king_blue_pieces[curr_blue];
				curr_blue += 1


			var posx = board_min.x + x*cell_dim;
			var posz = board_min.z + z*cell_dim

			curr_piece.position.x = posx;
			curr_piece.position.z = posz;

			if (king_piece != null):
				var posy = curr_piece.position.y + 0.5*piece_height + 0.01;
				king_piece.visible = true;
				king_piece.position = Vector3(posx, posy, posz);

	while (curr_red < red_pieces.size()):
		red_pieces[curr_red].visible = false;
		curr_red += 1;

	while (curr_blue < blue_pieces.size()):
		blue_pieces[curr_blue].visible = false;
		curr_blue += 1;


func set_board(new_board: PackedByteArray):
	board = new_board;
	update_piece_meshes();


func setup_board(parent: RigidBody3D, new_board = null):
	blue_pieces = $BluePieces.get_children();
	red_pieces = $RedPieces.get_children();

	king_blue_pieces = $BlueKings.get_children();
	king_red_pieces = $RedKings.get_children();

	self.parent_scene = parent;

	if new_board != null: board = new_board;

	update_piece_meshes();


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_board(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.linear_velocity = Vector3();
