extends Object

class_name Shop
# create shop inventory which holds inventoryitems as is (item_id, amount) -> to display them as given
static func _create_inventory_items_for_game_item(gameItem: GameItem) -> Array[InventoryItem]:
	var inventoryItems: Array[InventoryItem] = []
	if gameItem.type == GameItem.GameItemType.AMMO:
		inventoryItems.append(InventoryItem.from(gameItem.id, 5))
		inventoryItems.append(InventoryItem.from(gameItem.id, 10))
		inventoryItems.append(InventoryItem.from(gameItem.id, 20))
		inventoryItems.append(InventoryItem.from(gameItem.id, 50))
	elif gameItem.type == GameItem.GameItemType.WEAPON or gameItem.type == GameItem.GameItemType.MODULE:
		inventoryItems.append(InventoryItem.from(gameItem.id, 1))
	return inventoryItems

static func create_shop_inventory(item_ids: Array) -> Inventory:
	var inv = Inventory.empty()
	for item_id in item_ids:
		#inv.addItems(_create_inventory_items_for_game_item(ItemHelper.get_item_by_id(item_id)))
		inv.add(item_id, 999)
	return inv
