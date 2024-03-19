extends Object

class_name ItemHelper

static var cache = {} as Dictionary

static func get_item(id: String) -> GameItem:
	if cache.has(id):
		return cache[id]
	var json_data = FileUtil.getContentAsJson("res://data/items/items.json")
	var item = GameItem.new()
	if json_data.has(id):
		var item_data = json_data.get(id)
		item.id = id
		item.name = item_data.get("name")
		item.description = item_data.get("desc")
		if item_data.has("image"):
			item.image = load(item_data.get("image"))
		item.tradeable = item_data.get("trade", true)
		if item_data.has("type"):
			item.type = GameItem.GameItemType.get(item_data.get("type", null))
			init_subclass_item(item, item_data)
	cache[id] = item
	return item

static func init_subclass_item(item:GameItem, item_data:Dictionary):
	if item.type == GameItem.GameItemType.BLUEPRINT:
		if item_data.has("recipe") and item_data.has("result_item_id") and item_data.has("amount"):
			item = item as Blueprint
			item.recipe = item_data.get("recipe")
			item.result_item_id = item_data.get("result_item_id")
			item.amount = item_data.get("amount")
		else:
			push_error("Created broken blueprint item!")
		
