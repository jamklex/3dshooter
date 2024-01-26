extends Node3D
class_name Weapon

enum WeaponType {PISTOL, RIFLE, SNIPER, SHOTGUN}

@export var weaponName:String
@export var description:String
@export var magSize:int
@export var weaponType:WeaponType
@export var reloadMagTimeSecs:float
@export var damage:int
@export var shotSound:AudioStream
@export var emptyShotSound:AudioStream
@export var reloadMagSound:AudioStream
@export var muzzleFlare:GPUParticles3D
var manualLoading = false
var loaded = false
var restMagShoots:int


func _ready():
	manualLoading = [WeaponType.SNIPER, WeaponType.SHOTGUN].find(weaponType) > -1
	if reloadMagSound:
		reloadMagTimeSecs = reloadMagSound.get_length()
		
func needReload():
	return manualLoading && !loaded

func needReloadMag():
	return restMagShoots <= 0
	
func isMagFull():
	return restMagShoots == magSize
	
func reload(addShoots:int):
	var reloadedShoots = addShoots
	if reloadedShoots > magSize:
		reloadedShoots = magSize
	reloadedShoots -= restMagShoots
	restMagShoots += reloadedShoots
	return reloadedShoots
