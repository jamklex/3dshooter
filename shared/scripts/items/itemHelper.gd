extends Object

class_name ItemHelper

static func get_item(id: String) -> GameItem:
	var data = FileUtil.getContentAsJson("res://assets/items/items.json")
	var item = GameItem.new()
	if data.has(id):
		item.id = id
		item.name = data.get(id).get("name")
		item.description = data.get("desc")
		if data.has("image"):
			item.image = load(data.get("image"))
	return item
