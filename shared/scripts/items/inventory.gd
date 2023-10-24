extends Object

class_name Inventory

const GOLD_ITEM = "0"
var items = {} as Dictionary
signal onAddItem
signal onRemoveItem

static func from(data: Dictionary) -> Inventory:
	var inv = Inventory.new()
	for key in data.keys():
		inv.add(key, data.get(key))
	return inv

static func empty() -> Inventory:
	return Inventory.new()

func duplicate() -> Inventory:
	return Inventory.from(to_dict())

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
	onRemoveItem.emit([id,amount])

func moveAllItems(toInv:Inventory):
	for key in items.keys():
		toInv.add(key, count(key))
		items.erase(key)
		onRemoveItem.emit([key,count(key)])

func remove(id:String, amount:int) -> bool:
	if not check(id, amount):
		return false
	items.get(id).remove(amount)
	onRemoveItem.emit([id,count(id)])
	if !check(id, 1):
		items.erase(id)
	return true

func add(id:String, amount:int):
	if !items.has(id):
		items[id] = InventoryItem.from(id, amount)
	else:
		items.get(id).add(amount)
	onAddItem.emit([id,count(id)])

func set_total(id:String, amount:int):
	if !items.has(id):
		items[id] = InventoryItem.from(id, amount)
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

func to_readable_dict() -> Dictionary:
	var dict = {}
	for invItem in items.values():
		dict[invItem.item.name] = invItem.amount
	return dict
