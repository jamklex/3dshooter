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
	cache[id] = item
	return item
