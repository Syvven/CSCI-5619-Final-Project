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
var depth_display: Button = null;

var chosen_board: PackedByteArray;
var depth := 1

var trigger_pressed := false;
var change_depth_dead_zone := 0.9;
var updated_depth := false;
var stick_value := Vector2();

# Called when the node enters the scene tree for the first time.
func _ready():
	ai_ctrl_1 = $AIControllerOne
	depth_display = $DepthDisplayViewport/CanvasLayer/Button
	ai_ctrl_1.search_depth = depth
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# if Input.is_action_just_released("advance_game"):
	# 	print("Advancing Game");
	# 	# TODO: replace with not randomly chosen board
	# 	var children = ai_ctrl_1.get_children();
	# 	var random_index = randi() % children.size();
	# 	update_root_board_from_child(children[random_index]);
	if not trigger_pressed: return;

	if abs(stick_value.x) <= change_depth_dead_zone or updated_depth:
		if abs(stick_value.x) < 1e-6: 
			updated_depth = false;
		return;

	depth = min(max(1, depth + sign(stick_value.x)), 2);
	ai_ctrl_1.update_depth(depth);
	updated_depth = true;

	depth_display.text = "< Display " + str(depth) + " >"; 


func update_root_board_from_child(child: Node3D):
	ai_ctrl_1.update_root_board(child.board)


func start_stats_calculation(child: Node3D):
	return ai_ctrl_1.start_stats(child.board);

func poll_stats() -> Array:
	return ai_ctrl_1.poll_stats(); 


func button_down(input_name: String):
	if input_name == "trigger_click":
		trigger_pressed = true; 


func button_up(input_name: String):
	if input_name == "trigger_click":
		trigger_pressed = false; 


func process_input(input_name: String, value: Vector2):
	if input_name == "primary":
		stick_value = value;
		
