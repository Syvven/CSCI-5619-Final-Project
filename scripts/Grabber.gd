extends Node3D

signal object_grabbed(s: Vector3)

var grabbed_object: RigidBody3D = null
var previous_transform: Transform3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# var mesh = rigid_body.get_node("HighlightMesh");
	# mesh.visible = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Copy the grabber's relative movement since the last frame to to the grabbed object
	if self.grabbed_object:
		self.grabbed_object.transform = (
			self.global_transform * 
			self.previous_transform.inverse() * 
			self.grabbed_object.transform
		)

	self.previous_transform = self.global_transform

func _on_button_pressed(button_name: String) -> void:
	# Stop if we have not clicked the grip button or we already are grabbing an object
	if button_name != "grip_click" || self.grabbed_object != null:
		return

	# print(button_name);
	# if button_name == "ax_button" and grabbed_object != null:
	# 	for y in range(8):
	# 		var br = ""
	# 		for x in range(8):
	# 			br += str(grabbed_object.board[y*8 + x]) + " "  
	# 		print(br);
	
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
					globals.active_grabbers.remove_at(
						globals.active_grabbers.find(self)
					)
					break

			
			self.grabbed_object = grabbable_body
			# Freeze the object physics and then grab it
			grabbed_object.linear_velocity = Vector3();
			grabbed_object.gravity_scale = 0.0;
			globals.active_grabbers.push_back(self)
			var mesh: Node3D = self.grabbed_object.get_node("CollisionShape3D")
			object_grabbed.emit(mesh.scale);

	
func _on_button_released(button_name: String) -> void:
	# Stop if we have not clicked the grip button or we have no current grabbed object
	if button_name != "grip_click" || self.grabbed_object == null:
		return

	# Release the grabbed object and unfreeze it
	self.grabbed_object.linear_velocity = Vector3(0, 0, 0)
	self.grabbed_object.angular_velocity = Vector3.ZERO
	self.grabbed_object = null

	# Remove this grabber from the array of active grabbers
	var globals = get_node("/root/Globals")
	globals.active_grabbers.remove_at(globals.active_grabbers.find(self))
