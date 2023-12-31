extends Node3D

@export var zoom_marker_speed := 1.01
var grabbed_object: RigidBody3D = null
var previous_transform: Transform3D
var leftController : XRController3D
var rightController : XRController3D

var current_controller: XRController3D = null;
var other_controller: XRController3D = null;
var use_right_controller := true;

var spindle : Node3D
var up : Vector3 
var use_model_front:= false
var zoom_marker:= false
var zoom_marker_zoom:= false
var zoom_marker_shrink:= false
var input_vector:= Vector2.ZERO
var show:= false
var change_color_dead_zone = 0.9
var change_color_flag = false
var prev_color :=Color(0,1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	leftController = $%LeftController as XRController3D
	rightController = $%RightController as XRController3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	current_controller = (
		rightController 
		if use_right_controller else 
		leftController
	)

	other_controller = (
		leftController 
		if use_right_controller else 
		rightController
	)
		
	# do reconnecting of signals if needed
	if not current_controller.button_pressed.is_connected(self.on_botton_pressed):
		current_controller.button_pressed.connect(self.on_botton_pressed); 

	if not current_controller.button_released.is_connected(self.on_botton_released):
		current_controller.button_released.connect(self.on_botton_released); 

	if not current_controller.input_vector2_changed.is_connected(self.process_input):
		current_controller.input_vector2_changed.connect(self.process_input); 

	if other_controller.button_pressed.is_connected(on_botton_pressed):
		other_controller.button_pressed.disconnect(on_botton_pressed);

	if other_controller.button_released.is_connected(on_botton_released):
		other_controller.button_released.disconnect(on_botton_released);

	if other_controller.input_vector2_changed.is_connected(process_input):
		other_controller.input_vector2_changed.disconnect(process_input);

	spindle = $%Spindle as Node3D
	up = Vector3(0, 1, 0)
	self.global_position = current_controller.global_position - (current_controller.basis.z * spindle.spindleLength);
	self.look_at(current_controller.global_position, up,use_model_front)
	if self.grabbed_object:
		self.grabbed_object.transform = self.global_transform * self.previous_transform.affine_inverse() * self.grabbed_object.transform
	self.previous_transform = self.global_transform
		
	if zoom_marker:
		var mesh = self.get_node("MeshInstance3D")
		var collision = self.get_node("Area3D/CollisionShape3D")
		if zoom_marker_zoom:
			mesh.set_scale(Vector3(mesh.scale.x * zoom_marker_speed, mesh.scale.y * zoom_marker_speed, mesh.scale.z * zoom_marker_speed))
			collision.set_scale(Vector3(collision.scale.x * zoom_marker_speed, collision.scale.y * zoom_marker_speed, collision.scale.z * zoom_marker_speed))
					
		if zoom_marker_shrink:
			mesh.set_scale(Vector3(mesh.scale.x / zoom_marker_speed, mesh.scale.y / zoom_marker_speed, mesh.scale.z / zoom_marker_speed))
			collision.set_scale(Vector3(collision.scale.x / zoom_marker_speed, collision.scale.y / zoom_marker_speed, collision.scale.z / zoom_marker_speed))
					
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	var collision_area = $Area3D as Area3D
	for grabbable in grabbables:
		var highlightmesh = grabbable.get_node("HighlightMesh")
		var grabbable_body = grabbable as RigidBody3D
		if collision_area.overlaps_body(grabbable_body) :
			highlightmesh.visible = true;
		if !collision_area.overlaps_body(grabbable_body) || self.grabbed_object:
			highlightmesh.visible = false;
			
	if self.grabbed_object:
		self.grabbed_object.look_at(current_controller.global_position, up)
		if show:
			self.grabbed_object.rotate_object_local(Vector3(1, 0, 0),deg_to_rad(-90))

	if self.input_vector.x <= self.change_color_dead_zone && self.input_vector.x >= -self.change_color_dead_zone && !show:
		change_color_flag = true
	if change_color_flag:
		var mesh = self.get_node("MeshInstance3D") as MeshInstance3D
		var material = mesh.mesh.surface_get_material(0)
		if self.input_vector.x > self.change_color_dead_zone && !show:
			prev_color = material.albedo_color
			var random_color = Color(fmod(randf(), 1.0), fmod(randf(), 1.0), fmod(randf(), 1.0))
			material.albedo_color = random_color
			change_color_flag = false
		if self.input_vector.x < -self.change_color_dead_zone && !show:
			material.albedo_color = prev_color
			change_color_flag = false
					
func on_botton_pressed(button_name: String) -> void:
	# Stop if we have not clicked the grip button or we already are grabbing an object
	if button_name == "by_button":
		zoom_marker_zoom = true
	elif button_name == "ax_button":
		zoom_marker_shrink = true
	elif button_name == "trigger_click":
		zoom_marker = true
	elif button_name == "primary_click":
		show = true

	if button_name != "grip_click" || self.grabbed_object != null:
		return
	
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	var collision_area = $Area3D as Area3D

	# Iterate through all grabbable objects and check if the collision area overlaps with them
	for grabbable in grabbables:

		# Cast the grabbable object to a RigidBody3D
		var grabbable_body = grabbable as RigidBody3D

		# Check to see if the grabber and grabbable collision shapes are intersecting
		if collision_area.overlaps_body(grabbable_body):
			
			# If the object is already grabbed by another grabber, release it first
			var globals = get_node("/root/Globals")
			for grabber in globals.active_grabbers:
				if grabber.grabbed_object == grabbable_body:
					grabber.grabbed_object = null
					globals.active_grabbers.remove_at(globals.active_grabbers.find(self))
					break

			# Freeze the object physics and then grab it
			self.grabbed_object = grabbable_body
			globals.active_grabbers.push_back(self)
			
func on_botton_released(button_name: String) -> void:
	# Stop if we have not clicked the grip button or we have no current grabbed object
	if button_name == "by_button":
		zoom_marker_zoom = false
	elif button_name == "ax_button":
		zoom_marker_shrink = false
	elif button_name == "trigger_click":
		zoom_marker = false
	elif button_name == "primary_click":
		show = false

	if button_name != "grip_click" || self.grabbed_object == null:
		return

	# Release the grabbed object and unfreeze it
	self.grabbed_object.linear_velocity = Vector3(0, 0, 0)
	self.grabbed_object.angular_velocity = Vector3.ZERO
	self.grabbed_object = null

	# Remove this grabber from the array of active grabbers
	var globals = get_node("/root/Globals")
	globals.active_grabbers.remove_at(globals.active_grabbers.find(self))


func process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value
