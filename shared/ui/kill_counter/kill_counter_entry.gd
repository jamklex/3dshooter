extends HBoxContainer
class_name KillCounterEntry

@onready var nameLabel = $nameLabel
@onready var counterLabel = $counterLabel
var enemyName = ""
var killed = 0
var total = 0

func _ready() -> void:
	_refreshLabels()

func setAllInfos(name: String, killed_amount: int, total_amount: int):
	enemyName = name
	killed = killed_amount
	total = total_amount
	_refreshLabels()

func setName(name: String):
	enemyName = name
	_refreshLabels()
	
func setAmount(killed_amount: int, total_amount: int):
	killed = killed_amount
	total = total_amount
	_refreshLabels()
	
func setKilledAmount(new_amount: int):
	killed = new_amount
	_refreshLabels()

func setTotalAmount(new_amount: int):
	total = new_amount
	_refreshLabels()
	
func _refreshLabels():
	if nameLabel:
		nameLabel.text = enemyName
	if counterLabel:
		counterLabel.text = str(killed) + "/" + str(total)
