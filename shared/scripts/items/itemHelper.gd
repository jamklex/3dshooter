extends Object

class_name ItemHelper

static var cache = [] as Array[GameItem]

static func get_items() -> Array[GameItem]:
	if !cache:
		var json_data = FileUtil.getContentAsJson("res://data/items/items.json") as Dictionary
		for id in json_data.keys():
			var item = GameItem.new()
			var item_data: Dictionary = json_data.get(id)
			item.id = id
			item.name = item_data.get("name")
			item.description = item_data.get("desc")
			if item_data.has("image"):
				item.image = load(item_data.get("image"))
			item.tradeable = item_data.get("trade", true)
			if item_data.has("type"):
				item.type = GameItem.GameItemType.get(item_data.get("type"))
				item = init_item_type(item, item_data)
			cache.append(item)
	return cache

static func get_item_by_id(id: String) -> GameItem:
	return get_items().filter(func(item: GameItem): return item.id == id)[0]

static func get_item_by_rarity(rarities: Array[GameItem.Rarity]) -> Array[GameItem]:
	return get_items().filter(func(item: GameItem): return rarities.has(item.rarity))

static func init_item_type(item:GameItem, item_data:Dictionary):
	if item.type == GameItem.GameItemType.BLUEPRINT:
		if item_data.has("recipe") and item_data.has("result_item_id") and item_data.has("amount"):
			var blueprint = Blueprint.fromGameItem(item)
			blueprint.recipe = item_data.get("recipe")
			blueprint.result_item_id = item_data.get("result_item_id")
			blueprint.amount = item_data.get("amount")
			return blueprint
		else:
			push_error("Created broken blueprint item!")
	if item.type == GameItem.GameItemType.RESOURCE:
		if item_data.has("rarity"):
			item.rarity = GameItem.Rarity.get(item_data.get("rarity"))
	return item
