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
@onready var _reloadTimer:Timer = $reloadTimer
@onready var _magInfo:Label = $magInfo
var soundPlayer:AudioStreamPlayer

func _ready():
	_reloadTimer.timeout.connect(_reload)
	_refreshMagInfo()
	addWeapon("res://shared/shooting/weapons/pistol/_main.tscn")
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
	weapon.reload()
	weapons.append(weapon)
	weaponHolder.add_child(weapon)

func handle():
	_handleWeaponSwitching()
	_handleAimSwitching()
	_handleReloading()
	_handleShooting()
	
func set_bone_rot(boneName:String, ang:Vector3):
	var boneId = playerSkeleton.find_bone(boneName)
	var newpose = playerSkeleton.get_bone_global_pose_no_override(boneId)
	newpose = newpose.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
	playerSkeleton.set_bone_global_pose_override(boneId, newpose, 1, true)
	
func _handleReloading():
	if not currentWeapon:
		return
	if reloading:
		return
	if not Input.is_action_just_pressed("reload"):
		return
	if currentWeapon.isMagFull():
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
	currentWeapon.reload()
	reloading = false
	_refreshMagInfo()
	if aiming:
		aimOverride.start()
	
func _refreshMagInfo():
	var magInfoText = ""
	if reloading:
		magInfoText = "Reloading..."
	elif currentWeapon:
		magInfoText = str(currentWeapon.restMagShoots," / ",currentWeapon.magSize)
	_magInfo.text = magInfoText
	
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
