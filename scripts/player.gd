extends CharacterBody3D

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.1
@export var jump_speed: float = 10.0


# Reference to the Camera3D node
@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	handle_movement(delta)
	handle_look()

func handle_movement(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x
	
	input_dir = input_dir.normalized()

	# Horizontal velocity (X and Z)
	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.z * move_speed

	# Gravity and jumping
	if not is_on_floor():
		velocity.y -= 9.8 * delta  # Gravity
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed

	# Apply movement
	move_and_slide()

func handle_look():
	var mouse_delta = Input.get_last_mouse_velocity()
	# Rotate the player node horizontally
	rotate_y(-mouse_delta.x * look_sensitivity * 0.01)
	# Rotate the camera vertically
	camera.rotation_degrees.x = clamp(
			camera.rotation_degrees.x - mouse_delta.y * look_sensitivity * 0.01,
			-90, 90
	)
