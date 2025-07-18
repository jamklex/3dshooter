@tool
class_name Interactable

extends CSGBox3D

var highlightTimer = Timer.new()
var pingTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var enable_highlight = true
@export var disable_on_interact = false
@export var action: Interactable.Actions
@export var highlight_seconds = 0.1 as float
@export var interact_distance_m = -1
const POPUP_MESSAGE_FORMAT = "Take Action"
@export_placeholder(POPUP_MESSAGE_FORMAT) var default_popup_message: String
const FEEDBACK_MESSAGE_FORMAT = ""
@export_placeholder(FEEDBACK_MESSAGE_FORMAT) var default_feedback_messages: String
var highlighted = false
var audioPlayer: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

enum Actions {
	PRINT_ON,
	PRINT_OFF,
	TELEPORT_TO_BASE,
	AIR_VENT,
	CRAFTING
}

func _ready():
	add_child(audioPlayer)
	audioPlayer.bus = "Sound"
	if action == Actions.TELEPORT_TO_BASE:
		add_child(pingTimer)
		pingTimer.start(4.2)
		audioPlayer.set_max_distance(50)
		pingTimer.timeout.connect(play_ping)
	if material:
		material = material.duplicate(true)
	if enable_highlight:
		highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
		highlightTimer.one_shot = true
		add_child(highlightTimer)

func play_ping():
	audioPlayer.set_max_db(-20)
	SoundUtil.playAtConstantPitch(audioPlayer, SoundUtil.SoundName.SPAWN_PING)

func set_interactable(value: bool):
	interactable = value

func can_interact():
	return interactable

func interact(_player: Player):
	execute_action(action)
	await click_animation()
	if disable_on_interact:
		set_interactable(false)
		remove_highlight()
	var message = default_feedback_messages
	if !message:
		message = FEEDBACK_MESSAGE_FORMAT
	return message

func highlight():
	if !enable_highlight:
		return
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	material.emission_enabled = true
	material.emission = material.albedo_color

func remove_highlight():
	if !enable_highlight:
		return
	highlighted = false
	material.emission_enabled = false

func click_animation():
	# TODO: click animation
	return true

func execute_action(_action: Interactable.Actions):
	var player = WorldUtil.player as Player
	match (_action):
		Actions.TELEPORT_TO_BASE:
			WorldUtil.teleportToLowerShip()
		Actions.AIR_VENT:
			initiate_airvent()
		Actions.CRAFTING:
			WorldUtil.openCrafting()
		_:
			print("action " + str(_action) + " is not implemented")

func initiate_airvent():
	var player = get_player()
	WorldUtil.setCurrentWindow(Trade.new_instance(player.inventory, Inventory.empty(), exit_airvent))

func exit_airvent(_action: Trade.Actions, params: Array = []):
	var player = get_player()
	match (_action):
		Trade.Actions.SAVE_TRADE:
			player.inventory = params[0]
			var airlock_inv = params[1] as Inventory
			if airlock_inv.is_empty():
				set_interactable(true)
			airlock_inv.moveAllItems(player.salvager)
			WorldUtil.closeCurrentWindow()
			player.body.refresh_inventory_output()
		Trade.Actions.CANCEL_PRESSED:
			if disable_on_interact:
				set_interactable(true)
			WorldUtil.closeCurrentWindow()
		_:
			return false
	return true

func get_player() -> Player:
	return WorldUtil.player

func popup_message():
	var message = default_popup_message
	if !message:
		message = POPUP_MESSAGE_FORMAT
	return InteractionHelper.popup_message(message)
