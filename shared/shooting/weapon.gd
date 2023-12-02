extends Node3D
class_name Weapon

enum WeaponType {PISTOL, RIFLE, SNIPER}

@export var weaponName:String
@export var description:String
@export var magSize:int
@export var weaponType:WeaponType
@export var reloadTimeSecs:float
@export var damage:int
@export var shotSound:AudioStream
@export var emptyShotSound:AudioStream
@export var reloadSound:AudioStream
@export var muzzleFlare:GPUParticles3D
var restMagShoots:int


func _ready():
	if reloadSound:
		reloadTimeSecs = reloadSound.get_length()

func needReload():
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
