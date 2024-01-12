extends Control

@onready var _main_items_grid:ItemsGrid = $HBoxContainer/ItemsGrid
@onready var _side_items_grid:ItemsGrid = $HBoxContainer/player_inv/VBoxCon/ItemsGrid
@onready var _player_items_grid:PlayerItemsGrid = $HBoxContainer/player_inv/VBoxCon/player_items_grid
@onready var _menu:PopupMenu = $menu
var _selected_inventory_item:InventoryItem = null
var _main_inv: Inventory = null
var _side_inv: Inventory = null
var _equip_inv: EquipmentInventory = null

func _visible():
	_load_inventory()
	_show_inventory()

func _load_inventory():
	var player = WorldUtil.player as Player
	_equip_inv = player.equip_inventory
	if player.inMissionMap:
		_main_inv = player.run_inventory
		_side_inv = null
	else:
		_main_inv = player.inventory
		_side_inv = player.run_inventory

func _show_inventory():
	_main_items_grid.show_inventory(_main_inv, true)
	_side_items_grid.visible = true if _side_inv else false
	if _side_inv:
		_side_items_grid.show_inventory(_side_inv, true)
	_player_items_grid.show_equip_inventory(_equip_inv)

func _on_inventory_item_clicked(inventory_item):
	if not inventory_item:
		return
	_selected_inventory_item = inventory_item
	_clear_menu()
	_menu.add_item("Move to run inventory", 1)
	_menu.add_item("Equip", 2) # Check if equipable
	_show_menu()
	
func _on_run_inventory_item_clicked(inventory_item):
	if not inventory_item:
		return
	_selected_inventory_item = inventory_item
	_clear_menu()
	_menu.add_item("Move to player inventory", 3)
	_menu.add_item("Equip", 4) # Check if equipable
	_show_menu()
	
func _on_equipment_inventory_item_clicked(inventory_item):
	if not inventory_item:
		return
	_selected_inventory_item = inventory_item
	_clear_menu()
	_menu.add_item("Move to player inventory", 5)
	_menu.add_item("Move to run inventory", 6)
	_show_menu()
	
func _clear_menu():
	_menu.clear()
	
func _show_menu():
	_menu.position = get_global_mouse_position()
	_menu.show()

func _on_menu_id_pressed(id):
	match id:
		# from main inventory
		1:
			_main_inv.moveItem(_side_inv, _selected_inventory_item.item.id)
		2:
			_main_inv.moveItemSome(_equip_inv, _selected_inventory_item.item.id, 1)
		# from side inventory
		3:
			_side_inv.moveItem(_main_inv, _selected_inventory_item.item.id)
		4:
			_side_inv.moveItemSome(_equip_inv, _selected_inventory_item.item.id, 1)
		# from equip inventory
		5:
			_equip_inv.moveItemSome(_main_inv, _selected_inventory_item.item.id, 1)
		6:
			_equip_inv.moveItemSome(_side_inv, _selected_inventory_item.item.id, 1)
	_show_inventory()
	_selected_inventory_item = null

