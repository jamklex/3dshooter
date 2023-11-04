extends Object

class_name Shop

static func create_shop_inventory(item_ids: Array) -> Inventory:
	var inv = Inventory.empty()
	for item_id in item_ids:
		inv.set_total(item_id, 999)
	return inv
