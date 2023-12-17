extends Camera3D

var MOVE_SPEED := 8
var mouseDelta := Vector2();
var lookSensitivity := 4.0
var started := false;

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.started = true;
	var move_vec = Vector3();
	move_vec.x = (
		float(Input.is_action_pressed("move_right")) + 
		float(Input.is_action_pressed("move_left"))*-1
	)

	move_vec.y = (
		float(Input.is_action_pressed("move_up")) + 
		float(Input.is_action_pressed("move_down"))*-1
	)

	move_vec.z = (
		float(Input.is_action_pressed("move_forward"))*-1 + 
		float(Input.is_action_pressed("move_backward"))
	)

	var speed = MOVE_SPEED;
	if Input.is_action_pressed("speed_up"):
		speed *= 2;

	self.rotation_degrees.x -= self.mouseDelta.y * self.lookSensitivity * delta;
	self.rotation_degrees.y -= self.mouseDelta.x * self.lookSensitivity * delta;
	self.mouseDelta = Vector2();

	var move_len: float = move_vec.length();
	if (move_len != 0):
		move_vec /= move_len;
		move_vec *= delta * speed;
		self.position += self.basis * move_vec;

	
	
func _input(event): 
	if event is InputEventMouseMotion and self.started:
		self.mouseDelta = event.relative;
