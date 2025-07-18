extends Object

class_name DropItem

var id: String
var amount_fix: int
var amount_min: int
var amount_max: int
var chance: float
var true_amount: int

static func get_from(json: Dictionary):
	var item = DropItem.new()
	item.id = json.get("id", item.id)
	item.chance = json.get("chance")
	if json.has("amount_fix"):
		item.amount_fix = json.get("amount_fix")
	else:
		item.amount_min = json.get("amount_min")
		item.amount_max = json.get("amount_max")
	return item

static func create_fix(_id: String, _amount_fix: int = 1):
	var item = DropItem.new()
	item.id = _id
	item.amount_fix = _amount_fix
	return item

static func create_random(_id: String, _amount_min: int, _amount_max: int):
	var item = DropItem.new()
	item.id = _id
	item.amount_min = _amount_min
	item.amount_max = _amount_max
	item.fix_item = false
	return item

func get_amount():
	if true_amount > 0:
		return true_amount
	true_amount = amount_fix if amount_fix > 0 else randi_range(amount_min+1, amount_max)
	return true_amount

func pretty_name():
	return ItemHelper.get_item_by_id(id).name
