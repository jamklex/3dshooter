extends Control

@onready var _items_grid:ItemsGrid = $HBoxContainer/ItemsGrid
@onready var _item_info:ItemInfo = $HBoxContainer/ItemInfo

func _visible():
	_load_inventory()

func _get_inventory() -> Inventory:
	var player = WorldUtil.player as Player
	var inventory:Inventory = null
	if player.inMissionMap:
		inventory = player.run_inventory
	else:
		inventory = player.inventory
	return inventory

func _load_inventory():
	_items_grid.show_inventory(_get_inventory())


func _on_item_clicked(inventory_item:InventoryItem):
	_item_info.show_item_info(inventory_item)
