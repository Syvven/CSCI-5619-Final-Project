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

var collision_area: Area3D = null;
var board_mesh: MeshInstance3D = null;
var spot_marker: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	ai_ctrl_1 = $AIControllerOne
	depth_display = $DepthDisplayViewport/CanvasLayer/Button
	ai_ctrl_1.search_depth = depth

	collision_area = $BoardOutline/Area3D;
	board_mesh = $BoardOutline/GreenBoard;
	spot_marker = $BoardOutline
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# iterates through the grabbables in the scene
	for grabbable in get_tree().get_nodes_in_group("grabbable"):
		var grabbable_body = grabbable as RigidBody3D
		# checks if it overlaps
		if collision_area.overlaps_body(grabbable_body):
			var is_grabbed = false;
			# if its grabbed, don't do anything
			for grabber in get_node("/root/Globals").active_grabbers:
				if grabber.grabbed_object == grabbable:
					is_grabbed = true;
					break;
			
			# if its not grabbed, set its position and rotation, make the outline
			#   mesh invisible, and start the update thread in the board
			if not is_grabbed:
				grabbable.global_position = board_mesh.global_position;
				grabbable.rotation = board_mesh.rotation;

				spot_marker.visible = false;

				var previous_held = self.chosen_board;
				self.chosen_board = grabbable.board;
				if previous_held != chosen_board:
					update_root_board(self.chosen_board);

				break;
			elif grabbable_body.board == self.chosen_board:
				spot_marker.visible = true

	if not trigger_pressed: return;

	if abs(stick_value.x) <= change_depth_dead_zone or updated_depth:
		if abs(stick_value.x) < 1e-6: 
			updated_depth = false;
		return;

	depth = min(max(1, depth + sign(stick_value.x)), 2);
	ai_ctrl_1.update_depth(depth);
	updated_depth = true;

	depth_display.text = "< Display " + str(depth) + " >"; 


func update_root_board(board: PackedByteArray):
	ai_ctrl_1.update_root_board(board)


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
		
