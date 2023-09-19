extends Node3D
class_name Shooter

@export var raycast:RayCast3D
@export var weapons:Array[Node]
var currentWeapon:Weapon
var aiming:bool = false

func handle():
	_handleWeaponSwitching()
	_handleAimSwitching()
	_handleShooting()
	
func _handleShooting():
	if not currentWeapon:
		return
	if not Input.is_action_just_pressed("shoot"):
		return
	print("Shooooting...")

func _handleAimSwitching():
	if Input.is_action_just_pressed("aim"):
		aiming = !aiming
		print("Aiming: " + str(aiming))

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
#	_setWeaponSceneAsCurrentWeapon(weapons[currentIndex])
	
func _prevWeapon():
	if currentWeapon:
		_putWeaponAway()
	var currentIndex = _getCurrentWeaponIndex()
	currentIndex -= 1
	if currentIndex < 0:
		currentIndex = weapons.size() -1
#	_setWeaponSceneAsCurrentWeapon(weapons[currentIndex])
	
#func _setWeaponSceneAsCurrentWeapon(weapon:PackedScene):
#	pass
	
func _getCurrentWeaponIndex():
	return weapons.find(currentWeapon)
	
func _putWeaponAway():
	if not currentWeapon:
		return
	currentWeapon.queue_free()
	currentWeapon = null
