extends Object

class_name Inventory

const GOLD_ITEM = "0"
var items = {} as Dictionary

static func from(data: Dictionary) -> Inventory:
	var inv = Inventory.new()
	for key in data.keys():
		inv.add(key, data.get(key))
	return inv

static func empty() -> Inventory:
	return Inventory.new()

func duplicate() -> Inventory:
	var inv = Inventory.new()
	for key in items.keys():
		inv.add(key, count(key))
	return inv

func as_inventory_item(id: String, amount: int) -> InventoryItem:
	return to_inventory_item(ItemHelper.get_item(id), amount)

func to_inventory_item(item: GameItem, amount: int) -> InventoryItem:
	var inv_item = InventoryItem.new()
	inv_item.item = item
	inv_item.amount = amount
	return inv_item

func item_ids() -> Array:
	return items.keys()

func moveItemSome(toInv:Inventory, id:String, amount:int) -> bool:
	if remove(id, amount):
		toInv.add(id, amount)
		return true
	return false

func moveItem(toInv:Inventory, id:String):
	var amount = count(id)
	toInv.add(id, amount)
	items.erase(id)

func moveAllItems(toInv:Inventory):
	for key in items.keys():
		toInv.add(key, count(key))
		items.erase(key)

func remove(id:String, amount:int) -> bool:
	if !check(id, amount):
		return false
	items.get(id).remove(amount)
	if !check(id, 1):
		items.erase(id)
	return true

func add(id:String, amount:int):
	if !items.has(id):
		items[id] = as_inventory_item(id, amount)
	else:
		items.get(id).add(amount)

func set_total(id:String, amount:int):
	if !items.has(id):
		items[id] = as_inventory_item(id, amount)
	else:
		items.get(id).amount = amount

func check(id:String, minAmount:int):
	return count(id) >= minAmount

func count(id:String) -> int:
	if items.has(id):
		return items.get(id).amount
	return 0

func is_empty():
	return items.keys().is_empty()

func to_dict() -> Dictionary:
	var dict = {}
	for key in items.keys():
		dict[key] = count(key)
	return dict
