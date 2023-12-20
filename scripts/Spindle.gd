extends Node3D

@export var stretch_speed := 1.01
var leftController : XRController3D
var rightController : XRController3D

var current_controller: XRController3D = null;
var other_controller: XRController3D = null
var use_right_controller := true;

var up : Vector3 
var use_model_front:= false
var stretch_model:= false
var stretch_model_stretch:= false
var stretch_model_shorten:= false
var spindleLength = 1.0
var input_vector:= Vector2.ZERO

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

	# reconnecting of signals if needed
	if not current_controller.button_pressed.is_connected(self.on_botton_pressed):
		current_controller.button_pressed.connect(self.on_botton_pressed); 

	if not current_controller.button_released.is_connected(self.on_botton_released):
		current_controller.button_released.connect(self.on_botton_released); 
	
	if other_controller.button_pressed.is_connected(on_botton_pressed):
		other_controller.button_pressed.disconnect(on_botton_pressed);

	if other_controller.button_released.is_connected(on_botton_released):
		other_controller.button_released.disconnect(on_botton_released);

	up = Vector3(0, 1, 0)
	
	if stretch_model:
		if stretch_model_stretch:
			spindleLength = spindleLength * stretch_speed
		elif stretch_model_shorten:
			spindleLength = spindleLength / stretch_speed

	$MeshInstance3D.scale.z = spindleLength
	self.global_position = current_controller.global_position - current_controller.basis.z * (spindleLength * 0.5)
	self.look_at(current_controller.global_position, up, use_model_front)
			
			
func on_botton_pressed(button_name: String) -> void:
	if button_name == "by_button":
		stretch_model_stretch = true
	elif button_name == "ax_button":
		stretch_model_shorten = true
	elif button_name == "trigger_click":
		stretch_model = false
	else:
		return
		
func on_botton_released(button_name: String) -> void:
	if button_name == "by_button":
		stretch_model_stretch = false
	elif button_name == "ax_button":
		stretch_model_shorten = false
	elif button_name == "trigger_click":
		stretch_model = true
	else:
		return
		
