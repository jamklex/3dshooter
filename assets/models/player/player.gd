class_name Player

extends CharacterBody3D

@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0
@export var mouse_sensitivity := 0.05
@export var interact_distance := 2

@onready var _camera: Camera3D = $Camera
@onready var _model: Node3D = $Skin
@onready var _raycast: RayCast3D = $Camera/RayCast3D

var run_inventory: Array

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # locks mouse to screen
	run_inventory = []

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	handle_interaction()
	handle_show_inventory()

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, _camera.rotation.y).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if velocity.length() > 0.2:
			var look_direction = Vector2(velocity.z, velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	
func handle_interaction():
	if !_raycast.is_colliding():
		return
	var collider = _raycast.get_collider()
	if !collider or !collider.has_method("can_interact") or !collider.can_interact():
		return
	if collider.has_method("highlight"):
		collider.highlight(200)
	if !Input.is_action_just_pressed("interact"):
		return
	var distance = self.global_position.distance_to(collider.global_position)
	print(distance)
	if distance > interact_distance:
		return
	if collider.has_method("interact"):
		collider.interact(self)

func handle_show_inventory():
	if !Input.is_action_just_pressed("inventory"):
		return
	if run_inventory.is_empty():
		print("not items collected")
		return
	print(run_inventory)

func _unhandled_input(event):
	if event is InputEventMouseMotion: # or controller right stick
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
