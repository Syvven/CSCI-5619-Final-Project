extends Node3D

@export var dead_zone := 0.9

var input_vector:= Vector2.ZERO
var right_controller: XRController3D = null;
var left_controller: XRController3D = null;

var current_controller: XRController3D = null;
var other_controller: XRController3D = null;
var use_right_controller := true;

var origin: RigidBody3D = null;
var marker: Node3D = null;

var trigger_clicked := false;
var teleport := false;
var teleported := false;

# Called when the node enters the scene tree for the first time.
func _ready():
	self.right_controller = $%RightController
	self.left_controller = $%LeftController

	self.current_controller = self.right_controller

	marker = $%Marker

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Forward translation
	current_controller = (
		right_controller 
		if use_right_controller else 
		left_controller
	)

	other_controller = (
		left_controller 
		if use_right_controller else 
		right_controller
	)

	# do reconnecting of signals if it is needed
	if not current_controller.button_pressed.is_connected(self.button_pressed):
		current_controller.button_pressed.connect(self.button_pressed); 

	if not current_controller.input_vector2_changed.is_connected(self.process_input):
		current_controller.input_vector2_changed.connect(self.process_input); 
	
	if other_controller.button_pressed.is_connected(button_pressed):
		other_controller.button_pressed.disconnect(button_pressed);
	
	if other_controller.input_vector2_changed.is_connected(process_input):
		other_controller.input_vector2_changed.disconnect(process_input);
	
	if abs(input_vector.y) > dead_zone and teleport:
		self.global_position.x = marker.global_position.x;
		self.global_position.z = marker.global_position.z;
		teleport = false;
		teleported = true;

	teleport = false;

func process_input(input_name: String, input_value = null):
	if input_name == "primary":
		input_vector = input_value
	
func button_pressed(input_name: String):
	if input_name == "trigger_click":
		teleport = true;
