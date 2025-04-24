extends Lootable
class_name Storage


func _ready():
	set_looted(false)
	
func interact(player: Player):
	WorldUtil.openStorage()
