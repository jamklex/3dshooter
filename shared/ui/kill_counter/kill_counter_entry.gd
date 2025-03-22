extends HBoxContainer
class_name KillCounterEntry

@onready var nameLabel = $nameLabel
@onready var counterLabel = $counterLabel
var enemyName = ""
var killed = 0
var total = 0

func setName(name: String):
	enemyName = name
	_refreshLabels()
	
func setAmount(killed_amount: int, total_amount: int):
	counterLabel.text = str(killed_amount) + "/" + str(total_amount)
	_refreshLabels()
	
func _refreshLabels():
	pass
