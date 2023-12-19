extends Node3D

@export var max_speed := 2.5
@export var dead_zone := 0.2

@export var smooth_turn_speed := 45.0
@export var smooth_turn_dead_zone := 0.2

@export var snap_turned := false
@export var snap_turn_angle := 45.0
@export var snap_turn_dead_zone := 0.9 

var turn_timer = 0.0

var hand_directed = false
var snap_turn = false

var input_vector:= Vector2.ZERO
var camera: XRCamera3D = null;
var right_controller: XRController3D = null;
var left_controller: XRController3D = null;

var current_controller: XRController3D = null;

var body: RigidBody3D = null;

var trigger_clicked := false;

# Called when the node enters the scene tree for the first time.
func _ready():
	self.camera = $XRCamera3D
	self.right_controller = $RightController
	self.left_controller = $LeftController

	for child in self.right_controller.get_children():
		if is_instance_of(child, Area3D):
			var mat = child.get_node("MeshInstance3D").get_active_material(0)
			
			match child.name:
				"SmoothTurn":
					mat.albedo_color = (
						Color(0, 1, 0, mat.albedo_color.a)
						if not self.snap_turn else 
						Color(1, 0, 0, mat.albedo_color.a)
					)
				"SnapTurn":
					mat.albedo_color = (
						Color(0, 1, 0, mat.albedo_color.a)
						if self.snap_turn else 
						Color(1, 0, 0, mat.albedo_color.a)
					)
				"HandMove":
					mat.albedo_color = (
						Color(0, 1, 0, mat.albedo_color.a)
						if self.hand_directed else 
						Color(1, 0, 0, mat.albedo_color.a)
					)
				"ViewMove":
					mat.albedo_color = (
						Color(0, 1, 0, mat.albedo_color.a)
						if not self.hand_directed else 
						Color(1, 0, 0, mat.albedo_color.a)
					)		
				_: continue

	self.current_controller = self.right_controller

	self.body = $Body

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Forward translation
	if trigger_clicked: return;

	var mov_val = -self.input_vector.y
	var turn_val = -self.input_vector.x

	# self.body.global_position.x = self.camera.global_position.x
	# self.body.global_position.z = self.camera.global_position.z

	if abs(mov_val) > self.dead_zone:
		var movement_vector = Vector3(0, 0, max_speed * mov_val * delta)
		self.position += movement_vector.rotated(
			Vector3.UP, self.current_controller.global_rotation.y
						if self.hand_directed
						else self.camera.global_rotation.y
		)

	# get deadzone of the turning type and return if inside the deadzone
	var turn_dead_zone = self.snap_turn_dead_zone if self.snap_turn else self.smooth_turn_dead_zone
	if abs(turn_val) <= turn_dead_zone:
		if abs(turn_val) < 1e-6: 
			self.snap_turned = false;
		return;

	# Smooth turn
	if not self.snap_turn:
		self.turn_timer = 0.0;
		# move to the position of the camera
		self.translate(self.camera.position)

		# rotate about the camera's position
		self.rotate(Vector3.UP, deg_to_rad(smooth_turn_speed) * turn_val * delta)

		# reverse the translation to move back to the original position
		self.translate(self.camera.position * -1)
		return;

	if self.snap_turned: return;

	self.snap_turned = true;

	self.translate(self.camera.position)
	self.rotate(Vector3.UP, deg_to_rad(snap_turn_angle) * sign(turn_val))
	self.translate(self.camera.position * -1);

func process_input(input_name: String, input_value = null):
	if input_name == "primary":
		input_vector = input_value

		if not hand_directed:
			return 

		self.current_controller = (
			self.left_controller 
			if self.left_controller.is_button_pressed(input_name) else
			self.right_controller)
	
func button_pressed(input_name: String):
	if input_name == "ax_button":
		self.hand_directed = not self.hand_directed
	elif input_name == "by_button":
		self.snap_turn = not self.snap_turn
	elif input_name == "trigger_click":
		trigger_clicked = true;
		# var used_controller = (
		# 	self.left_controller 
		# 	if self.left_controller.is_button_pressed(input_name) else 
		# 	self.right_controller
		# )

		# var other_controller = (
		# 	self.right_controller 
		# 	if self.left_controller.is_button_pressed(input_name) else 
		# 	self.left_controller
		# )
		
		# var selector = used_controller.get_node("Selector")
		# for child in other_controller.get_children():
		# 	if is_instance_of(child, Area3D):
		# 		var overlaps = child.overlaps_body(selector)

		# 		if not overlaps: continue

		# 		var mat = child.get_node("MeshInstance3D").get_active_material(0)
		# 		mat.albedo_color = Color(0, 1, 0, mat.albedo_color.a)
		# 		var otherNode = "";
		# 		match child.name:
		# 			"SmoothTurn":
		# 				self.snap_turn = false
		# 				otherNode = "SnapTurn"
		# 			"SnapTurn":
		# 				self.snap_turn = true
		# 				otherNode = "SmoothTurn"
		# 			"HandMove":
		# 				self.hand_directed = true
		# 				otherNode = "ViewMove"
		# 			"ViewMove":
		# 				otherNode = "HandMove"
		# 				self.hand_directed = false
		# 			_: continue
					
		# 		var omat = used_controller.get_node(otherNode).get_node("MeshInstance3D").get_active_material(0)
		# 		omat.albedo_color = Color(1, 0, 0, omat.albedo_color.a)

		# 		return

func button_released(input_name: String):
	if input_name == "trigger_click":
		trigger_clicked = false;
