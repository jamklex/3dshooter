extends VBoxContainer
class_name KillCounter


@onready var header = $header
@onready var entries_holder = $entriesHolder
const entry_template = preload("res://shared/ui/kill_counter/kill_counter_entry.tscn")

func addEntry(name: String, killed_amount: int, total_amount: int): 
	var newEntry = entry_template.instantiate() as KillCounterEntry
	newEntry.setAllInfos(name, killed_amount, total_amount)
	entries_holder.add_child(newEntry)
	header.visible = true

func cleanEntries():
	for node in entries_holder.get_children():
		node.queue_free()
	header.visible = false
