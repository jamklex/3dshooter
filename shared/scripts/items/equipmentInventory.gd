extends Inventory
class_name EquipmentInventory

const ALLOWED_ITEM_MAP = {
	GameItem.GameItemType.MODULE: 2,
	GameItem.GameItemType.WEAPON: 2
}

static func from(data: Dictionary) -> EquipmentInventory:
	var inv = EquipmentInventory.new()
	for key in data.keys():
		inv.add(key, data.get(key))
	return inv

func _can_store(id:String, amount:int) -> bool:
	var item_type = ItemHelper.get_item(id).type
	if not item_type in ALLOWED_ITEM_MAP.keys():
		return false
	return _get_places_for_type(item_type) >= amount
	
func _get_places_for_type(item_type: GameItem.GameItemType):
	if not item_type in ALLOWED_ITEM_MAP.keys():
		return 0
	return ALLOWED_ITEM_MAP.get(item_type,0) - _count_item_types(item_type) 
	
func _count_item_types(item_type: GameItem.GameItemType):
	var count = 0
	for item in items.values():
		var inv_item = item as InventoryItem
		if inv_item.item.type == item_type:
			count += 1
	return count
