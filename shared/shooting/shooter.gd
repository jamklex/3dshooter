extends Node3D
class_name Shooter

const RELOAD_SOUND: AudioStream = preload("res://shared/shooting/switch.mp3")
@export var raycastMeters:int
@export var camera:Camera3D
@export var weaponHolder:Node3D
@export var playerSkeleton:Skeleton3D
@export var aimOverride:SkeletonIK3D
var weapons:Array[Weapon]
var currentWeapon:Weapon
var aiming:bool = false
var reloadingMag:bool = false
var reloading:bool = false
var useRealMunition:bool = true
@onready var _reloadMagTimer:Timer = $reloadMagTimer
@onready var _reloadTimer:Timer = $reloadTimer
@onready var _shotTimer:Timer = $shotTimer
@onready var _magInfo:Label = $magInfo
@onready var _spreadCircle: Panel = $spreadCircle
var soundPlayer:AudioStreamPlayer
signal onHitShootable

const _ITEM_WEAPON_MAP = {
	"6": "res://shared/shooting/weapons/pistol/_main.tscn",
	"8": "res://shared/shooting/weapons/betterPistol/_main.tscn",
	"10": "res://shared/shooting/weapons/rifle/_main.tscn",
	"12": "res://shared/shooting/weapons/sniper/_main.tscn",
	"14": "res://shared/shooting/weapons/shotgun/_main.tscn",
}

const _MUNITION_MAP = {
	Weapon.WeaponType.PISTOL: "7",
	Weapon.WeaponType.RIFLE: "11",
	Weapon.WeaponType.SNIPER: "13",
	Weapon.WeaponType.SHOTGUN: "15",
}

func _ready():
	_reloadMagTimer.timeout.connect(_reloadMag)
	_reloadTimer.timeout.connect(_reload)
	_shotTimer.timeout.connect(_shotCooldownDone)
	_refreshMagInfo()
	soundPlayer = AudioStreamPlayer.new()
	soundPlayer.bus = "Sound"
	add_child(soundPlayer)
	
func hasWeaponWithAmmo():
	if len(weapons) <= 0:
		return false
	for weapon in weapons:
		if _getAmmoInInventory(weapon.weaponType) > 0:
			return true
	return false
	
func hideUi():
	_magInfo.visible = false
	_spreadCircle.visible = false
	
func showUi():
	_magInfo.visible = true
	_refreshSpreadCircle()
	
func addWeapon(scenePath:String):
	if _getWeaponForScenePath(scenePath):
		return
	var packedScene = load(scenePath) as PackedScene
	if not packedScene:
		return
	var weapon = packedScene.instantiate() as Weapon
	if not weapon:
		return
	weapon.visible = false
	_reloadWeapon(weapon)
	weapons.append(weapon)
	weaponHolder.add_child(weapon)

func unlockPlayerInventoryWeapons(playerInventory:Inventory):
	for itemId in playerInventory.item_ids():
		if _is_weapon_id(itemId):
			_addWeaponForItemId(itemId)

func putBulletsToInventory():
	if len(weapons) <= 0:
		return
	if not useRealMunition:
		return
	for weapon in weapons:
		var restMun = weapon.restMagShoots
		if restMun <= 0:
			return
		_addRestAmmo(weapon.weaponType, restMun)

func removeBullets():
	for weapon in weapons:
		weapon.restMagShoots = 0

func checkForMunitionChanged(item_id:String, new_amount:int):
	_checkForMunitionAction(item_id, new_amount)
	
func checkForWeaponChanged(item_id:String, new_amount:int):
	_checkForWeaponAction(item_id, new_amount)
			
func _checkForMunitionAction(item_id:String, new_amount:int):
	if _MUNITION_MAP.has(item_id):
		_refreshMagInfo()

func _checkForWeaponAction(item_id:String, new_amount:int):
	if not _is_weapon_id(item_id):
		return
	var got_weapon = new_amount >= 1
	var weapon_already_initizalized = _has_weapon_with_id(item_id)
	if got_weapon and weapon_already_initizalized:
		return
	if not got_weapon and not weapon_already_initizalized:
		return
	if got_weapon:
		_addWeaponForItemId(item_id)
	else:
		_removeWeaponForItemId(item_id)

func setUseRealMunition(newUseRealMunition:bool):
	useRealMunition = newUseRealMunition
		
func handle():
	_handleWeaponSwitching()
	_handleAimSwitching()
	_handleReloadingMag()
	_handleShooting()
	
func _has_weapon_with_id(weaponId:String):
	return _getWeaponForItemId(weaponId) != null
	
func _addWeaponForItemId(weaponId:String):
	var scenePathForWeaponId = _ITEM_WEAPON_MAP.get(weaponId)
	if not scenePathForWeaponId:
		return
	addWeapon(scenePathForWeaponId)
	
func _removeWeaponForItemId(weaponId:String):
	var weaponForId = _getWeaponForItemId(weaponId)
	if not weaponForId:
		return
	_removeWeapon(weaponForId)

func _getWeaponForItemId(weaponId:String):
	var scenePathForWeaponId = _ITEM_WEAPON_MAP.get(weaponId)
	if not scenePathForWeaponId:
		return null
	return _getWeaponForScenePath(scenePathForWeaponId)
	
func _getWeaponForScenePath(scenePath:String):
	for weapon in weapons:
		if weapon.scene_file_path == scenePath:
			return weapon
	return null
			
func _getWeaponIdForScenePath(scenePath:String):
	var index = 0
	for path in _ITEM_WEAPON_MAP.values():
		if path == scenePath:
			return _ITEM_WEAPON_MAP.keys()[index]
		index += 1
	return null
			
func _removeWeapon(weapon:Weapon):
	if weapon == currentWeapon:
		putWeaponAway()
	weapons.erase(weapon)
	weaponHolder.remove_child(weapon)

func set_bone_rot(boneName:String, ang:Vector3):
	var boneId = playerSkeleton.find_bone(boneName)
	var newpose = playerSkeleton.get_bone_global_pose_no_override(boneId)
	newpose = newpose.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
	playerSkeleton.set_bone_global_pose_override(boneId, newpose, 1, true)
	
func _is_weapon_id(itemId:String):
	return _ITEM_WEAPON_MAP.has(itemId)
	
func _handleReloadingMag():
	if not currentWeapon:
		return
	if reloadingMag:
		return
	if not Input.is_action_just_pressed("reload"):
		return
	if currentWeapon.isMagFull():
		return
	if useRealMunition and _getAmmoInInventory(currentWeapon.weaponType) <= 0:
		return
	if aiming:
		aimOverride.stop()
	_startReloadMag()
	
func _startReloadMag():
	reloadingMag = true
	soundPlayer.stream = currentWeapon.reloadMagSound
	soundPlayer.play(0)
	_reloadMagTimer.start(currentWeapon.reloadMagTimeSecs)
	_refreshMagInfo()
	
func _cancelMagReload():
	if not reloadingMag:
		return
	soundPlayer.stop()
	_reloadMagTimer.stop()
	_endReloadMag()
	
func _startReload():
	if reloading or not currentWeapon.manualLoading:
		return
	reloading = true
	soundPlayer.stream = currentWeapon.reloadSound
	soundPlayer.play(0)
	_reloadTimer.start(currentWeapon.reloadSound.get_length())
	
func _cancelReload():
	if not reloading:
		return
	soundPlayer.stop()
	_reloadTimer.stop()
	_endReload()
	
func _endReload():
	reloading = false
	
func _reloadMag():
	_reloadWeapon(currentWeapon)
	_endReloadMag()
	
func _reload():
	if currentWeapon.restMagShoots > 0:
		currentWeapon.loaded = true
	_endReload()

func _endReloadMag():
	reloadingMag = false
	_refreshMagInfo()
	if aiming:
		aimOverride.start()
		
func _reloadWeapon(weapon:Weapon):
	if useRealMunition:
		var restAmmo = _getAmmoInInventory(weapon.weaponType)
		if restAmmo <= 0:
			return
		_removeRestAmmo(weapon.weaponType, weapon.reload(restAmmo))
	else:
		weapon.reload(weapon.magSize)
	
func _removeRestAmmo(weaponType:Weapon.WeaponType, removeShoots:int):
	var munitionId = _MUNITION_MAP.get(weaponType)
	if not munitionId:
		return
	var playerInv = WorldUtil.player.inventory as Inventory
	playerInv.remove(munitionId, removeShoots)
	
func _addRestAmmo(weaponType:Weapon.WeaponType, addShoots:int):
	var munitionId = _MUNITION_MAP.get(weaponType)
	if not munitionId:
		return
	var playerInv = WorldUtil.player.inventory as Inventory
	playerInv.add(munitionId, addShoots)

func _refreshMagInfo():
	var magInfoText = ""
	if reloadingMag:
		magInfoText = "reloading..."
	elif currentWeapon:
		var restAmmo = "∞"
		if useRealMunition:
			restAmmo = _getAmmoInInventory(currentWeapon.weaponType)
		magInfoText = str(currentWeapon.restMagShoots," / ", restAmmo)
	_magInfo.text = magInfoText
	
func _getAmmoInInventory(weaponType:Weapon.WeaponType):
	var munitionId = _MUNITION_MAP.get(weaponType)
	if not munitionId:
		return currentWeapon.magSize
	var playerInv = WorldUtil.player.inventory as Inventory
	return playerInv.count(munitionId)
	
func _shoot_triggered():
	return (Input.is_action_just_pressed("shoot") and currentWeapon.singleShot) \
		or (Input.is_action_pressed("shoot") and !currentWeapon.singleShot)
	
func _handleShooting():
	if reloadingMag:
		return
	if not currentWeapon or not aiming:
		return
	if currentWeapon.needReloadMag() and Input.is_action_just_pressed("shoot"):
		_emptyShoot()
		return
	if currentWeapon.needReloadMag():
		return
	if currentWeapon.needReload() and not reloading and _shotTimer.is_stopped() and Input.is_action_just_pressed("shoot"):
		_startReload()
		return
	if not currentWeapon.loaded:
		return
	if not _shoot_triggered():
		return
	_shoot()
	_refreshMagInfo()
	
func _emptyShoot():
	soundPlayer.stream = currentWeapon.emptyShotSound
	soundPlayer.play(0)
	
func get_enemy_base_for_bone(enemyBone: CharacterBody3D):
	var curElement = enemyBone
	for i in range(10):
		curElement = curElement.get_parent()
		if curElement is Enemy:
			return curElement
	return null

func _shoot():
	currentWeapon.restMagShoots -= 1
	currentWeapon.loaded = false
	soundPlayer.stream = currentWeapon.shotSound
	soundPlayer.play(0)
	_shotTimer.start(max(currentWeapon.shotCooldown, 0.001))
	currentWeapon.muzzleFlare.restart()
	for i in range(currentWeapon.projecticles):
		var hittedObject = _raycastForHittedObject()
		if not hittedObject:
			continue
		if hittedObject is Shootable and hittedObject.died:
			continue
		var criticalHit = false
		if hittedObject is CharacterBody3D:
			criticalHit = hittedObject.get_parent().name == "head"
			hittedObject = get_enemy_base_for_bone(hittedObject).get_node("shootable")
		var damage = currentWeapon.damage
		if criticalHit:
			damage *= 2
		hittedObject.takeDamage(damage)
		onHitShootable.emit(hittedObject.health <= 0)
	_recoil()
		
func _recoil():
	var max_recoil = currentWeapon.recoil
	var min_recoil = max_recoil / 2
	var vertical_recoil = randf_range(min_recoil, max_recoil)
	var horizontal_recoil = randf_range(-min_recoil, min_recoil)
	WorldUtil.movePlayerCamera(horizontal_recoil, vertical_recoil)
	
func _cancelShotCooldown():
	_shotTimer.stop()
		
func _shotCooldownDone():
	if currentWeapon.manualLoading:
		_startReload()
	else:
		currentWeapon.loaded = true
		
func _applyInaccuracy(ray_direction: Vector3, inaccuracy: float) -> Vector3:
	var deviation = Vector3(randf_range(-0.5,0.5), randf_range(-0.5,0.5), randf_range(-0.5,0.5)) * inaccuracy
	return ray_direction + deviation
	
	
func _raycastForHittedObject() -> Node:
	var space = get_world_3d().direct_space_state
	var ray_direction = camera.global_transform.basis.z
	var accuracy = max(0.01, currentWeapon.accuracy)
	var inaccuarcy = (1 - accuracy) / 2
	ray_direction = _applyInaccuracy(ray_direction,inaccuarcy)
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,
		camera.global_position - ray_direction * raycastMeters, 0b101)
	var collision = space.intersect_ray(query)
	if not collision:
		return
	#_show_projectiles_collision(collision)
	var collider = collision.collider as Node
	var bone = collision.collider as CharacterBody3D
	if bone:
		return bone
	if collider.has_method("takeDamage"):
		return collider
	elif collider.has_node("shootable"):
		return collider.get_node("shootable")
	if collider.has_node("shootable"):
		return collider.get_node("shootable")
	return null
	
func disableAim():
	if aiming:
		_switchAim()

func _handleAimSwitching():
	if not currentWeapon:
		return
	if not Input.is_action_just_pressed("aim"):
		return
	_switchAim()

func _switchAim():
	aiming = !aiming
	if aiming:
		aimOverride.start()
	else: 
		aimOverride.stop()
	_checkFov()

func _handleWeaponSwitching():
	if Input.is_action_just_pressed("putWeaponAway"):
		putWeaponAway()
	if Input.is_action_just_pressed("nextWeapon"):
		_nextWeapon()
	elif Input.is_action_just_pressed("prevWeapon"):
		_prevWeapon()
	_checkFov()
		
func putWeaponAway():
	if currentWeapon == null:
		return
	_putCurrentWeaponAway()
	if aiming:
		_switchAim()
	_refreshMagInfo()
	_playWeaponSwitchSound()
	_refreshSpreadCircle()
	
func _switchWeapon(newIndex: int):
	if _getCurrentWeaponIndex() == newIndex:
		return
	_putCurrentWeaponAway()
	_setCurrentWeapon(weapons[newIndex])
	_playWeaponSwitchSound()
	_refreshSpreadCircle()
	
func _nextWeapon():
	if weapons.size() == 0:
		return
	var nextIndex = _getCurrentWeaponIndex()
	nextIndex += 1
	if nextIndex >= weapons.size():
		nextIndex = 0
	_switchWeapon(nextIndex)
	
func _prevWeapon():
	if weapons.size() == 0:
		return
	var previousIndex = _getCurrentWeaponIndex()
	previousIndex -= 1
	if previousIndex < 0:
		previousIndex = weapons.size() - 1
	_switchWeapon(previousIndex)
	
	
func _setCurrentWeapon(weapon:Weapon):
	currentWeapon = weapon
	currentWeapon.visible = true
	_refreshMagInfo()
	
func _getCurrentWeaponIndex():
	return weapons.find(currentWeapon)
	
func _putCurrentWeaponAway():
	if not currentWeapon:
		return
	_cancelMagReload()
	_cancelReload()
	_cancelShotCooldown()
	currentWeapon.visible = false
	currentWeapon = null
	
func _checkFov():
	var fov = 50
	if currentWeapon and aiming:
		fov = 30 if currentWeapon.weaponType == currentWeapon.WeaponType.SNIPER else 40
	WorldUtil.player_cam.fov = fov
	
func _playWeaponSwitchSound():
	soundPlayer.stream = RELOAD_SOUND
	soundPlayer.play(0)
	
func _refreshSpreadCircle():
	if currentWeapon == null:
		_spreadCircle.visible = false
		return
	var weaponAccuracy = currentWeapon.accuracy
	if weaponAccuracy == 1:
		_spreadCircle.visible = false
		return
	_spreadCircle.visible = true
	var circleSizeInScreenHeightPercent = 1 - weaponAccuracy
	var windowWidth = ProjectSettings.get_setting("display/window/size/viewport_width")
	var windowHeight = ProjectSettings.get_setting("display/window/size/viewport_height")
	var size = windowHeight * circleSizeInScreenHeightPercent
	_spreadCircle.size = Vector2(size, size)
	var style = _spreadCircle.get_theme_stylebox("panel") as StyleBoxFlat
	style.corner_radius_top_left = size
	style.corner_radius_top_right = size
	style.corner_radius_bottom_right = size
	style.corner_radius_bottom_left = size
	var newPos = Vector2(windowWidth/2-size/2, windowHeight/2-size/2)
	_spreadCircle.position = newPos
	
func _show_projectiles_collision(collision):
	var sphere = SphereMesh.new()
	var sphere_instance = MeshInstance3D.new()
	sphere_instance.mesh = sphere
	sphere_instance.transform.origin = collision.position
	sphere_instance.scale = Vector3(0.1,0.1,0.1)
	var red_material = StandardMaterial3D.new()
	red_material.albedo_color = Color.RED
	sphere_instance.material_override = red_material
	var despawner = Timer.new()
	despawner.autostart = true
	despawner.one_shot = true
	despawner.wait_time = 1
	despawner.timeout.connect(sphere_instance.free)
	sphere_instance.add_child(despawner)
	get_tree().get_root().add_child(sphere_instance)
