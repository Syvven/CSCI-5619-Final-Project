extends Node3D

class Player:
	const HUMAN := 1;
	const AI := 2;

class Turn:
	const RED := 4
	const BLUE := 8

# Human starts first as color red 
var current_turn = Turn.RED;

var ai_ctrl_1: Node3D = null;
var ai_ctrl_2: Node3D = null;

var chosen_board: PackedByteArray;

# Called when the node enters the scene tree for the first time.
func _ready():
	ai_ctrl_1 = $AIControllerOne
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("advance_game"):
		print("Advancing Game");
		# TODO: replace with not randomly chosen board
		var children = ai_ctrl_1.get_children();
		var random_index = randi() % children.size();
		update_root_board_from_child(children[random_index]);


func update_root_board_from_child(child: Node3D):
	ai_ctrl_1.update_root_board(child.board)
