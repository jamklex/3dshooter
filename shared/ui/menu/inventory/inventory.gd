extends Control

@onready var _main_items_grid:ItemsGrid = $HBoxContainer/ItemsGrid
@onready var _side_items_grid:ItemsGrid = $HBoxContainer/player_inv/VBoxCon/ItemsGrid
@onready var _player_items_grid:PlayerItemsGrid = $HBoxContainer/player_inv/VBoxCon/player_items_grid
@onready var _menu:PopupMenu = $menu
@onready var _amount_slider:AmountSlider = $AmountSlider
var _selected_inventory_item:InventoryItem = null
var _preselected_move:MOVE = MOVE.NONE
var _main_inv: Inventory = null
var _side_inv: Inventory = null
var _equip_inv: EquipmentInventory = null

enum MOVE {
	NONE,
	MAIN_TO_SIDE, MAIN_TO_EQUIP,
	SIDE_TO_MAIN, SIDE_TO_EQUIP,
	EQUIP_TO_MAIN, EQUIP_TO_SIDE
}

func _ready():
	_amount_slider.on_apply.connect(amount_slider_apply)

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
	
func _on_main_inventory_clicked(inventory_item:InventoryItem):
	if _side_inv:
		_on_inventory_item_clicked(inventory_item)
	else:
		_on_run_inventory_item_clicked(inventory_item)

func _on_inventory_item_clicked(inventory_item:InventoryItem):
	if not inventory_item:
		return
	_selected_inventory_item = inventory_item
	_clear_menu()
	_menu.add_item("Move to run inventory", MOVE.MAIN_TO_SIDE) # TODO: use enum
	if _equip_inv.can_store(inventory_item.item.id, 1):
		_menu.add_item("Equip", MOVE.MAIN_TO_EQUIP) # TODO: use enum...
	_show_menu()
	
func _on_run_inventory_item_clicked(inventory_item:InventoryItem):
	if not inventory_item:
		return
	_selected_inventory_item = inventory_item
	_clear_menu()
	if not WorldUtil.player.inMissionMap:
		_menu.add_item("Move to player inventory", MOVE.SIDE_TO_MAIN)
	if _equip_inv.can_store(inventory_item.item.id, 1):
		_menu.add_item("Equip", MOVE.SIDE_TO_EQUIP if _side_inv else MOVE.MAIN_TO_EQUIP)
	_show_menu()
	
func _on_equipment_inventory_item_clicked(inventory_item:InventoryItem):
	if not inventory_item:
		return
	_selected_inventory_item = inventory_item
	_clear_menu()
	if not WorldUtil.player.inMissionMap:
		_menu.add_item("Move to player inventory", MOVE.EQUIP_TO_MAIN)
	_menu.add_item("Move to run inventory", MOVE.EQUIP_TO_SIDE if _side_inv else MOVE.EQUIP_TO_MAIN)
	_show_menu()
	
func _clear_menu():
	_menu.clear()
	
func _show_menu():
	if _menu.item_count == 0:
		return
	_menu.position = get_global_mouse_position()
	_menu.show()

func _on_menu_id_pressed(move:MOVE):
	if not move in [MOVE.MAIN_TO_SIDE, MOVE.SIDE_TO_MAIN] or _selected_inventory_item.amount == 1:
		_apply_item_move(move, 1)
		return
	_preselected_move = move
	_show_amount_slider()
		
func _show_amount_slider():
	_amount_slider.show_slider(_selected_inventory_item, false)
	
func amount_slider_apply(inventory_item:InventoryItem, amount:int, rightToLeft:bool):
	if _preselected_move == MOVE.NONE:
		return
	_apply_item_move(_preselected_move, amount)

func _apply_item_move(move:MOVE, amount):
	match move:
		MOVE.MAIN_TO_SIDE:
			_main_inv.moveItemSome(_side_inv, _selected_inventory_item.item.id, amount)
		MOVE.MAIN_TO_EQUIP:
			_main_inv.moveItemSome(_equip_inv, _selected_inventory_item.item.id, 1)
		MOVE.SIDE_TO_MAIN:
			_side_inv.moveItemSome(_main_inv, _selected_inventory_item.item.id, amount)
		MOVE.SIDE_TO_EQUIP:
			_side_inv.moveItemSome(_equip_inv, _selected_inventory_item.item.id, 1)
		MOVE.EQUIP_TO_MAIN:
			_equip_inv.moveItemSome(_main_inv, _selected_inventory_item.item.id, 1)
		MOVE.EQUIP_TO_SIDE:
			_equip_inv.moveItemSome(_side_inv, _selected_inventory_item.item.id, 1)
	_show_inventory()
	_selected_inventory_item = null
	_preselected_move = 0 
