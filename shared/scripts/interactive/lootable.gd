class_name Lootable

extends CSGBox3D
var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var highlight_seconds = 1.0 as float
@export var interact_distance_m = -1
@export_file("*.json") var drop_table_file = "res://data/drop_tables/default_droptable.json"
@onready var drop_table = JSON.parse_string(FileAccess.open(drop_table_file, FileAccess.READ).get_as_text()) as Dictionary
const POPUP_MESSAGE_FORMAT = "Open Container"
@export_placeholder(POPUP_MESSAGE_FORMAT) var default_popup_message: String
const FEEDBACK_MESSAGE_FORMAT = "Collected: <ITEM>"
@export_placeholder(FEEDBACK_MESSAGE_FORMAT) var default_feedback_messages: String

func _ready():
	material = material.duplicate(true) # individual material
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	var loot = get_random_item() as DropItem
	InteractionHelper.add_drop(player, loot)
	if await open_animation():
		interactable = false
		remove_highlight()
		highlightTimer.stop()
	var message = default_feedback_messages
	if !message:
		var loot_feedback = loot.pretty_name()
		var amount = loot.get_amount()
		if amount > 1:
			loot_feedback += " x" + str(amount)
		message = FEEDBACK_MESSAGE_FORMAT.replace("<ITEM>", loot_feedback)
	return message

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
	var _total_chance = total_chance(drop_items)
	var rng = randf_range(0, _total_chance)
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
	var _total_chance = 0
	for item in items:
		_total_chance += item.chance
	return _total_chance

func popup_message():
	var message = default_popup_message
	if !message:
		message = POPUP_MESSAGE_FORMAT
	return InteractionHelper.popup_message(message)
