extends CharacterBody3D

const SPEED = 3.0
#const JUMP_VELOCITY = 4.5
@onready var _animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var _visuals = $visuals
@onready var _shootable:Shootable = $shootable
var dieing = false
var currentMoveVector2 = Vector2.ZERO
var elapsedTimeWithCurrentMoveVector2 = 0.0
var triggerTimeForNextMoveVector = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _wannaJump():
	return false
	
func _die():
	dieing = true
	currentMoveVector2 = Vector2.ZERO
	_animation_player.speed_scale = 2.0
	_animation_player.play("knock_down")
	_animation_player.animation_finished.connect(_dead)
	
func _dead(animationName):
	queue_free()
	
func _getNextMoveVector2(prevMoveVector2:Vector2):
	if prevMoveVector2 == Vector2.ZERO:
		return Vector2(randi_range(-1,1),randi_range(-1,1))
	else:
		return Vector2.ZERO
		
func _ready():
	_shootable.setStartHealth(randi_range(1,10))

func _physics_process(delta):		
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if dieing:
		return
		
	elapsedTimeWithCurrentMoveVector2 += delta
	if elapsedTimeWithCurrentMoveVector2 >= triggerTimeForNextMoveVector:
		currentMoveVector2 = _getNextMoveVector2(currentMoveVector2)
		elapsedTimeWithCurrentMoveVector2 = 0
		triggerTimeForNextMoveVector = randi_range(1,5) if currentMoveVector2 == Vector2.ZERO else 1

#	if _wannaJump() and is_on_floor():
#		velocity.y = JUMP_VELOCITY

	var input_dir = currentMoveVector2
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		_playAnimation("walking")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		_visuals.look_at(position + direction)
	else:
		_playAnimation("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
		
func _playAnimation(animationName:String):
	if _animation_player.current_animation != animationName:
		_animation_player.play(animationName)
