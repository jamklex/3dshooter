extends Control

@onready var _main_items_grid:ItemsGrid = $HBoxContainer/ItemsGrid
@onready var _player_items_grid:PlayerItemsGrid = $HBoxContainer/player_inv/VBoxCon/player_items_grid
@onready var _menu:PopupMenu = $menu
@onready var _amount_slider:AmountSlider = $AmountSlider
var _selected_inventory_item:InventoryItem = null
var _preselected_move:MOVE = MOVE.NONE
var _main_inv: Inventory = null
var _equip_inv: EquipmentInventory = null

enum MOVE {
	NONE,
	MAIN_TO_EQUIP,
	EQUIP_TO_MAIN
}

func _ready():
	_amount_slider.on_apply.connect(amount_slider_apply)

func _visible():
	_load_inventory()
	_show_inventory()

func _load_inventory():
	var player = WorldUtil.player as Player
	_equip_inv = player.equipment
	_main_inv = player.inventory

func _show_inventory():
	_main_items_grid.show_inventory(_main_inv, true)
	_player_items_grid.show_equip_inventory(_equip_inv)
	
func _on_inventory_clicked(inventory_item: InventoryItem, slot_action: Slot.Action):	
	if inventory_item.item.type in [GameItem.GameItemType.MODULE, GameItem.GameItemType.WEAPON]:
		if _equip_inv.can_store(inventory_item.item.id, 1):
			_main_inv.moveItemSome(_equip_inv, inventory_item.item.id, 1)
			_show_inventory()
		return

func _on_equipment_inventory_item_clicked(inventory_item:InventoryItem, slot_action:Slot.Action):
	if not inventory_item:
		return
	if slot_action != Slot.Action.MOVE_SINGLE_ITEM:
		return
	_equip_inv.moveItemSome(_main_inv, inventory_item.item.id, 1)
	_show_inventory()
	
func _clear_menu():
	_menu.clear()
	
func _show_menu():
	if _menu.item_count == 0:
		return
	_menu.position = get_global_mouse_position()
	_menu.show()

func _show_amount_slider():
	_amount_slider.show_slider(_selected_inventory_item, false)
	
func amount_slider_apply(inventory_item:InventoryItem, amount:int, rightToLeft:bool):
	if _preselected_move == MOVE.NONE:
		return
	_apply_item_move(_preselected_move, amount)

func _apply_item_move(move:MOVE, amount):
	match move:
		MOVE.MAIN_TO_EQUIP:
			_main_inv.moveItemSome(_equip_inv, _selected_inventory_item.item.id, 1)
		MOVE.EQUIP_TO_MAIN:
			_equip_inv.moveItemSome(_main_inv, _selected_inventory_item.item.id, 1)
	_show_inventory()
	_selected_inventory_item = null
	_preselected_move = 0 
