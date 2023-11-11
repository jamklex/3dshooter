extends CharacterBody3D

const SPEED = 3.0
const ATTACK_RANGE = 1.7
@onready var _anim_player = $visuals/mixamo_base/AnimationPlayer
@onready var _anim_tree = $visuals/mixamo_base/AnimationTree
@onready var _visuals = $visuals
@onready var _shootable:Shootable = $shootable
var dieing = false
var currentMoveVector2 = Vector2.ZERO
var elapsedTimeWithCurrentMoveVector2 = 0.0
var triggerTimeForNextMoveVector = 0.0
@onready var nav_agent = $NavigationAgent3D
var player:Node3D = null
var attacking = false
var state_machine = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _wannaJump():
	return false
	
func _die():
	dieing = true
	# TODO: play die animation faster 
#	_anim_tree.advance(2.0)
#	_anim_player.speed_scale = 2.0
	_anim_tree.set("parameters/conditions/die", true)
	
func _getNextMoveVector2(prevMoveVector2:Vector2):
	if prevMoveVector2 == Vector2.ZERO:
		return Vector2(randi_range(-1,1),randi_range(-1,1))
	else:
		return Vector2.ZERO
		
func _ready():
	_shootable.setStartHealth(randi_range(1,10))
	state_machine = _anim_tree.get("parameters/playback")
	
func _get_player():
	if WorldUtil.player and WorldUtil.player.body:
		return WorldUtil.player.body
	
func _get_next_pos():
	if not player:
		player = _get_player()
	if not player:
		return Vector3.ZERO
	nav_agent.target_position = player.global_position
	return nav_agent.get_next_path_position()
	
func _is_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	var next_pos = _get_next_pos()
	if not next_pos:
		return
	_anim_tree.set("parameters/conditions/has_target", next_pos != null)
	_anim_tree.set("parameters/conditions/in_range", next_pos && _is_in_range())
	if next_pos:
		velocity = (next_pos - global_transform.origin).normalized()
		_visuals.look_at(position + velocity)
	match state_machine.get_current_node():
		"die":
			return
		"attack":
			_visuals.look_at(position + velocity)
			return
	move_and_slide()

#func _playAnimation(animationName:String):
#	if _anim_player.current_animation != animationName:
#		_anim_player.play(animationName)
		
func _hit():
	if _is_in_range():
		print("hitting...")
