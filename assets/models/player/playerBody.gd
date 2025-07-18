class_name PlayerBody
extends CharacterBody3D


@export var speed = 7.0
@export var jump_strength = 20.0
@export var gravity = 50.0
@onready var mouse_sensitivity = UserSettings.get_setting(UserSettings.KEY_MOUSE_SENS) 
@export var interact_distance = 3

@onready var _shooter:Shooter = $shooter
@onready var _shootable:Shootable = $shootable
@onready var _visuals = $visuals
@onready var _animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var _camera_mount = $camera_mount
@onready var _raycast = $camera_mount/camera_arm/camera_rot/camera/RayCast3D
@onready var _ui = $camera_mount/camera_arm/camera_rot/camera/ui
@onready var minimap_icon = $visuals/minimap_icon
@onready var _player_mesh_1 = $visuals/mixamo_base/Armature/Skeleton3D/Beta_Surface as MeshInstance3D
@onready var _player_mesh_2 = $visuals/mixamo_base/Armature/Skeleton3D/Beta_Joints as MeshInstance3D
@onready var _camera = $camera_mount/camera_arm/camera_rot/camera as Camera3D

@onready var inventory_output = _ui.get_node("RunInventory") as RichTextLabel
@onready var interactionPopup = _ui.get_node("InteractionPopup") as Label
@onready var interactionFeedback = _ui.get_node("InteractionFeedback") as Label
@onready var quests_ui = _ui.get_node("QuestHolder/quests") as VBoxContainer
@onready var hitmarker = _ui.get_node("Hitmarker") as TextureRect
@onready var health_bar = _ui.get_node("health_bar") as HealthBar
@onready var kill_counter = _ui.get_node("kill_counter") as KillCounter
var audioPlayer: AudioStreamPlayer3D
var ambientAudioPlayer: AudioStreamPlayer
var sprinting = false
var _reward_queue = []
var base_health = 0

func is_dead():
	return _shootable.died
	
func hasWeaponWithAmmo():
	return _shooter.hasWeaponWithAmmo()

func _ready():
	if minimap_icon:
		minimap_icon.visible = true
	if WorldUtil.player.bodyStartPos and WorldUtil.player.bodyStartPos != Vector3.ZERO:
		position = WorldUtil.player.bodyStartPos
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # locks mouse to screen
	WorldUtil.player.body = self
	WorldUtil.player_cam = $camera_mount/camera_arm/camera_rot/camera
	refresh_inventory_output()
	fade_interaction_feedback(1)
	QuestLoader.attach_quests(quests_ui)
	WorldUtil.player.equipment.onAddItem.connect(_on_equipment_changed)
	WorldUtil.player.equipment.onRemoveItem.connect(_on_equipment_changed)
	WorldUtil.player.inventory.onAddItem.connect(_on_inventory_changed)
	WorldUtil.player.inventory.onRemoveItem.connect(_on_inventory_changed)
	_shooter.setUseRealMunition(WorldUtil.player.inMissionMap)
	_shooter.unlockPlayerInventoryWeapons(WorldUtil.player.equipment)
	_shooter.onHitShootable.connect(_showHitMarker)
	base_health = _shootable.max_health
	_check_for_health_module(true)
	audioPlayer = AudioStreamPlayer3D.new()
	add_child(audioPlayer)
	ambientAudioPlayer = AudioStreamPlayer.new()
	add_child(ambientAudioPlayer)
	_playAmbientSound()

func _exit_tree():
	_shooter.putBulletsToInventory()
	WorldUtil.player.bodyLastPos = position
	WorldUtil.player.body = null
	WorldUtil.player_cam = null

#var last_pos = Vector3.ZERO  # FOR DEBUGGING
func _physics_process(delta):
	handle_show_menu()
	handle_show_inventory()
	handle_show_quests()
	if WorldUtil.currentWindow:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_ui.visible = false
		_shooter.hideUi()
		_playAnimation("idle")
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_ui.visible = true
	_shooter.showUi()
	if not is_on_floor():
		velocity.y -= gravity * delta
	fade_interaction_feedback(0.5*delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	if Input.is_action_just_pressed("sprint") and is_on_floor():
		sprinting = WorldUtil.player.equipment.check("9", 1)

	handle_interaction()
	handle_reward_queue()
	if _shooter:
		_shooter.handle()

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var currentSpeed = speed
	if sprinting:
		_playAnimation("running")
		currentSpeed *= 1.5
	else:
		_playAnimation("walking")
	if _shooter.aiming:
		_visuals.rotation = Vector3.ZERO
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
		if not _shooter.aiming:
			_visuals.look_at(position + direction)
	else:
		_playAnimation("idle")
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
		sprinting = false
	var visualsToCameraDistance = _camera.global_position.distance_to(_camera_mount.global_position)
	var cameraTooNear = visualsToCameraDistance < 0.7
	var visualsTransparency = 0
	if cameraTooNear:
		visualsTransparency = 0.9
	_player_mesh_1.transparency = visualsTransparency
	_player_mesh_2.transparency = visualsTransparency
	move_and_slide()
#	=== FOR DEBUGGING ===
	#if global_position != last_pos:
		#last_pos = global_position
		#print(global_position)
#	=========

func _playAnimation(animationName:String):
	if _animation_player.current_animation != animationName:
		_animation_player.play(animationName)

func fade_interaction_feedback(rate = 0.5 as float, reset = false as bool):
	var new_modulate = interactionFeedback.modulate
	var target_value = 1 if reset else 0
	new_modulate.a = max(target_value, new_modulate.a - rate)
	interactionFeedback.set_modulate(new_modulate)

func handle_show_inventory():
	if !Input.is_action_just_pressed("inventory"):
		return
	_switchUiMenu(0)

func handle_show_quests():
	if !Input.is_action_just_pressed("questlog"):
		return
	_switchUiMenu(1)

func handle_show_menu():
	if !Input.is_action_just_pressed("menu"):
		return
	_switchUiMenu(2)

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
	if !WorldUtil.currentWindow and collider.has_method("popup_message"):
		interactionPopup.text = collider.popup_message()
	if !Input.is_action_just_pressed("interact"):
		return
	if collider.has_method("interact"):
		var feedback = collider.interact(WorldUtil.player)
		if feedback:
			interactionFeedback.text = feedback
			fade_interaction_feedback(0, true)
	interactionPopup.text = ""

func handle_reward_queue():
	var reward_message = ""
	while not _reward_queue.is_empty():
		var reward = _reward_queue.pop_front() as DropItem
		reward_message += reward.pretty_name()
		var amount = reward.get_amount()
		if amount > 1:
			reward_message += " x" + str(amount)
		reward_message += "\n"
	if not reward_message.is_empty():
		interactionFeedback.text = reward_message
		fade_interaction_feedback(0, true)

func refresh_inventory_output():
	var inventory_text = ""
	if !WorldUtil.player.inventory.is_empty():
		inventory_text += "Inventory: " + JSON.stringify(WorldUtil.player.inventory.to_readable_dict(), "\t") + "\n"
	if !WorldUtil.player.storage.is_empty():
		inventory_text += "Storage: " + JSON.stringify(WorldUtil.player.storage.to_readable_dict(), "\t") + "\n"
	if !WorldUtil.player.salvager.is_empty():
		inventory_text += "Salvager: " + JSON.stringify(WorldUtil.player.salvager.to_readable_dict(), "\t") + "\n"
	if inventory_text == "":
		inventory_text = "no items collected"
	inventory_output.text = inventory_text

func add_reward_to_queue(reward: DropItem):
	_reward_queue.push_back(reward)

func moveCamera(relative_x: float, relative_y: float):
	var yRot = deg_to_rad(relative_x * mouse_sensitivity)
	rotate_y(-yRot)
	if not _shooter.aiming:
		_visuals.rotate_y(yRot)
	_camera_mount.rotate_x(deg_to_rad(-relative_y * mouse_sensitivity))
	_camera_mount.rotation_degrees.x = clamp(_camera_mount.rotation_degrees.x, -80.0, 60.0)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		moveCamera(event.relative.x,event.relative.y)
	
func _showHitMarker(lastHit):
	hitmarker.visible = true
	hitmarker.modulate = Color(255,0,0) if lastHit else Color(255,255,255)
	await get_tree().create_timer(0.1).timeout
	hitmarker.visible = false

func _closeCurrentWindow():
	var dialog = WorldUtil.currentWindow as Dialog
	if not dialog:
		WorldUtil.closeCurrentWindow()

func _switchUiMenu(selectedTabIndex):
	var menu = WorldUtil.currentWindow as Menu
	if WorldUtil.currentWindow and not menu:
		_closeCurrentWindow()
		return
	if not menu:
		menu = WorldUtil.showMenu()
		menu.menuTab.current_tab = selectedTabIndex
	else:
		if menu.menuTab.current_tab == selectedTabIndex or selectedTabIndex == menu.menuTab.get_child_count()-1:
			WorldUtil.closeCurrentWindow()
		else:
			menu.menuTab.current_tab = selectedTabIndex

func _on_health_changed(health):
	if _shootable.died:
		return
	health_bar.setHealth(health)
	_playDamagedSound()
	if health <= 0 and not _shootable.died:
		_playDeadSound()
		WorldUtil.player_died()

func _on_equipment_changed(payload:Array):
	var item_id = payload[0]
	var new_amount = int(payload[1])
	_shooter.checkForWeaponChanged(item_id, new_amount)
	_check_for_health_module()

func _on_inventory_changed(payload:Array):
	var item_id = payload[0]
	var new_amount = int(payload[1])
	_shooter.checkForMunitionChanged(item_id, new_amount)

func _check_for_health_module(first_check:bool=false):
	var new_max_health = base_health
	new_max_health += WorldUtil.player.equipment.count("19") * 10
	_shootable.max_health = new_max_health
	if not WorldUtil.player.inMissionMap or first_check:
		_shootable.resetHealth()
	health_bar.init(_shootable.health, _shootable.max_health)

func _playDeadSound():
	_playSound(SoundUtil.SoundName.PLAYER_DEAD, -10, 0)

func _playDamagedSound():
	_playSound(SoundUtil.SoundName.PLAYER_DAMAGE, -4, 0)

func _playStepSound():
	if is_on_floor():
		_playSound(SoundUtil.SoundName.PLAYER_STEP, -3, 0)
		
func _playAmbientSound():
	var inMissionMap = WorldUtil.player.inMissionMap
	var sound = SoundUtil.getSound(SoundUtil.SoundName.AMBIENT_MISSION if inMissionMap else SoundUtil.SoundName.AMBIENT_HOME)
	sound.loop = true
	ambientAudioPlayer.bus = "Ambient"
	ambientAudioPlayer.stream = sound
	ambientAudioPlayer.volume_db = -20 if inMissionMap else -10
	ambientAudioPlayer.play()

func _playSound(soundName: SoundUtil.SoundName, max_db: float, max_distance: float):
	audioPlayer.stream = SoundUtil.getSound(soundName)
	audioPlayer.bus = "Sound"
	audioPlayer.max_db = max_db
	audioPlayer.max_distance = max_distance
	audioPlayer.play()
