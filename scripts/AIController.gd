extends Node3D

class P:
	const EMPTY: int = 1;
	const BLUE: int = 2;
	const RED: int = 4;
	const KINGED: int = 8;

var root_board: PackedByteArray = [
	P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED,
	P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY, P.RED, P.EMPTY,
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, P.EMPTY, 
	P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE,
	P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY, P.BLUE, P.EMPTY,
]

var opposite_type := {
	P.RED: P.BLUE,
	P.BLUE: P.RED
};

var n_cols := 8; 
var n_rows := 8;

var child_boards := []

var board_scene := preload("res://scenes/Board.tscn")
var root_board_scene: RigidBody3D = null

var search_depth := 1;

var turn_color: int = P.BLUE;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root_board_scene = board_scene.instantiate()
	root_board_scene.setup_board(root_board);
	root_board_scene.freeze = true;

	self.add_child(root_board_scene);

	update_next();


func update_root_board(board: PackedByteArray):
	root_board_scene.setup_board(board); 
	root_board_scene.position = Vector3();
	root_board = board;
	update_next();


func instantiate_new_board_scene(board: PackedByteArray):
	var new_board_scene = board_scene.instantiate()
	new_board_scene.setup_board(board)
	new_board_scene.freeze = true;

	self.add_child(new_board_scene)

	new_board_scene.position.x = self.get_children().size() * 1.1;


func get_valid_moves(
	board: PackedByteArray, y: int, x: int, idx: int
) -> Array:
	if y >= self.n_rows or y < 0 or x >= self.n_cols or x < 0: 
		return []

	var cell: int = board[idx]
	var cell_norm: int = cell ^ P.KINGED;
	# return will be array of (final_idx, will_capture, capture_idx) tuples
	var check_moves: Array = []

	# up is negative, down is positive
	if cell & P.KINGED:
		if x - 1 >= 0 and y + 1 < self.n_rows:
			check_moves.append(idx + self.n_cols - 1)
		if x + 1 < self.n_cols and y + 1 < self.n_rows:
			check_moves.append(idx + self.n_cols + 1)
		if x - 1 >= 0 and y - 1 >= 0:
			check_moves.append(idx - self.n_cols - 1)
		if x + 1 < self.n_cols and y - 1 >= 0:
			check_moves.append(idx - self.n_cols + 1)
	else:
		# blue goes up, so should be idx - values
		# red goes down so should be idx + values
		var dir: int = -1 if cell & P.BLUE else 1;
		var within_board_y: int = (
			y + dir >= 0 if dir == -1 else y + dir < self.n_rows
		);
		var dir_cols: int = dir * self.n_cols;
		if x - 1 >= 0 and within_board_y:
			check_moves.append(idx + dir_cols - 1)
		if x + 1 < n_cols and within_board_y:
			check_moves.append(idx + dir_cols + 1)
	
	var return_moves = []
	for new_idx in check_moves:
		var new_cell_norm: int = board[new_idx] ^ P.KINGED;
		if new_cell_norm & P.EMPTY: 
			# if empty, its always valid to go to
			return_moves.append([idx, new_idx, false, -1]);
		elif new_cell_norm == cell_norm:
			# if the cells are same color, can't move
			continue 
		else:
			# the only other case should be that they are different colors
			pass

	return return_moves;
	

func recurse_generate_scenes(board: PackedByteArray, level: int):
	# this function assumes that the root board has been updated
	if level == 0: return;

	var idx := 0
	var all_valid_moves := []
	for y in range(self.n_rows):
		for x in range(self.n_cols):
			var cell = board[idx]
			idx += 1
			if (cell & P.EMPTY or cell & opposite_type[self.turn_color]): 
				continue
			all_valid_moves += get_valid_moves(board, y, x, idx-1);

	for move in all_valid_moves:
		# move[0] -> from idx, move[1] -> to idx, 
		# move[2] -> piece captured, move[3] -> idx of piece captured
		var cell: int = board[move[0]]
		var new_board: PackedByteArray = board.duplicate()
		new_board[move[1]] = cell
		new_board[move[0]] = P.EMPTY;

		instantiate_new_board_scene(new_board);
		recurse_generate_scenes(new_board, level-1);


func update_next() -> void:
	# clear children to setup the new children
	for child in self.get_children():
		if child != root_board_scene: 
			child.free();
	
	recurse_generate_scenes(root_board, self.search_depth);

	var children: Array = self.get_children();
	var num_children: int = children.size();
	var curr_angle: float = 0.0;
	var num_in_ring = 11;
	var angle_inc: float = (2*PI) / num_in_ring;
	var dist_mod = 4;
	var counter = 0;
	for child in children:
		if child == root_board_scene: continue;
		if counter == num_in_ring: break;
		child.position.x = self.position.x + cos(curr_angle) * dist_mod; 
		child.position.z = self.position.z + sin(curr_angle) * dist_mod;
		curr_angle += angle_inc;
		counter += 1

	self.turn_color = self.opposite_type[self.turn_color]
	print(num_children)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass
