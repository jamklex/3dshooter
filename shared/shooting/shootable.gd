extends Node
class_name Shootable

@export var health:int
var currentHealth:int
signal healthReachedZero
signal onDamageTaken

func takeDamage(damage:int):
	onDamageTaken.emit(damage)
	currentHealth -= damage
	if currentHealth <= 0:
		healthReachedZero.emit()

func _ready():
	currentHealth = health
