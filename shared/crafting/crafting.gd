extends Control
class_name Crafting

@onready var _inventory_grid:ItemsGrid = $bg/leftInv/items
@onready var _crafting_grid:ItemsGrid = $bg/VBoxContainer/craftInv/items
@onready var _blueprint_slot:Slot = $bg/VBoxContainer/blueprint
@onready var _craft_button:Button = $bg/VBoxContainer/Panel/CraftButton
@onready var _amount_slider:AmountSlider = $bg/AmountSlider
var _equip_inv: EquipmentInventory = null
var _crafting_inv: Inventory = null
var _blueprint_item: InventoryItem = null
var _preselected_move:MOVE = MOVE.NONE
var _selected_inventory_item:InventoryItem = null

enum MOVE {
	NONE,
	CRAFT_TO_EQUIP,EQUIP_TO_CRAFT
}

func _ready():
	_craft_button.disabled = true

func _visible():
	_equip_inv = WorldUtil.player.equip_inventory
	_refresh_item_grids()
	
func _refresh_item_grids():
	_inventory_grid.show_inventory(_equip_inv, true)
	_crafting_grid.show_inventory(_crafting_inv, true)
	_blueprint_slot.show_item(_blueprint_item)

func _on_blueprint_clicked(inventory_item:InventoryItem):
	if !inventory_item:
		return
	_equip_inv.add(inventory_item.item.id,inventory_item.amount)
	_blueprint_item = null
	_refresh_item_grids()

func _on_craft_inv_item_clicked(inventory_item:InventoryItem):
	if inventory_item.amount == 1:
		_apply_item_move(MOVE.CRAFT_TO_EQUIP, 1)
	else:
		_selected_inventory_item = inventory_item
		_preselected_move = MOVE.CRAFT_TO_EQUIP
		_show_amount_slider()
	_refresh_item_grids()

func _on_equip_inv_item_clicked(inventory_item:InventoryItem):
	if inventory_item.item.type == GameItem.GameItemType.BLUEPRINT:
		_blueprint_item = InventoryItem.from(inventory_item.item.id, 1)
		_equip_inv.remove(inventory_item.item.id, 1)
	else:
		if inventory_item.amount == 1:
			_apply_item_move(MOVE.EQUIP_TO_CRAFT, 1)
		else:
			_selected_inventory_item = inventory_item
			_preselected_move = MOVE.EQUIP_TO_CRAFT
			_show_amount_slider()
	_refresh_item_grids()
	
func amount_slider_apply(inventory_item:InventoryItem, amount:int, rightToLeft:bool):
	if _preselected_move == MOVE.NONE:
		return
	_apply_item_move(_preselected_move, amount)
	
func _show_amount_slider():
	_amount_slider.show_slider(_selected_inventory_item, false)
	
func _apply_item_move(move:MOVE, amount):
	match move:
		MOVE.EQUIP_TO_CRAFT:
			_equip_inv.moveItemSome(_crafting_inv, _selected_inventory_item.item.id, amount)
		MOVE.CRAFT_TO_EQUIP:
			_crafting_inv.moveItemSome(_equip_inv, _selected_inventory_item.item.id, 1)
	_refresh_item_grids()
	_selected_inventory_item = null
	_preselected_move = 0 
	
func _close_crafting():
	WorldUtil.player.body.setInDialog(false)
	queue_free()
