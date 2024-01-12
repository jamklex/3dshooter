extends Panel
class_name PlayerItemsGrid

signal on_item_clicked(inventory_item:InventoryItem)
var _equip_inv:EquipmentInventory = null
@onready var _itemInfos:ItemInfos = $ItemInfos

func show_equip_inventory(equip_inv: EquipmentInventory):
	_equip_inv = equip_inv
	refresh()
	
func refresh():
	for slot in _get_slots():
		slot.clear()
	if not _equip_inv:
		return
	for item in _equip_inv.items.values():
		var inventory_item = item as InventoryItem
		for i in range(inventory_item.amount):
			var empty_slot = _get_empty_slot(inventory_item.item.type)
			if not empty_slot:
				return
			empty_slot.show_item(inventory_item)
		
func _get_empty_slot(item_type:GameItem.GameItemType):
	for slot in _get_slots_by_type(item_type):
		if slot.is_empty():
			return slot
	return null
	
func _get_slots_by_type(item_type:GameItem.GameItemType):
	var needed_type_str = GameItem.GameItemType.keys()[item_type].to_lower()
	return find_children(needed_type_str + "*", "Slot")
		
func _get_slots():
	return find_children("*", "Slot")

func _on_slot_clicked(inventory_item:InventoryItem):
	if not inventory_item:
		return
	on_item_clicked.emit(inventory_item)
	
func _on_slot_hovered(inventory_item:InventoryItem):
	if not inventory_item:
		return
	_itemInfos.show_item_infos(inventory_item)
	
func _on_slot_leaved(inventory_item:InventoryItem):
	_itemInfos.hide_item_infos()
