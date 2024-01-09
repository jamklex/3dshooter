extends Control

@onready var _items_grid:ItemsGrid = $HBoxContainer/ItemsGrid
@onready var _menu:PopupMenu = $menu

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
	_items_grid.show_inventory(_get_inventory(), true)

func _on_inventory_item_clicked(inventory_item):
	if not inventory_item:
		return
	_clear_menu()
	_menu.add_item("Move to run inventory", 1)
	_menu.add_item("Equip", 2) # Check if equipable
	_show_menu()
	
func _on_run_inventory_item_clicked(inventory_item):
	if not inventory_item:
		return
	_clear_menu()
	_menu.add_item("Move to player inventory", 3)
	_menu.add_item("Equip", 4) # Check if equipable
	_show_menu()
	
func _on_equipment_inventory_item_clicked(inventory_item):
	if not inventory_item:
		return
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
		# from player inventory
		1:
			print("player inv -> run inv")
		2:
			print("player inv -> equip inv")
		# from run inventory
		3:
			print("run inv -> player inv")
		4:
			print("run inv -> equip inv")
		# from equip inventory
		5:
			print("equip inv -> player inv")
		6:
			print("equip inv -> run inv")

