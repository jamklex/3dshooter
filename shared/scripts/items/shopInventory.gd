extends Inventory
class_name ShopInventory

var itemList: Array[InventoryItem]

static func empty() -> ShopInventory:
	return ShopInventory.new()
	
func duplicate() -> ShopInventory:
	var copy = ShopInventory.new()
	copy.addItems(itemList)
	return copy
	
static func createForItemIds(item_ids: Array) -> ShopInventory:
	var inv = ShopInventory.empty()
	for item_id in item_ids:
		inv.addItems(_create_inventory_items_for_game_item(ItemHelper.get_item_by_id(item_id)))
	return inv

func addItems(items: Array[InventoryItem]):
	super.addItems(items)
	if not itemList:
		itemList = []
	itemList.append_array(items)
	
static func _create_inventory_items_for_game_item(gameItem: GameItem) -> Array[InventoryItem]:
	var inventoryItems: Array[InventoryItem] = []
	if gameItem.type == GameItem.GameItemType.AMMO:
		inventoryItems.append(InventoryItem.from(gameItem.id, 5))
		inventoryItems.append(InventoryItem.from(gameItem.id, 10))
		inventoryItems.append(InventoryItem.from(gameItem.id, 20))
	elif gameItem.type == GameItem.GameItemType.WEAPON or gameItem.type == GameItem.GameItemType.MODULE or gameItem.type == GameItem.GameItemType.BLUEPRINT:
		inventoryItems.append(InventoryItem.from(gameItem.id, 1))
	else: 
		print("No entries for gameitem type: " + str(gameItem.type))
	return inventoryItems
