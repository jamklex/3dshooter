extends Object

class_name InventoryItem

var item: GameItem
var amount: int

func add(value: int):
	amount += value

func remove(value: int):
	amount -= value
