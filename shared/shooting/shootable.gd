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
		_die()
			
func _die():
	if healthReachedZero.get_connections().size() > 0:
		healthReachedZero.emit()
	else:
		get_parent().queue_free()

func _ready():
	currentHealth = health
