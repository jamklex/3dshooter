extends Node
class_name InventoryUtil

static func moveItem(fromInv:Dictionary, toInv:Dictionary, item:String, amount:int):
	if removeFromInventory(fromInv, item, amount):
		addToInventory(toInv, item, amount)
		return true
	return false
	
static func moveItemComplete(fromInv:Dictionary, toInv:Dictionary, item:String):
	var itemAmount = getItemCount(fromInv, item)
	removeFromInventory(fromInv, item, itemAmount)
	addToInventory(toInv, item, itemAmount)
	
static func moveAllItems(fromInv:Dictionary, toInv:Dictionary):
	for item in fromInv.keys():
		var itemAmount = getItemCount(fromInv, item)
		removeFromInventory(fromInv, item, itemAmount)
		addToInventory(toInv, item, itemAmount)
	
static func getItemCount(inv:Dictionary, item:String):
	if item in inv:
		return inv[item]
	return 0

static func removeFromInventory(inv:Dictionary, item:String, amount:int):
	if !checkInventory(inv, item, amount):
		return false
	inv[item] -= amount
	if !checkInventory(inv, item, amount):
		inv.erase(item)
	return true
	
static func addToInventory(inv:Dictionary, item:String, amount:int):
	if item in inv:
		inv[item] += amount
	else:
		inv[item] = amount
	
static func checkInventory(inv:Dictionary, item:String, minAmount:int):
	if item in inv:
		return inv[item] >= minAmount
	return false
	
