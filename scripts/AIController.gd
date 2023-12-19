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

var thread := Thread.new();
var stats_ready := false;
var found_stats: Dictionary = {};

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root_board_scene = board_scene.instantiate()
	root_board_scene.setup_board(root_board);
	root_board_scene.gravity_scale = 0.0;
	root_board_scene.linear_velocity = Vector3();

	self.add_child(root_board_scene);

	update_next();


func update_root_board(board: PackedByteArray):
	root_board_scene.setup_board(board); 
	root_board_scene.position = Vector3();
	root_board = board;
	update_next();


func update_depth(new_depth: int):
	if new_depth == search_depth: return;
	search_depth = new_depth;
	update_next();


func instantiate_new_board_scene(board: PackedByteArray):
	var new_board_scene = board_scene.instantiate()
	new_board_scene.setup_board(board)
	new_board_scene.gravity_scale = 0.0;
	new_board_scene.linear_velocity = Vector3();

	self.add_child(new_board_scene)

	new_board_scene.position.x = self.get_children().size() * 1.1;


func get_valid_moves(
	board: PackedByteArray, y: int, x: int, idx: int
) -> Array:
	if y >= self.n_rows or y < 0 or x >= self.n_cols or x < 0: 
		return []

	var cell: int = board[idx]
	var cell_norm: int = cell ^ P.KINGED;
	# return will be array of [start_idx, final_idx, will_capture, capture_id]
	var check_moves: Array = []

	# up is negative, down is positive
	if cell & P.KINGED:
		if x - 1 >= 0 and y + 1 < self.n_rows:
			check_moves.append([idx + self.n_cols - 1, 1, -1])
		if x + 1 < self.n_cols and y + 1 < self.n_rows:
			check_moves.append([idx + self.n_cols + 1, 1, 1])
		if x - 1 >= 0 and y - 1 >= 0:
			check_moves.append([idx - self.n_cols - 1, -1, -1])
		if x + 1 < self.n_cols and y - 1 >= 0:
			check_moves.append([idx - self.n_cols + 1, -1, 1])
	else:
		# blue goes up, so should be idx - values
		# red goes down so should be idx + values
		var dir: int = -1 if cell & P.BLUE else 1;
		var within_board_y: int = (
			y + dir >= 0 if dir == -1 else y + dir < self.n_rows
		);
		var dir_cols: int = dir * self.n_cols;
		if x - 1 >= 0 and within_board_y:
			check_moves.append([idx + dir_cols - 1, dir, -1])
		if x + 1 < n_cols and within_board_y:
			check_moves.append([idx + dir_cols + 1, dir, 1])
	
	var return_moves = []
	for move in check_moves:
		var new_cell_norm: int = board[move[0]] ^ P.KINGED;
		if new_cell_norm & P.EMPTY: 
			# if empty, its always valid to go to
			return_moves.append([idx, move[0], false, -1]);
		elif new_cell_norm == cell_norm:
			# if the cells are same color, can't move
			continue 
		else:
			# the only other case should be that they are different colors
			var jump_col = x + move[2]*2;
			var jump_row = y + move[1]*2;
			if (jump_col >= 0 and jump_col < n_cols and 
				jump_row >= 0 and jump_row < n_rows):
				return_moves.append([
					idx, jump_row*n_cols + jump_row, true, move[0]
				])

	return return_moves;
	

func do_move_on_board(board: PackedByteArray, move: Array) -> Array:
	var cell: int = board[move[0]]
	var new_board: PackedByteArray = board.duplicate()

	# move the current piece to its new position
	new_board[move[1]] = cell

	# set where it was to empty
	new_board[move[0]] = P.EMPTY;

	# if there was a piece captured, empty the captured square
	if move[2]:
		new_board[move[3]] = P.EMPTY;
	
	var kinged = false;
	# if the piece is in the last row: king it
	if (move[1] < 8 and cell & P.BLUE) or (move[1] >= 56 and cell & P.RED):
		new_board[move[1]] |= P.KINGED;
		kinged = true;

	return [new_board, kinged];


func get_all_valid_moves(board: PackedByteArray, turn: int) -> Array:
	var idx := 0
	var all_valid_moves := []
	for y in range(self.n_rows):
		for x in range(self.n_cols):
			var cell = board[idx]
			idx += 1
			if (cell & P.EMPTY or cell & opposite_type[turn]): 
				continue
			all_valid_moves += get_valid_moves(board, y, x, idx-1);

	return all_valid_moves;


func recurse_generate_scenes(board: PackedByteArray, turn: int, level: int):
	# this function assumes that the root board has been updated
	if level == 0: return;

	var all_valid_moves = get_all_valid_moves(board, self.turn_color)

	for move in all_valid_moves:
		# move[0] -> from idx, move[1] -> to idx, 
		# move[2] -> piece captured, move[3] -> idx of piece captured
		
		var new_board = do_move_on_board(board, move);
		instantiate_new_board_scene(new_board[0]);

		# change turn color before recursing
		recurse_generate_scenes(new_board[0], opposite_type[turn], level-1);


func count_board_pieces(board: PackedByteArray) -> Dictionary:
	var counts = {
		P.BLUE: 0,
		P.RED: 0,
		P.KINGED: 0
	}

	for i in range(self.n_rows * self.n_cols):
		if board[i] & P.EMPTY: continue;

		counts[P.BLUE] += min(board[i] & P.BLUE, 1);
		counts[P.RED] += min(board[i] & P.RED, 1);
		counts[P.KINGED] += min(board[i] & P.KINGED, 1);
	
	return counts;


func update_next() -> void:
	# clear children to setup the new children
	for child in self.get_children():
		if child != root_board_scene: 
			child.free();
	
	recurse_generate_scenes(root_board, self.turn_color, self.search_depth);

	# TODO: Change this so it generates into a sort of cloud rather than
	#       just one ring
	var children: Array = self.get_children();
	var num_children: int = children.size();
	var curr_angle: float = 0.0;
	var num_in_ring = 11;
	var angle_inc: float = (2*PI) / num_in_ring;
	var dist_mod = 2;
	var counter = 0;
	for child in children:
		if child == root_board_scene: continue;
		if counter == num_in_ring: break;
		child.position.x = self.position.x + cos(curr_angle) * dist_mod; 
		child.position.z = self.position.z + sin(curr_angle) * dist_mod;
		curr_angle += angle_inc;
		counter += 1

	self.turn_color = self.opposite_type[self.turn_color]


func recurse_get_stats(
	board: PackedByteArray, turn: int, stats: Dictionary, depth: int, 
	recent_king_counts: Dictionary, num_since_board_change_with_king: int
):
	if depth == 5:
		return;

	stats["total_states"] += 1
	var counts = count_board_pieces(board);
	
	# base cases for wins, losses, etc...
	if counts[self.turn_color] == 0:
		stats["losses"] += 1
		return;

	if counts[self.opposite_type[self.turn_color]] == 0:
		stats["wins"] += 1
		return;

	# this matters that its last
	if counts[P.KINGED] == (counts[P.BLUE] + counts[P.RED]): 
		stats["draws"] += 1
		return;

	if recent_king_counts[P.KINGED] != 0:
		if (counts[P.KINGED] == recent_king_counts[P.KINGED] and
			counts[P.BLUE] == recent_king_counts[P.BLUE] and
			counts[P.RED] == recent_king_counts[P.RED]):
			num_since_board_change_with_king += 1;
		else:
			num_since_board_change_with_king = 0;

	if num_since_board_change_with_king == 14:
		return;

	# get moves for this current board
	var all_valid_moves = get_all_valid_moves(board, turn);
	
	# if you cause your opponent to have no moves, you win
	if all_valid_moves.size() == 0:
		if turn == self.turn_color:
			stats["losses"] += 1;
		else:
			stats["wins"] += 1;
		return;

	# just iterate through each move, recurse on the new board 
	for move in all_valid_moves:
		var new_board = do_move_on_board(board, move);
		recurse_get_stats(
			new_board[0], opposite_type[turn], stats, depth+1, 
			counts, num_since_board_change_with_king
		);
	
	# for threading stuff, say that you found stats when the first recursion ends
	if depth == 0:
		found_stats = stats;
		stats_ready = true;

# returns array of whether stats is present and the stats if it is
func poll_stats() -> Array:
	if stats_ready: 
		stats_ready = false;
		thread.wait_to_finish();
		return [true, found_stats]

	return [false, {}]


func start_stats(board: PackedByteArray):
	# TODO: calculate stats for given board
	#   stats should include:
	#	Total win branches, total loss branches, total draw branches
	#   total number of child states
	#	board score
	# this will be unfettered branch recursion until end of game
	# end of game conditions include:
	# 	all of one or other team's pieces gone (win/loss)
	#   all pieces on board kinged (draw)

	# wins, losses, draws, child states
	var stats = {
		"wins": 0, 
		"losses": 0, 
		"draws": 0, 
		"total_states": 0
	}
	var counts = count_board_pieces(board);
	stats_ready = false;
	found_stats = {}
	# starts thread so there's no lag in calculating
	thread.start(
		recurse_get_stats.bind(board, self.turn_color, stats, 0, counts, 0)
	)

	# recurse_get_stats(board, self.turn_color, stats, 0, counts, 0);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass


func _exit_tree():
	thread.wait_to_finish();
