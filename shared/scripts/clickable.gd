class_name Clickable

extends CSGBox3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var enable_highlight = true
@export var disable_on_interact = false
@export var action: Clickable.Actions
@export var highlight_seconds = 0.1 as float
@export var interact_distance_m = 2.0
var highlighted = false

enum Actions {
	PRINT_ON,
	PRINT_OFF,
	TELEPORT_TO_BASE,
	AIR_VENT
}

func _ready():
	material = material.duplicate(true) # individual material
	if enable_highlight:
		highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
		highlightTimer.one_shot = true
		add_child(highlightTimer)

func set_interactable(value: bool):
	interactable = value

func can_interact():
	return interactable

func interact(player: Player):
	execute_action(action)
	await click_animation()
	if(disable_on_interact):
		set_interactable(false)
		remove_highlight()

func highlight():
	if !enable_highlight:
		return
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	material.emission_enabled = true
	material.emission = material.albedo_color

func remove_highlight():
	highlighted = false
	material.emission_enabled = false

func click_animation():
	print("TODO: click animation")
	return true

func execute_action(action: Clickable.Actions):
	var player = WorldUtil.player as Player
	match (action):
		Actions.PRINT_ON:
			print("on")
		Actions.PRINT_OFF:
			print("off")
		Actions.TELEPORT_TO_BASE:
			player.saveRunInventory()
			WorldUtil.teleportToLowerShip()
		Actions.AIR_VENT:
			initiate_airvent()
		_:
			print("action " + str(action) + " is not implemented")

func initiate_airvent():
	var player = get_player()
	add_child(Trade.new_instance(player.run_inventory, {}, exit_airvent))
	player.body.setInDialog(true)

func exit_airvent(action: Trade.TradeActions, params: Array = []):
	var player = get_player()
	match (action):
		Trade.TradeActions.SAVE_TRADE:
			player.run_inventory = params[0]
			player.move_all(params[1], player.store_inventory)
			player.body.setInDialog(false)
			player.body.refresh_inventory_output()
		Trade.TradeActions.CANCEL_PRESSED:
			set_interactable(true)
			player.body.setInDialog(false)
		_:
			return false
	return true

func get_player() -> Player:
	return WorldUtil.player
