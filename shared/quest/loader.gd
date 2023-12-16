extends Node

var quest_matcher: Dictionary = {}
static var quests: Array[Quest] = []
static var menu_quests: Array[Quest] = []
const _savePath: String = "user://quests.json"
const scene_root: String = "res://shared/quest/scenes/"

func _process(_delta):
	highlight_quest_npcs(quests)

func highlight_quest_npcs(_quests: Array[Quest]):
	var quest_npcs:Array[String] = []
	var all_npcs = get_tree().get_nodes_in_group("npc").filter(func(n): return n is NPC)
	for q in _quests:
		var active_tasks = q.get_active_tasks()
		if active_tasks.is_empty():
			continue
		for _t in active_tasks:
			var active_dialog = _t.dialog
			if active_dialog != null:
				quest_npcs.push_back(active_dialog.npc)
	for n in all_npcs:
		if quest_npcs.has(n.get("npc_id")):
			n.show_quest_marker()
		else:
			n.hide_quest_marker()

func load_quest(path: String, state: Dictionary, _scene_root = scene_root) -> Quest:
	var tasks = []
	for file_name in FileUtil.getFilesAt(path):
		tasks.push_back(FileUtil.getContentAsJson(file_name))
	return await Quest.from(path, tasks, state)

func load_quests(path: String, _scene_root = scene_root) -> Array:
	if !path.ends_with("/"):
		path = path + "/"
	var _quests: Array[Quest] = []
	var _saves = save_state()
	for dir in DirAccess.get_directories_at(path):
		var quest_path = path + dir
		if !quest_path.ends_with("/"):
			quest_path = quest_path + "/"
		var quest = await load_quest(quest_path, _saves.get(quest_path, {}), _scene_root)
		_quests.push_back(quest)
		quest_matcher[dir] = quest.title
	return _quests

func attach_quests(questlog: VBoxContainer):
	for quest in get_quests():
		if !quest:
			continue
		questlog.add_child(quest)
		quest.refresh_data()

func attach_tasks(tasklog: VBoxContainer, quest: Quest):
	for task in quest.get_active_tasks():
		if !task:
			continue
		tasklog.add_child(task)
		task.refresh_data()

func get_quest(_name: String) -> Quest:
	var _quests = get_quests()
	for _q in _quests:
		if quest_matcher.get(_name, _name) == _q.title:
			return _q
	return null

func get_quests() -> Array:
	quests = quests.filter(func(o): return is_instance_valid(o))
	if quests.is_empty():
		reload_quests()
	return quests

func reload_quests():
	quests = await load_quests("res://data/quests")
	menu_quests = await load_quests("res://data/quests", "res://shared/ui/menu/quests/")

func save_progress(_quest: Quest):
	var content = save_state()
	content[_quest.path] = _quest.save_dict()
	var file = FileAccess.open(_savePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(content, "\t"))

func save_state() -> Dictionary:
	var json = FileUtil.getContentAsJson(_savePath, false)
	return json if json else {}
