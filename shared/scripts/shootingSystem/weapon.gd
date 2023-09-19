extends Node3D
class_name Weapon

enum WeaponType {PISTOL, RIFLE, SNIPER}

@export var weaponName:String
@export var description:String
@export var magSize:int
@export var weaponType:WeaponType

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Weapon got initialized!")
	print("WeaponName:" + weaponName)
	print("Description:" + description)
