class_name PlayerBody
extends CharacterBody3D


@export var speed = 7.0
@export var jump_strength = 20.0
@export var gravity = 50.0
@export var mouse_sensitivity = 0.05
@export var interact_distance = 3

@onready var _visuals = $visuals
@onready var _animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var _camera_mount = $camera_mount
@onready var _camera: Camera3D = $camera_mount/camera_offset/camera_rot/camera
@onready var _model: Node3D = $Skin
@onready var _raycast: RayCast3D = $camera_mount/camera_offset/camera_rot/camera/RayCast3D
@onready var last_drop: RichTextLabel = $camera_mount/camera_offset/camera_rot/camera/LastDrop
@onready var inventory_output: RichTextLabel = $camera_mount/camera_offset/camera_rot/camera/RunInventory
@onready var crosshair = $camera_mount/camera_offset/camera_rot/camera/Crosshair
@onready var interactionPopup = $camera_mount/camera_offset/camera_rot/camera/InteractionPopup as Label
@onready var interactionFeedback = $camera_mount/camera_offset/camera_rot/camera/InteractionFeedback as Label
var inDialog = false

func setInDialog(value:bool):
	inDialog = value
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if inDialog else Input.MOUSE_MODE_CAPTURED
	crosshair.visible = !inDialog
	inventory_output.visible = !inDialog
	last_drop.visible = !inDialog

func _ready():
	if WorldUtil.player.bodyStartPos and WorldUtil.player.bodyStartPos != Vector3.ZERO:
		position = WorldUtil.player.bodyStartPos
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # locks mouse to screen
	WorldUtil.player.body = self
	WorldUtil.player.cam = get_node("Camera")
	refresh_inventory_output()
	fade_interaction_feedback(1)
	
func _exit_tree():
	WorldUtil.player.bodyLastPos = position
	WorldUtil.player.body = null
	WorldUtil.player.cam = null

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	fade_interaction_feedback()
	if inDialog:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	handle_interaction()
	handle_show_inventory()
	handle_show_menu()

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, _camera.rotation.y).normalized()
	if direction:
		_playAnimation("walking")
		_visuals.look_at(position + direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if velocity.length() > 0.2:
			var look_direction = Vector2(velocity.z, velocity.x)
	else:
		_playAnimation("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	
	
func _playAnimation(animationName:String):
	if _animation_player.current_animation != animationName:
		_animation_player.play(animationName)	

func fade_interaction_feedback(rate = 0.025 as float, reset = false as bool):
	var new_modulate = interactionFeedback.modulate
	if reset:
		new_modulate.a = 1
	if new_modulate.a > 0:
		new_modulate.a = new_modulate.a * (1 - rate)
	interactionFeedback.set_modulate(new_modulate)

func handle_show_menu():
	if !Input.is_action_just_pressed("menu"):
		return
	WorldUtil.quitGame()
	
func handle_interaction():
	interactionPopup.text = ""
	if !_raycast.is_colliding():
		return
	var collider = _raycast.get_collider()
	if !collider or !collider.has_method("can_interact") or !collider.can_interact():
		return
	if collider.has_method("highlight"):
		collider.highlight()
	var distance = self.global_position.distance_to(collider.global_position)
	if distance > InteractionHelper.interact_distance(collider, interact_distance):
		return
	if !inDialog and collider.has_method("popup_message"):
		interactionPopup.text = collider.popup_message()
	if !Input.is_action_just_pressed("interact"):
		return
	if collider.has_method("interact"):
		var feedback = collider.interact(WorldUtil.player)
		if feedback:
			interactionFeedback.text = feedback
			fade_interaction_feedback(0, true)
	interactionPopup.text = ""

func handle_show_inventory():
	if !Input.is_action_just_pressed("inventory"):
		return
	refresh_inventory_output()
	inventory_output.visible = !inventory_output.visible

func refresh_inventory_output():
	var inventory_text = ""
	if !WorldUtil.player.run_inventory.is_empty():
		inventory_text += "RunInventory: " + JSON.stringify(WorldUtil.player.run_inventory.to_dict(), "\t") + "\n"
	if !WorldUtil.player.inventory.is_empty():
		inventory_text += "Inventory: " + JSON.stringify(WorldUtil.player.inventory.to_dict(), "\t") + "\n"
	if !WorldUtil.player.store_inventory.is_empty():
		inventory_text += "StoreInventory: " + JSON.stringify(WorldUtil.player.store_inventory.to_dict(), "\t") + "\n"
	if inventory_text == "":
		inventory_text = "no items collected"
	inventory_output.text = inventory_text

func show_last_drop(text):
	last_drop.text = text

func _unhandled_input(event):
	if event is InputEventMouseMotion: # or controller right stick
		var yRot = deg_to_rad(event.relative.x*mouse_sensitivity)
		rotate_y(-yRot)
		_visuals.rotate_y(yRot)
		_camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		_camera_mount.rotation_degrees.x = clamp(_camera_mount.rotation_degrees.x, -80.0, 60.0)
		
