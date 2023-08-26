class_name Lootable

extends CSGBox3D
var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var highlight_seconds = 1.0 as float
@export var interact_distance_m = 2.0 as float
@export_file("*.json") var drop_table_file = "res://assets/drop_tables/default_droptable.json"
@onready var drop_table = JSON.parse_string(FileAccess.open(drop_table_file, FileAccess.READ).get_as_text()) as Dictionary

func _ready():
	material = material.duplicate(true) # individual material
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	InteractionHelper.add_drop(player, get_random_item())
	if await open_animation():
		interactable = false
		remove_highlight()
		highlightTimer.stop()

func highlight():
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	material.emission_enabled = true
	material.emission = material.albedo_color

func remove_highlight():
	highlighted = false
	material.emission_enabled = false

func open_animation():
	print("TODO: opening animation")
	return true

func get_random_item():
	var drop_items = get_drop_items()
	var total_chance = total_chance(drop_items)
	var rng = randf_range(0, total_chance)
	var current_chance = 0
	for item in drop_items:
		current_chance += item.chance
		if rng <= current_chance:
			return item

func get_drop_items():
	var items = []
	for item in drop_table.get("items", []):
		items.append(DropItem.get_from(item))
	return items

func total_chance(items: Array):
	var total_chance = 0
	for item in items:
		total_chance += item.chance
	return total_chance
