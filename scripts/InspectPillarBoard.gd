extends Node3D

var held_board: Node3D = null;
var controller: Node3D = null;
var stats_display: Node3D = null;
var stats_button: Button = null;
var board_mesh: MeshInstance3D = null;
var stats_updated := false

var base_text = "------ Board Stats (Depth 5) ------\n"

# Called when the node enters the scene tree for the first time.
func _ready():
	controller = get_node("/root/Main/GameController");
	stats_display = get_node("/root/Main/StatsDisplay");
	stats_button = stats_display.get_node("SubViewport/CanvasLayer/Button")
	board_mesh = get_node("GreenBoard");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var occupied = false;
	var collision_area = $Area3D as Area3D
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
				occupied = true;
				grabbable.global_position = board_mesh.global_position;
				grabbable.rotation = board_mesh.rotation;

				self.visible = false;

				var previous_held = self.held_board;
				self.held_board = grabbable;
				if previous_held != grabbable:
					stats_updated = false;
					board_entered();

				break;
	
	# if not occupied, reset stuffs
	if not occupied:
		self.visible = true;
		self.held_board = null;
		stats_button.text = base_text + "No Board Present"
		return;

	self.visible = false;
	
	# if no stats yet,
	if not stats_updated:
		# attempt to poll the stats from the controller
		var stat_ret = controller.poll_stats();
		# if stats available, set stats display and proper variables
		if stat_ret[0]:
			var stats = stat_ret[1]
			stats_updated = true;
			stats_button.text = base_text + (
				"Wins: " + str(stats["wins"]) + "\n" +
				"Losses: " + str(stats["losses"]) + "\n" +
				"Draws: " + str(stats["draws"]) + "\n" + 
				"Total States: " + str(stats["total_states"])
			);
		else:
			stats_button.text = base_text + "Loading..."


func board_entered():
	# calls the controller to start the calculation thread
	if held_board != null:
		controller.start_stats_calculation(held_board);
