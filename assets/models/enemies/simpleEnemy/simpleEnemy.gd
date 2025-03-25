extends CharacterBody3D
class_name Enemy

const NEXT_RANDOM_POS_RANGE = 50
const VELOCITY_SMOOTHNESS = 0.2
@onready var _anim_player = $visuals/mixamo_base/AnimationPlayer
@onready var _anim_tree = $visuals/mixamo_base/AnimationTree
@onready var _visuals = $visuals
@onready var _shootable:Shootable = $shootable
@onready var nav_agent = $NavigationAgent3D
@onready var sight_cone = $visuals/mixamo_base/Armature/Skeleton3D/sightAttachment/sightHolder/sightCone
@onready var sight_raycast = $visuals/mixamo_base/Armature/Skeleton3D/sightAttachment/sightHolder/raycast
@onready var skin: MeshInstance3D = $visuals/mixamo_base/Armature/Skeleton3D/Beta_Surface
var audioPlayer: AudioStreamPlayer3D
var damage:int = 0
var dieing = false
var player:PlayerBody = null
var playerSpotted = false
var state_machine: AnimationNodeStateMachinePlayback
var last_pos = null
var not_moving_since = null
var simple_path_until = null
var rng = RandomNumberGenerator.new()
var pingTimer = Timer.new()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum ENEMY_TYPE {WEAK_SQUISHY, STRONG_SQUISHY, WEAK_TANK, STRONG_TANK}
const ENEMY_NAME_MAP = {
	ENEMY_TYPE.WEAK_SQUISHY: "W4KSY",
	ENEMY_TYPE.STRONG_SQUISHY: "5TR0S",
	ENEMY_TYPE.WEAK_TANK: "W34KT",
	ENEMY_TYPE.STRONG_TANK: "ST4NK",
}

const PING_RATE_SECS = 3
var lastPingTime = 0

func _wannaJump():
	return false
	
func _die():
	if dieing: 
		return
	dieing = true
	_anim_tree.set("parameters/conditions/die", true)
	_playDeadSound()
	WorldUtil.enemy_died(_shootable.id)
	
func _getNextMoveVector2(prevMoveVector2:Vector2):
	if prevMoveVector2 == Vector2.ZERO:
		return Vector2(randi_range(-1,1),randi_range(-1,1))
	else:
		return Vector2.ZERO
		
func _ready():
	add_child(pingTimer)
	_shootable.setStartHealth(randi_range(1,10))
	state_machine = _anim_tree.get("parameters/playback")
	rng.randomize()
	process_enemy_type_attributes(rng.randi_range(0, ENEMY_TYPE.size()-1))
	audioPlayer = AudioStreamPlayer3D.new()
	add_child(audioPlayer)
	_pingLogic()

func _get_player():
	if WorldUtil.player and WorldUtil.player.body:
		return WorldUtil.player.body
	
func _get_next_random_pos():
	while true:
		var next_random_pos = _generate_random_pos()
		if global_position.distance_to(next_random_pos) > 5:
			return next_random_pos
	
func _generate_random_pos():
	var new_random_pos = global_position
	new_random_pos.x = rng.randi_range(new_random_pos.x - NEXT_RANDOM_POS_RANGE, new_random_pos.x + NEXT_RANDOM_POS_RANGE)
	new_random_pos.z = rng.randi_range(new_random_pos.z - NEXT_RANDOM_POS_RANGE, new_random_pos.z + NEXT_RANDOM_POS_RANGE)
	return new_random_pos

func _is_target_pos_reached():
	if not nav_agent.target_position:
		return false
	return global_position.distance_to(nav_agent.get_final_position()) < nav_agent.target_desired_distance
	
func _is_in_attack_range():
	if not player:
		return false
	return global_position.distance_to(player.position) < nav_agent.target_desired_distance
	
func _set_player_spotted_to_all_enemies():
	var all_enemies = get_tree().get_nodes_in_group("enemies") as Array[Enemy]
	for enemy in all_enemies:
		enemy.playerSpotted = true

func _moving():
	if not last_pos:
		last_pos = global_position
		return true
	var moving = global_position.distance_to(last_pos) > 0.001
	last_pos = global_position
	return moving
	
func _is_attacking():
	return playerSpotted and _is_in_attack_range()

func _physics_process(delta):
	if dieing or player and player.is_dead():
		_anim_tree.set("parameters/conditions/has_target", false)
		_anim_tree.set("parameters/conditions/in_range", false)
		return
	if simple_path_until:
		if Time.get_ticks_msec() >= simple_path_until:
			nav_agent.path_postprocessing = 0
			simple_path_until = null
	else:
		if not _moving() and not _is_attacking():
			if not not_moving_since:
				not_moving_since = Time.get_ticks_msec()
			elif Time.get_ticks_msec() - not_moving_since > 2000:
				not_moving_since = null
				simple_path_until = Time.get_ticks_msec() + 5000
				nav_agent.path_postprocessing = 1
		else:
			not_moving_since = null
	if not player:
		player = _get_player()
	if not nav_agent.target_position or _is_target_pos_reached() or playerSpotted:
		nav_agent.target_position = player.global_position if playerSpotted else _get_next_random_pos()
	if nav_agent.target_position:
		var next_path_pos = nav_agent.get_next_path_position()
		next_path_pos.y = global_position.y
		nav_agent.velocity = (next_path_pos - global_position).normalized()
	_anim_tree.set("parameters/conditions/has_target", nav_agent.target_position != null)
	_anim_tree.set("parameters/conditions/in_range", _is_attacking())
	if state_machine.get_current_node() == "attack":
		var hitPos = player.global_position
		hitPos.y = position.y
		_visuals.look_at(hitPos)
		return
	move_and_slide()
	
func _pingLogic():
	pingTimer.start(PING_RATE_SECS)
	pingTimer.timeout.connect(_playPingSound)

func _hit():
	_playAttackSound()
	if _is_in_attack_range():
		var shootable = player.get_node("shootable") as Shootable
		shootable.takeDamage(damage)
		
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
		_set_player_spotted_to_all_enemies()

func _on_damage_taken(damage):
	_set_player_spotted_to_all_enemies()

func process_enemy_type_attributes(enemyType: ENEMY_TYPE):
	_shootable.id = enemyType
	match enemyType:
		ENEMY_TYPE.WEAK_SQUISHY:
			damage = 3
			_shootable.health = 10
			_set_color(Color.SKY_BLUE)
		ENEMY_TYPE.STRONG_SQUISHY:
			damage = 6
			_shootable.health = 12
			_set_color(Color.LEMON_CHIFFON)
		ENEMY_TYPE.WEAK_TANK:
			damage = 4
			_shootable.health = 20
			_set_color(Color.INDIAN_RED)
		ENEMY_TYPE.STRONG_TANK:
			damage = 8
			_shootable.health = 30
			_set_color(Color.PURPLE)

func _set_color(color: Color):
	var new_material = StandardMaterial3D.new() as StandardMaterial3D
	new_material.albedo_color = color
	skin.set_surface_override_material(0, new_material)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	var velocity_distance = abs(velocity.distance_to(safe_velocity))
	if velocity_distance > 0.01:
		velocity_distance *= 10
		velocity = velocity.lerp(safe_velocity, VELOCITY_SMOOTHNESS / velocity_distance)
	else: 
		velocity = velocity.lerp(safe_velocity, VELOCITY_SMOOTHNESS)
	if state_machine.get_current_node() == "attack":
		return
	var look_at_pos = global_position + velocity
	if global_position.distance_to(look_at_pos) > 0.001:
		_visuals.look_at(global_position + velocity)


func _on_health_changed(health: int) -> void:
	if health <= 0:
		_die()

func _playDeadSound():
	_playSound(SoundUtil.SoundName.ENEMY_DEAD, 20, 0)
	
func _playAttackSound():
	_playSound(SoundUtil.SoundName.ENEMY_ATTACK, -5, 20)
	
func _playPingSound():
	if playerSpotted:
		if pingTimer.get_wait_time() == PING_RATE_SECS:
			pingTimer.start(PING_RATE_SECS/2)
		_playSound(SoundUtil.SoundName.ENEMY_AGGRESSIVE, -1, 20)
	else:
		_playSound(SoundUtil.SoundName.ENEMY_IDLE, -1, 20)
	
func _playSound(soundName: SoundUtil.SoundName, max_db: float, max_distance: float):
	audioPlayer.stream = SoundUtil.getSound(soundName)
	audioPlayer.bus = "Sound"
	audioPlayer.max_db = max_db
	audioPlayer.max_distance = max_distance
	audioPlayer.play()
