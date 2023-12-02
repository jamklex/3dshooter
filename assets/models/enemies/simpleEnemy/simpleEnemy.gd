extends CharacterBody3D
class_name Enemy

const DAMAGE:int = 3
const SPEED = 3.0
const ATTACK_RANGE = 1.7
const ROUTINE_RANGE = 2.5
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
var playerSpotted = false
var attacking = false
var state_machine = null
var start_pos = null
var routine_pos_use_time = 10000
var rng = RandomNumberGenerator.new()
@onready var sight_cone = $visuals/mixamo_base/Armature/Skeleton3D/sightAttachment/sightHolder/sightCone
@onready var sight_raycast = $visuals/mixamo_base/Armature/Skeleton3D/sightAttachment/sightHolder/raycast


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _wannaJump():
	return false
	
func _die():
	dieing = true
	_anim_tree.set("parameters/conditions/die", true)
	
func _getNextMoveVector2(prevMoveVector2:Vector2):
	if prevMoveVector2 == Vector2.ZERO:
		return Vector2(randi_range(-1,1),randi_range(-1,1))
	else:
		return Vector2.ZERO
		
func _ready():
	_shootable.setStartHealth(randi_range(1,10))
	state_machine = _anim_tree.get("parameters/playback")
	start_pos = position
	rng.randomize()
	
func _get_player():
	if WorldUtil.player and WorldUtil.player.body:
		return WorldUtil.player.body
	
func _get_next_pos_to_player():
	if not player:
		return Vector3.ZERO
	nav_agent.target_position = player.global_position
	return nav_agent.get_next_path_position()
	
func _get_random_next_pos():
	var new_random_pos = start_pos
	new_random_pos.x = rng.randi_range(start_pos.x - ROUTINE_RANGE, start_pos.x + ROUTINE_RANGE)
	new_random_pos.z = rng.randi_range(start_pos.z - ROUTINE_RANGE, start_pos.z + ROUTINE_RANGE)
	return new_random_pos

func _routine_pos_reached():
	if not nav_agent.target_position:
		return false
	return position.distance_to(nav_agent.target_position) < 1

func _get_next_routine_pos(delta):
	routine_pos_use_time += delta
	if routine_pos_use_time >= 1 or _routine_pos_reached():
		nav_agent.target_position = _get_random_next_pos()
		routine_pos_use_time = 0
	return nav_agent.get_next_path_position()
	
func _is_in_attack_range():
	if not player:
		return false
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
#func _is_in_view_range():
#	if not player:
#		return false
#	return global_position.distance_to(player.global_position) < VIEW_RANGE
	
func _set_player_spotted_to_all_enemies(newSpottedFlag:bool):
	var all_enemies = get_parent().find_children("*","Enemy") as Array[Enemy]
	for enemy in all_enemies:
		enemy.playerSpotted = true
		
#func _try_to_spot_player():
#	if not base_ray_cast.is_colliding():
#		return
#	var col = base_ray_cast.get_collider()
#	if col is CharacterBody3D and not playerSpotted:
#		print("player spotted")
#		_set_player_spotted_to_all_enemies(true)

func _physics_process(delta):
	if not player:
		player = _get_player()
	if not is_on_floor():
		velocity.y -= gravity * delta
	var next_pos = null
	if playerSpotted:
		next_pos = _get_next_pos_to_player()
	else:
		next_pos = _get_next_routine_pos(delta)
	_anim_tree.set("parameters/conditions/has_target", next_pos != null)
	_anim_tree.set("parameters/conditions/in_range", (playerSpotted and _is_in_attack_range()))
	if next_pos and not dieing:
		velocity = (next_pos - global_transform.origin).normalized()
		_visuals.look_at(position + velocity)
	match state_machine.get_current_node():
		"die":
			return
		"attack":
			var hitPos = player.global_position
			hitPos.y = position.y
			_visuals.look_at(hitPos)
			return
	move_and_slide()

func _hit():
	if _is_in_attack_range():
		var shootable = player.get_node("shootable") as Shootable
		shootable.takeDamage(DAMAGE)
		
func _find_player(nodes:Array[Node3D]):
	for node in nodes:
		if node is PlayerBody:
			return node
	return null

func _can_see(node:Node3D):
	sight_raycast.look_at(node.global_transform.origin, Vector3.UP)
	sight_raycast.force_raycast_update()
	if not sight_raycast.is_colliding():
		return false
	var collider = sight_raycast.get_collider()
	return (collider is PlayerBody)

func check_sight():
	var overlaps = sight_cone.get_overlapping_bodies()
	if overlaps.size() <= 0:
		return
	var player = _find_player(overlaps)
	if not player:
		return
	if _can_see(player):
		_set_player_spotted_to_all_enemies(true)
