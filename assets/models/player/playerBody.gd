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

@onready var inventory_output = _ui.get_node("RunInventory") as RichTextLabel
@onready var interactionPopup = _ui.get_node("InteractionPopup") as Label
@onready var interactionFeedback = _ui.get_node("InteractionFeedback") as Label
@onready var quests_ui = _ui.get_node("QuestHolder/quests") as VBoxContainer
@onready var death_screen = _ui.get_node("deathScreen") as Panel
@onready var hitmarker = _ui.get_node("Hitmarker") as TextureRect
@onready var health_bar = _ui.get_node("health_bar") as HealthBar
var sprinting = false
var _reward_queue = []
var base_health = 0

func _ready():
	if WorldUtil.player.bodyStartPos and WorldUtil.player.bodyStartPos != Vector3.ZERO:
		position = WorldUtil.player.bodyStartPos
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # locks mouse to screen
	WorldUtil.player.body = self
	WorldUtil.player_cam = $camera_mount/camera_arm/camera_rot/camera
	refresh_inventory_output()
	fade_interaction_feedback(1)
	QuestLoader.attach_quests(quests_ui)
	WorldUtil.player.equip_inventory.onAddItem.connect(_on_equip_inv_changed)
	WorldUtil.player.equip_inventory.onRemoveItem.connect(_on_equip_inv_changed)
	WorldUtil.player.run_inventory.onAddItem.connect(_on_run_inv_changed)
	WorldUtil.player.run_inventory.onRemoveItem.connect(_on_run_inv_changed)
	_shooter.setUseRealMunition(WorldUtil.player.inMissionMap)
	_shooter.unlockPlayerInventoryWeapons(WorldUtil.player.equip_inventory)
	_shooter.onShootableDie.connect(WorldUtil.player.onShootableKilled)
	_shooter.onHitShootable.connect(_showHitMarker)
	base_health = _shootable.max_health
	_check_for_health_module(true)

func _exit_tree():
	_shooter.putBulletsToInventory()
	WorldUtil.player.bodyLastPos = position
	WorldUtil.player.body = null
	WorldUtil.player_cam = null

func _physics_process(delta):
	handle_show_menu()
	if WorldUtil.currentWindow:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_ui.visible = false
		_playAnimation("idle")
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_ui.visible = true
	if not is_on_floor():
		velocity.y -= gravity * delta
	fade_interaction_feedback(0.5*delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	if Input.is_action_just_pressed("sprint") and is_on_floor():
		sprinting = WorldUtil.player.equip_inventory.check("9", 1)

	handle_interaction()
	handle_show_inventory()
	handle_show_quests()
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
	move_and_slide()

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
	if WorldUtil.currentWindow:
		return
	#refresh_inventory_output()
	#inventory_output.visible = !inventory_output.visible
	_switchUiMenu(0)

func handle_show_quests():
	if !Input.is_action_just_pressed("questlog"):
		return
	if WorldUtil.currentWindow:
		return
	QuestLoader.attach_quests(quests_ui)
	_switchUiMenu(1)

func handle_show_menu():
	if !Input.is_action_just_pressed("menu"):
		return
	if WorldUtil.currentWindow and not WorldUtil.currentDialog:
		WorldUtil.closeCurrentWindow()
		return
	if WorldUtil.currentDialog:
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
	if !WorldUtil.player.run_inventory.is_empty():
		inventory_text += "RunInventory: " + JSON.stringify(WorldUtil.player.run_inventory.to_readable_dict(), "\t") + "\n"
	if !WorldUtil.player.inventory.is_empty():
		inventory_text += "Inventory: " + JSON.stringify(WorldUtil.player.inventory.to_readable_dict(), "\t") + "\n"
	if !WorldUtil.player.store_inventory.is_empty():
		inventory_text += "StoreInventory: " + JSON.stringify(WorldUtil.player.store_inventory.to_readable_dict(), "\t") + "\n"
	if inventory_text == "":
		inventory_text = "no items collected"
	inventory_output.text = inventory_text

func add_reward_to_queue(reward: DropItem):
	_reward_queue.push_back(reward)

func _unhandled_input(event):
	if event is InputEventMouseMotion: # or controller right stick
		var yRot = deg_to_rad(event.relative.x*mouse_sensitivity)
		rotate_y(-yRot)
		if not _shooter.aiming:
			_visuals.rotate_y(yRot)
		_camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		_camera_mount.rotation_degrees.x = clamp(_camera_mount.rotation_degrees.x, -80.0, 60.0)

func _on_player_died():
	WorldUtil.player.clearMissionInventories()
	var respawnBtn = death_screen.get_node("respawnBtn") as Button
	respawnBtn.pressed.connect(WorldUtil.respawn)
	var quitBtn = death_screen.get_node("quitBtn") as Button
	quitBtn.pressed.connect(WorldUtil.quitGame)
	death_screen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _showHitMarker(lastHit):
	hitmarker.visible = true
	hitmarker.modulate = Color(255,0,0) if lastHit else Color(255,255,255)
	await get_tree().create_timer(0.1).timeout
	hitmarker.visible = false
	
func _switchUiMenu(selectedTabIndex):
	var menu = WorldUtil.currentWindow
	if menu and (menu.menuTab.current_tab == selectedTabIndex or selectedTabIndex == menu.menuTab.get_child_count()-1):
		WorldUtil.closeCurrentWindow()
	elif not menu:
		WorldUtil.showMenu()
		#if not menu:
			#menu = WorldUtil.showMenu()
		#menu.menuTab.current_tab = selectedTabIndex

func _on_health_changed(health):
	health_bar.setHealth(health)

func _on_equip_inv_changed(payload:Array):
	var item_id = payload[0]
	var new_amount = int(payload[1])
	_shooter.checkForWeaponChanged(item_id,new_amount)
	_check_for_health_module()
	
func _on_run_inv_changed(payload:Array):
	var item_id = payload[0]
	var new_amount = int(payload[1])
	_shooter.checkForMunitionChanged(item_id, new_amount)
	
func _check_for_health_module(first_check:bool=false):
	var new_max_health = base_health
	new_max_health += WorldUtil.player.equip_inventory.count("19") * 10
	_shootable.max_health = new_max_health
	if not WorldUtil.player.inMissionMap or first_check:
		_shootable.resetHealth()
	health_bar.init(_shootable.health, _shootable.max_health)
