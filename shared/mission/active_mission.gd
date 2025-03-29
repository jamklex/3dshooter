extends PanelContainer

@onready var label = $ordering/header/label as Label
@onready var expire = $ordering/expire as Label
@onready var teleport_button = $ordering/header/teleport_button as Button
@onready var collect_button = $ordering/header/collect_button as Button
@onready var remove_button = $ordering/header/remove_button as Button
@onready var kills = $ordering/body/kills as VBoxContainer
@onready var resources = $ordering/body/resources as VBoxContainer
@onready var rewards = $ordering/body/rewards as VBoxContainer
@onready var punishments = $ordering/body/punishments as VBoxContainer
var linked_mission: Mission
var kills_holder: Array
var resources_holder: Array
var rewards_holder: Array
var punishment_holder: Array
signal on_teleport

const active_color = Color("#9558224b")
const expired_color = Color("#b5323b4b")
const done_color = Color("#4a76424b")
const colors = [active_color, expired_color, done_color]
var stepUi = preload("res://shared/mission/active_step.tscn")

func _ready():
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate(true))
	set_bg_color(active_color)

func _process(_delta):
	var is_over = linked_mission.isOver()
	collect_button.visible = linked_mission.allDone() && !is_over
	teleport_button.visible = !linked_mission.allDone() && !is_over
	rewards.visible = !is_over
	remove_button.visible = is_over
	punishments.visible = is_over
	label.text = linked_mission._name
	add_entities(kills_holder, kills)
	add_entities(resources_holder, resources)
	add_entities(rewards_holder, rewards)
	add_entities(punishment_holder, punishments)
	if is_over:
		set_bg_color(expired_color)
		expire.set_text("00:00:00")
		remove_button.disabled = not linked_mission.can_pay_punishment()
		return
	else:
		refresh_timer()
	var is_done = linked_mission and linked_mission.allDone()
	var color = done_color if is_done else active_color
	set_bg_color(color)

func clear(_parent: Node):
	for c in _parent.get_children():
		_parent.remove_child(c)

func add_entities(entities: Array, container: VBoxContainer):
	for e in entities:
		if(!e.get_parent()):
			container.add_child(e)


func refresh_timer():
	var now = int(Time.get_unix_time_from_system())
	var time = Time.get_datetime_dict_from_unix_time(linked_mission.over - now)
	var h = str(time.get("hour")).pad_zeros(2)
	var m = str(time.get("minute")).pad_zeros(2)
	var s = str(time.get("second")).pad_zeros(2)
	expire.set_text("%s:%s:%s" % [h,m,s])

func link(mission: Mission):
	linked_mission = mission
	for k in linked_mission.kills:
		add_step(k, kills_holder)
	for r in linked_mission.resources:
		add_step(r, resources_holder)
	for r in linked_mission.rewards:
		var _label = Label.new()
		_label.text = r.item.name + ": " + str(r.amount)
		rewards_holder.push_back(_label)
	for p in linked_mission.getPunishment():
		var _label = Label.new()
		_label.add_theme_color_override("font_color", Color.RED)
		_label.text = p.item.name + ": -" + str(p.amount)
		punishment_holder.push_back(_label)

func add_step(s: MissionStep, _parent: Array):
	var step = stepUi.instantiate()
	step.add_link(s)
	_parent.push_back(step)

func _is_done() -> bool:
	return false

func _on_ship() -> bool:
	return false

func set_bg_color(color: Color):
	get_theme_stylebox("panel").bg_color = color

func _on_remove_button_pressed():
	for punishment in linked_mission.getPunishment():
		var resource_id = punishment.item.id
		var amount = punishment.amount
		WorldUtil.removeFromPlayerInventory([resource_id, amount])
	WorldUtil.remove_mission(linked_mission)
	queue_free()

func _on_collect_button_pressed():
	for resource in linked_mission.resources:
		var resource_id = resource.id
		var amount = resource.total
		WorldUtil.removeFromPlayerInventory([resource_id, amount])
	for reward in linked_mission.rewards:
		var resource_id = reward.item.id
		var amount = reward.amount
		WorldUtil.addToPlayerInventory([resource_id, amount])
	WorldUtil.remove_mission(linked_mission)
	queue_free()

func _on_teleport_button_pressed() -> void:
	on_teleport.emit(linked_mission)
