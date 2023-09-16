extends Object

class_name InventoryItem

var item: GameItem
var amount: int

static func from(id: String, amount: int) -> InventoryItem:
	var item = InventoryItem.new()
	item.item = ItemHelper.get_item(id)
	item.amount = amount
	return item

func add(value: int):
	amount += value

func remove(value: int):
	amount -= value
