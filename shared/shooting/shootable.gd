extends Node
class_name Shootable

@export var health:int
var currentHealth:int
var died:bool = false
signal healthReachedZero
signal onDamageTaken
signal onHealthChanged(health:int)

func resetHealth():
	currentHealth = health
	died = false

func takeDamage(damage:int):
	onDamageTaken.emit(damage)
	currentHealth -= damage
	onHealthChanged.emit(currentHealth)
	if currentHealth <= 0 and not died:
		_die()
		died = true
		return true
	return false

func setStartHealth(newHealth:int):
	health = newHealth
	currentHealth = newHealth
			
func _die():
	if healthReachedZero.get_connections().size() > 0:
		healthReachedZero.emit()
	else:
		get_parent().queue_free()

func _ready():
	currentHealth = health
