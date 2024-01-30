extends Node3D
class_name Shooter

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
var soundPlayer:AudioStreamPlayer
signal onShootableDie
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
	add_child(soundPlayer)
	
func addWeapon(scenePath:String):
	var packedScene = load(scenePath) as PackedScene
	if not packedScene:
		return
	var weapon = packedScene.instantiate() as Weapon
	if not weapon:
		return
	if _getWeaponForScenePath(scenePath):
		return
	weapon.visible = false
	_reloadWeapon(weapon)
	weapons.append(weapon)
	weaponHolder.add_child(weapon)

func unlockPlayerInventoryWeapons(playerInventory:Inventory):
	for itemId in playerInventory.item_ids():
		if _isWeaponId(itemId):
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

func checkForMunitionChanged(payload:Array):
	_checkForMunitionAction(payload)
	
func checkForWeaponChanged(payload:Array):
	_checkForWeaponAction(payload)
			
func _checkForMunitionAction(payload:Array):
	var itemId = payload[0]
	if _MUNITION_MAP.has(itemId):
		_refreshMagInfo()

func _checkForWeaponAction(payload:Array):
	var itemId = payload[0]
	var newAmount = int(payload[1])
	if not _isWeaponId(itemId):
		return
	var gotWeapon = newAmount >= 1
	var weaponAlreadyInitizalized = _hasWeaponWithId(itemId)
	if gotWeapon and weaponAlreadyInitizalized:
		return
	if not gotWeapon and not weaponAlreadyInitizalized:
		return
	if gotWeapon:
		_addWeaponForItemId(itemId)
	else:
		_removeWeaponForItemId(itemId)

func setUseRealMunition(newUseRealMunition:bool):
	useRealMunition = newUseRealMunition
		
func handle():
	_handleWeaponSwitching()
	_handleAimSwitching()
	_handleReloadingMag()
	_handleShooting()
	
func _hasWeaponWithId(weaponId:String):
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
	
func _isWeaponId(itemId:String):
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
	if _getAmmoInInventory(currentWeapon.weaponType) <= 0 and useRealMunition:
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
	var playerInv = WorldUtil.player.run_inventory as Inventory
	playerInv.remove(munitionId, removeShoots)
	
func _addRestAmmo(weaponType:Weapon.WeaponType, addShoots:int):
	var munitionId = _MUNITION_MAP.get(weaponType)
	if not munitionId:
		return
	var playerInv = WorldUtil.player.run_inventory as Inventory
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
	var playerInv = WorldUtil.player.run_inventory as Inventory
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
	_shotTimer.start(currentWeapon.shotCooldown)
	currentWeapon.muzzleFlare.restart()
	for i in range(currentWeapon.projecticles):
		var shootable = _raycastForShootable()
		if not shootable or shootable.died:
			continue
		var criticalHit = false
		if shootable is CharacterBody3D:
			criticalHit = shootable.get_parent().name == "head"
			shootable = get_enemy_base_for_bone(shootable).get_node("shootable")
		var damage = currentWeapon.damage
		if criticalHit:
			damage *= 2
		var died = shootable.takeDamage(damage)
		shootable = shootable as Shootable
		if shootable:
			onHitShootable.emit(died)
		if shootable and died:
			onShootableDie.emit(shootable)
		
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
	
	
func _raycastForShootable() -> Node:
	var space = get_world_3d().direct_space_state
	var ray_direction = camera.global_transform.basis.z
	var inaccuarcy = (1 - currentWeapon.accuracy) / 2
	ray_direction = _applyInaccuracy(ray_direction,inaccuarcy)
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,
		camera.global_position - ray_direction * raycastMeters, 0b101)
	var collision = space.intersect_ray(query)
	if not collision:
		return
	########## DEBUG PROJECTILES
	## Create a sphere at the collision position
	#var sphere = SphereMesh.new()
	#var sphere_instance = MeshInstance3D.new()
	#sphere_instance.mesh = sphere
	#sphere_instance.transform.origin = collision.position
	#sphere_instance.scale = Vector3(0.1,0.1,0.1)
	## Create a ShaderMaterial with a red color
	#var red_material = StandardMaterial3D.new()
	#red_material.albedo_color = Color.RED
	## Assign the material to the sphere
	#sphere_instance.material_override = red_material
	## Add the sphere to the scene
	#get_tree().get_root().add_child(sphere_instance)
	#############
	var collider = collision.collider as Node
	var bone = collision.collider as CharacterBody3D
	if bone:
		return bone
	if collider.has_method("takeDamage"):
		return collider
	elif collider.has_node("shootable"):
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
	if weapons.size() < 1:
		_checkFov()
		return
	if Input.is_action_just_pressed("nextWeapon"):
		_nextWeapon()
	elif Input.is_action_just_pressed("prevWeapon"):
		_prevWeapon()
	_checkFov()
		
func putWeaponAway():
	_putCurrentWeaponAway()
	if aiming:
		_switchAim()
	_refreshMagInfo()
	
func _nextWeapon():
	var currentIndex = _getCurrentWeaponIndex()
	_putCurrentWeaponAway()
	currentIndex += 1
	if currentIndex >= weapons.size():
		currentIndex = 0
	_setCurrentWeapon(weapons[currentIndex])
	
	
func _prevWeapon():
	var currentIndex = _getCurrentWeaponIndex()
	_putCurrentWeaponAway()
	currentIndex -= 1
	if currentIndex < 0:
		currentIndex = weapons.size() - 1
	_setCurrentWeapon(weapons[currentIndex])
	
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
	if aiming and currentWeapon and currentWeapon.weaponType == currentWeapon.WeaponType.SNIPER:
		fov = 30
	WorldUtil.player_cam.fov = fov
