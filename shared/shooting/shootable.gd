extends Node
class_name Shootable

@export var max_health:int
@export var enemy_type: EnemyType = EnemyType.DUMMY
var id:int = -1
var health:int
var died:bool = false
signal healthReachedZero
signal onDamageTaken(damage:int)
signal onHealthChanged(health:int)

enum EnemyType {
	DUMMY, NORMAL
}

func resetHealth():
	health = max_health
	died = false

func takeDamage(damage:int):
	onDamageTaken.emit(damage)
	health -= damage
	onHealthChanged.emit(health)
	if health <= 0 and not died:
		_die()
		died = true

func setStartHealth(new_health:int):
	max_health = new_health
	health = max_health
			
func _die():
	if healthReachedZero.get_connections().size() > 0:
		healthReachedZero.emit()
	else:
		get_parent().queue_free()

func _ready():
	health = max_health
