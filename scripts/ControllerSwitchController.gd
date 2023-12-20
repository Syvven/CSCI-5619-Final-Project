extends Node3D

var left_controller: XRController3D = null;
var right_controller: XRController3D = null;

var current_controller: XRController3D = null;
var use_right_controller = true;

var spindle: Node3D = null;
var marker: Node3D = null;
var game_controller: Node3D = null;
var xr_origin: XROrigin3D = null;

var last_left_pos: Vector3;
var last_right_pos: Vector3;

var cooldown_timer: Timer;
var on_cooldown = false;

var angle_threshold = 0.5;
var speed_threshold = 1.0;

var cooldown_time_delta = 1.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	left_controller = $%LeftController
	right_controller = $%RightController

	xr_origin = $%XROrigin3D

	last_left_pos = left_controller.position;
	last_right_pos = right_controller.position;

	current_controller = (
		right_controller
		if use_right_controller else 
		left_controller
	)

	spindle = $%Spindle
	marker = $%Marker 
	game_controller = $%GameController 

	# timer so that we don't change constantly when overlapped
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = cooldown_time_delta;
	self.add_child(cooldown_timer);
	cooldown_timer.connect("timeout", self.on_timer_timeout);


func on_timer_timeout():
	print("timer done");
	on_cooldown = false;
	cooldown_timer.stop();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var left_area: Area3D = left_controller.get_node("ChangeArea/Area3D") as Area3D;
	var right_area: Area3D = right_controller.get_node("ChangeArea/Area3D") as Area3D;

	var holding: bool = get_node("/root/Globals").active_grabbers.size() != 0;

	# don't switch if holding something or on cooldown timer
	if not holding and not on_cooldown and left_area.overlaps_area(right_area):
		var inv_delta = 1 / delta;

		# find the speed of the left and right controllers
		var left_diff = last_left_pos - left_controller.position;
		var left_speed = left_diff.length() * inv_delta;
		
		var right_diff = last_right_pos - right_controller.position;
		var right_speed = right_diff.length() * inv_delta;

		var left_dir = left_controller.basis.z;
		var right_dir = right_controller.basis.z;

		# the two should be sufficiently opposite directions
		var aligned: bool = abs(left_dir.dot(right_dir)) < angle_threshold;

		# if the speed of both controllers is beyond the threshold and are aligned
		#    then change the hands of each functionality
		if (right_speed > speed_threshold and left_speed > speed_threshold and aligned):
			print("both fast enough ", right_speed, " ", left_speed);
			on_cooldown = true;

			marker.use_right_controller = not marker.use_right_controller;
			spindle.use_right_controller = not spindle.use_right_controller;
			xr_origin.use_right_controller = not xr_origin.use_right_controller;
			game_controller.use_left_controller = not game_controller.use_left_controller;

			cooldown_timer.start();

	last_right_pos = right_controller.position;
	last_left_pos = left_controller.position;
