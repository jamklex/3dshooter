extends Node3D
class_name Shooter

@export var raycast:RayCast3D
@export var weaponHolder:Node3D
@export var playerSkeleton:Skeleton3D
@export var aimOverride:SkeletonIK3D
var weapons:Array[Weapon]
var currentWeapon:Weapon
var aiming:bool = false

func _ready():
	addWeapon("res://assets/models/weapons/pistol.tscn")

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
	_handleShooting()
#	if aiming:
#		_overrideSkeleton()
		
func _overrideSkeleton():
	pass
#	set_bone_rot("mixamorig_RightArm", Vector3(0,0,90))
	
func set_bone_rot(boneName:String, ang:Vector3):
	var boneId = playerSkeleton.find_bone(boneName)
	var newpose = playerSkeleton.get_bone_global_pose_no_override(boneId)
	newpose = newpose.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
#	playerSkeleton.set_bone_rest(boneId, newpose)
#	playerSkeleton.set_bone_pose_rotation(boneId, Quaternion(90,0,0,0))
	playerSkeleton.set_bone_global_pose_override(boneId, newpose, 1, true)
	
func _handleShooting():
	if not currentWeapon:
		return
	if not Input.is_action_just_pressed("shoot"):
		return
	print("Shooooting...")

func _handleAimSwitching():
	if not currentWeapon:
		return
	if not Input.is_action_just_pressed("aim"):
		return
	aiming = !aiming
	print("Aiming: " + str(aiming))
	if aiming:
		aimOverride.start()
	else: 
		aimOverride.stop()
#	if not aiming:
#		playerSkeleton.clear_bones_global_pose_override()

func _handleWeaponSwitching():
	if Input.is_action_just_pressed("putWeaponAway"):
		_putWeaponAway()
	if weapons.size() == 0:
		return 
	if Input.is_action_just_pressed("nextWeapon"):
		_nextWeapon()
	elif Input.is_action_just_pressed("prevWeapon"):
		_prevWeapon()
	
func _nextWeapon():
	if currentWeapon:
		_putWeaponAway()
	var currentIndex = _getCurrentWeaponIndex()
	currentIndex += 1
	if currentIndex >= weapons.size():
		currentIndex = 0
	_setCurrentWeapon(weapons[currentIndex])
	
func _prevWeapon():
	if currentWeapon:
		_putWeaponAway()
	var currentIndex = _getCurrentWeaponIndex()
	currentIndex -= 1
	if currentIndex < 0:
		currentIndex = weapons.size() -1
	_setCurrentWeapon(weapons[currentIndex])
	
func _setCurrentWeapon(weapon:Weapon):
	currentWeapon = weapon
	currentWeapon.visible = true
	
func _getCurrentWeaponIndex():
	return weapons.find(currentWeapon)
	
func _putWeaponAway():
	if not currentWeapon:
		return
	currentWeapon.visible = false
	currentWeapon = null
