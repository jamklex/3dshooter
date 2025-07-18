@tool
extends Panel
class_name ItemsGrid

signal on_item_clicked(inventory_item:InventoryItem, slot_action: Slot.Action)
var _inventory:Inventory = null
var _show_non_tradeable = false
@onready var _container:GridContainer = $ScrollContainer/CenterContainer/slots
@onready var _itemInfos:ItemInfos = $ItemInfos
var slot_scene = preload("res://shared/ui/items_grid/slot.tscn") as PackedScene


@export_range(1,20) var columns = 1:
	set(new_columns):
		columns = new_columns
		_init_slots()
		
@export_range(1,20) var rows = 1:
	set(new_rows):
		rows = new_rows
		_init_slots()
		
func _init_slots():
	_container = get_node("ScrollContainer/CenterContainer/slots") as GridContainer
	for slot in _get_slots():
		_container.remove_child(slot)
	_container.columns = columns
	var total_slots = rows * columns
	for i in range(total_slots):
		var slot = slot_scene.instantiate() as Slot
		_container.add_child(slot)
	for slot in _get_slots():
		slot.clicked.connect(_on_slot_clicked)
		slot.mouseHovered.connect(_on_slot_hovered)
		slot.mouseExited.connect(_on_slot_left)
		
func _on_slot_clicked(inventory_item:InventoryItem, slot_action: Slot.Action):
	if not inventory_item:
		return
	on_item_clicked.emit(inventory_item, slot_action)
	
func _on_slot_hovered(inventory_item:InventoryItem):
	if not inventory_item:
		return
	_itemInfos.show_item_infos(inventory_item)
	
func _on_slot_left(inventory_item:InventoryItem):
	_itemInfos.hide_item_infos()
		
func _get_slots():
	var slots = []
	for child in _container.get_children():
		slots.append(child)
	return slots
	
func _get_empty_slot():
	for slot in _get_slots():
		if slot.is_empty():
			return slot
	return null
		
func show_inventory(inventory:Inventory, show_non_tradeable=false):
	_inventory = inventory
	_show_non_tradeable = show_non_tradeable
	refresh()

func refresh():
	for slot in _get_slots():
		slot.clear()
	if not _inventory:
		return
	var shopInventory = _inventory as ShopInventory
	if shopInventory:
		refreshShopInventory()
	else:
		refreshInventory()
		
func refreshShopInventory():
	var shopInventory = _inventory as ShopInventory
	for inventory_item in shopInventory.itemList:
		if inventory_item.amount == 0:
			continue
		if not inventory_item.item.tradeable and not _show_non_tradeable:
			continue
		var empty_slot = _get_empty_slot()
		if not empty_slot:
			return
		empty_slot.show_item(inventory_item)
		
func refreshInventory():
	for item in _inventory.items.values():
		var inventory_item = item as InventoryItem
		if inventory_item.amount == 0:
			continue
		if not inventory_item.item.tradeable and not _show_non_tradeable:
			continue
		if inventory_item.item.type in [GameItem.GameItemType.WEAPON, GameItem.GameItemType.MODULE, GameItem.GameItemType.BLUEPRINT]:
			for i in inventory_item.amount:
				var one_inventory_item = InventoryItem.from(inventory_item.item.id, 1)
				var empty_slot = _get_empty_slot()
				if not empty_slot:
					print("Not enough slots!")
					return
				empty_slot.show_item(one_inventory_item)
		else:
			var empty_slot = _get_empty_slot()
			if not empty_slot:
				print("Not enough slots!")
				return
			empty_slot.show_item(inventory_item)
