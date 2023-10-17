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
var reloading:bool = false
var useRealMunition:bool = true
@onready var _reloadTimer:Timer = $reloadTimer
@onready var _magInfo:Label = $magInfo
var soundPlayer:AudioStreamPlayer
signal onShootableDie

const _ITEM_WEAPON_MAP = {
	"6": "res://shared/shooting/weapons/pistol/_main.tscn"
}

const _MUNITION_MAP = {
	Weapon.WeaponType.PISTOL: "7"
}

func _ready():
	_reloadTimer.timeout.connect(_reload)
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
	weapon.visible = false
	_reloadWeapon(weapon)
	weapons.append(weapon)
	weaponHolder.add_child(weapon)
	
func unlockPlayerInventoryWeapons(playerInventory:Inventory):
	for itemId in playerInventory.item_ids():
		if _isWeaponId(itemId):
			_addWeaponForItemId(itemId)
	
func putBulletsToInventory():
	if not currentWeapon:
		return
	if not useRealMunition:
		return
	var restMun = currentWeapon.restMagShoots
	if restMun <= 0:
		return
	_addRestAmmo(currentWeapon.weaponType, restMun)
	
func handlePlayerInventoryChanged(payload:Array):
	var itemId = payload[0]
	if not _MUNITION_MAP.has(itemId):
		return
	_refreshMagInfo()

func checkForWeaponAction(payload:Array):
	var itemId = payload[0]
	var newAmount = int(payload[1])
	if not _isWeaponId(itemId):
		return
	var gotWeapon = newAmount >= 1
	var weaponAlreadyInitizalized = _weaponAlreadyInitizalized(itemId)
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
	if currentWeapon and not reloading:
		_refreshMagInfo()
		
func handle():
	_handleWeaponSwitching()
	_handleAimSwitching()
	_handleReloading()
	_handleShooting()
	
func _weaponAlreadyInitizalized(weaponId:String):
	var scenePathForWeaponId = _ITEM_WEAPON_MAP.get(weaponId)
	if not scenePathForWeaponId:
		return
	for weapon in weapons:
		if weapon.scene_file_path == scenePathForWeaponId:
			return true
	return false
	
func _addWeaponForItemId(weaponId:String):
	var scenePathForWeaponId = _ITEM_WEAPON_MAP.get(weaponId)
	if not scenePathForWeaponId:
		return
	addWeapon(scenePathForWeaponId)
	
func _removeWeaponForItemId(weaponId:String):
	var scenePathForWeaponId = _ITEM_WEAPON_MAP.get(weaponId)
	if not scenePathForWeaponId:
		return
	for weapon in weapons:
		if weapon.scene_file_path == scenePathForWeaponId:
			_removeWeapon(weapon)
			return
			
func _removeWeapon(weapon:Weapon):
	if weapon == currentWeapon:
		_putWeaponAway()
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
	
func _handleReloading():
	if not currentWeapon:
		return
	if reloading:
		return
	if not Input.is_action_just_pressed("reload"):
		return
	if currentWeapon.isMagFull():
		return
	if _getRestAmmo(currentWeapon.weaponType) == 0:
		return
	if aiming:
		aimOverride.stop()
	_startReload()
	
func _startReload():
	reloading = true
	soundPlayer.stream = currentWeapon.reloadSound
	soundPlayer.play(0)
	_reloadTimer.start(currentWeapon.reloadTimeSecs)
	_refreshMagInfo()
	
func _reload():
	_reloadWeapon(currentWeapon)
	reloading = false
	_refreshMagInfo()
	if aiming:
		aimOverride.start()
		
func _reloadWeapon(weapon:Weapon):
	var restAmmo = _getRestAmmo(weapon.weaponType)
	if restAmmo == -1:
		weapon.reload(weapon.magSize)
	else:
		_removeRestAmmo(weapon.weaponType, weapon.reload(_getRestAmmo(weapon.weaponType)))
	
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
	if reloading:
		magInfoText = "Reloading..."
	elif currentWeapon:
		var restAmmo = _getRestAmmo(currentWeapon.weaponType)
		if restAmmo == -1:
			restAmmo = "∞"
		magInfoText = str(currentWeapon.restMagShoots," / ", restAmmo)
	_magInfo.text = magInfoText
	
func _getRestAmmo(weaponType:Weapon.WeaponType):
	if not useRealMunition:
		return -1
	return _getAmmoInInventory(weaponType)
	
func _getAmmoInInventory(weaponType:Weapon.WeaponType):
	var munitionId = _MUNITION_MAP.get(weaponType)
	if not munitionId:
		return currentWeapon.magSize
	var playerInv = WorldUtil.player.inventory as Inventory
	return playerInv.count(munitionId)
	
func _handleShooting():
	if not currentWeapon:
		return
	if reloading:
		return
	if currentWeapon.needReload():
		return
	if not Input.is_action_just_pressed("shoot"):
		return
	if not aiming:
		return
	_shoot()
	currentWeapon.restMagShoots -= 1
	_refreshMagInfo()

func _shoot():
	soundPlayer.stream = currentWeapon.shotSound
	soundPlayer.play(0)
	currentWeapon.muzzleFlare.restart()
	var shootable = _raycastForShootable()
	if not shootable:
		return
	shootable.takeDamage(currentWeapon.damage)
	shootable = shootable as Shootable
	if shootable and shootable.currentHealth <= 0 and not shootable.died:
		onShootableDie.emit(shootable)
	
func _raycastForShootable() -> Node:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,
		camera.global_position - camera.global_transform.basis.z * raycastMeters)
	var collision = space.intersect_ray(query)
	if not collision:
		return
	var collider = collision.collider as Node
	if collider.has_method("takeDamage"):
		return collider
	elif collider.has_node("shootable"):
		return collider.get_node("shootable")
	return null

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

func _handleWeaponSwitching():
	if Input.is_action_just_pressed("putWeaponAway"):
		_putWeaponAway()
	if weapons.size() == 0:
		return 
	if Input.is_action_just_pressed("nextWeapon"):
		_nextWeapon()
	elif Input.is_action_just_pressed("prevWeapon"):
		_prevWeapon()
		
func _putWeaponAway():
	_putCurrentWeaponAway()
	if aiming:
		_switchAim()
	_refreshMagInfo()
	
func _nextWeapon():
	_putCurrentWeaponAway()
	var currentIndex = _getCurrentWeaponIndex()
	currentIndex += 1
	if currentIndex >= weapons.size():
		currentIndex = 0
	_setCurrentWeapon(weapons[currentIndex])
	
func _prevWeapon():
	_putCurrentWeaponAway()
	var currentIndex = _getCurrentWeaponIndex()
	currentIndex -= 1
	if currentIndex < 0:
		currentIndex = weapons.size() -1
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
	currentWeapon.visible = false
	currentWeapon = null
