extends Control
class_name Crafting

@onready var _inventory_grid:ItemsGrid = $bg/leftInv/items
@onready var _crafting_grid:ItemsGrid = $bg/VBoxContainer/craftInv/items
@onready var _blueprint_slot:Slot = $bg/VBoxContainer/blueprint
@onready var _craft_button:Button = $bg/VBoxContainer/Panel/CraftButton
@onready var _amount_slider:AmountSlider = $bg/AmountSlider
@onready var _recipe_text:RichTextLabel = $bg/recipeText
var _player_inv: Inventory = null
var _crafting_inv: Inventory = null
var _blueprint_item: InventoryItem = null
var _preselected_move:MOVE = MOVE.NONE
var _selected_inventory_item:InventoryItem = null

enum MOVE {
	NONE,
	CRAFT_TO_PLAYER,PLAYER_TO_CRAFT
}

func _ready():
	_craft_button.disabled = true
	_recipe_text.text = ""

func _visible():
	_player_inv = WorldUtil.player.inventory
	_crafting_inv = Inventory.empty()
	_refresh_item_grids()
	
func _refresh_item_grids():
	_inventory_grid.show_inventory(_player_inv, true)
	_crafting_grid.show_inventory(_crafting_inv, true)
	_blueprint_slot.show_item(_blueprint_item)
	
func _refresh_craft_output():
	var new_recipe_text = ""
	if _blueprint_item:
		var blueprint = _blueprint_item.item as Blueprint
		var recipe = blueprint.recipe as Dictionary
		for item_id in recipe.keys():
			var item = ItemHelper.get_item_by_id(item_id)
			var neededAmount = recipe[item_id]
			var actualAmount = _crafting_inv.count(item_id)
			if actualAmount >= neededAmount:
				new_recipe_text += "[color=#00FF00]"
			else:
				new_recipe_text += "[color=#FF0000]"
			new_recipe_text += str(actualAmount) + "/" + str(neededAmount) + " - " + item.name + "[/color]\n"
	_recipe_text.text = new_recipe_text
	_craft_button.disabled = not _can_craft()
	
func _can_craft():
	if not _blueprint_item:
		return false
	var blueprint = _blueprint_item.item as Blueprint
	var recipe = blueprint.recipe as Dictionary
	for item_id in recipe.keys():
		var item = ItemHelper.get_item_by_id(item_id)
		var neededAmount = recipe[item_id]
		var actualAmount = _crafting_inv.count(item_id)
		if actualAmount < neededAmount:
			return false
	return true

func _on_blueprint_clicked(inventory_item:InventoryItem):
	if !inventory_item:
		return
	_player_inv.add(inventory_item.item.id,inventory_item.amount)
	_blueprint_item = null
	_refresh_item_grids()
	_refresh_craft_output()

func _on_craft_inv_item_clicked(inventory_item:InventoryItem):
	_selected_inventory_item = inventory_item
	if inventory_item.amount == 1:
		_apply_item_move(MOVE.CRAFT_TO_PLAYER, 1)
	else:
		_preselected_move = MOVE.CRAFT_TO_PLAYER
		_show_amount_slider()
	_refresh_item_grids()

func _on_player_inv_item_clicked(inventory_item:InventoryItem):
	if inventory_item.item.type == GameItem.GameItemType.BLUEPRINT:
		if _blueprint_item:
			_player_inv.addItem(_blueprint_item)
		_blueprint_item = InventoryItem.from(inventory_item.item.id, 1)
		_player_inv.remove(inventory_item.item.id, 1)
		_refresh_craft_output()
	else:
		_selected_inventory_item = inventory_item
		if inventory_item.amount == 1:
			_apply_item_move(MOVE.PLAYER_TO_CRAFT, 1)
		else:
			_preselected_move = MOVE.PLAYER_TO_CRAFT
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
		MOVE.PLAYER_TO_CRAFT:
			_player_inv.moveItemSome(_crafting_inv, _selected_inventory_item.item.id, amount)
		MOVE.CRAFT_TO_PLAYER:
			_crafting_inv.moveItemSome(_player_inv, _selected_inventory_item.item.id, amount)
	_refresh_item_grids()
	_selected_inventory_item = null
	_preselected_move = 0
	_refresh_craft_output()
	
func _close_crafting():
	_crafting_inv.moveAllItems(_player_inv)
	if _blueprint_item:
		_player_inv.addItem(_blueprint_item)
	WorldUtil.closeCurrentWindow()

func _craft_():
	if not _can_craft():
		return
	var blueprint = _blueprint_item.item as Blueprint
	var recipe = blueprint.recipe as Dictionary
	for item_id in recipe.keys():
		var neededAmount = recipe[item_id]
		_crafting_inv.remove(item_id, neededAmount)
	_crafting_inv.add(str(blueprint.result_item_id), blueprint.amount)
	_blueprint_item = null
	_refresh_craft_output()
	_refresh_item_grids()
