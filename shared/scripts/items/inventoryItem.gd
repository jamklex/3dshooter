extends Object

class_name InventoryItem

var item: GameItem
var amount: int

static func from(id: String, _amount: int) -> InventoryItem:
	var _item = InventoryItem.new()
	_item.item = ItemHelper.get_item(id)
	_item.amount = _amount
	return _item

func add(value: int):
	amount += value

func remove(value: int):
	amount -= value

func toDict() -> Dictionary:
	return {
		item.id: amount
	}
