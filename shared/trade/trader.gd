extends Object

class_name Trader

static func get_taxes(prices: Dictionary) -> Dictionary:
	var tax_value = get_tax_value() as float
	var tax_prices = {}
	for key in prices.keys():
		var value = max(1, prices.get(key) * tax_value)
		tax_prices[key] = value
	return tax_prices

static func get_tax_value() -> float:
	return WorldUtil.player.taxes

static func set_tax_value(value: float):
	var player = WorldUtil.player
	player.taxes = value
	player.save()

static func get_tax_value_percent() -> String:
	return str(get_tax_value() * 100)
