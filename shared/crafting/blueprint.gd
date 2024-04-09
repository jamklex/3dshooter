extends GameItem
class_name Blueprint

var recipe: Dictionary
var result_item_id: int
var amount: int

static func fromGameItem(gameItem:GameItem):
	var blueprint = Blueprint.new()
	blueprint.id = gameItem.id
	blueprint.name = gameItem.name
	blueprint.description = gameItem.description
	blueprint.image = gameItem.image
	blueprint.tradeable = gameItem.tradeable
	blueprint.type = gameItem.type
	return blueprint
