extends Node

var quest_matcher: Dictionary = {}
static var quests: Array = []
const _savePath: String = "user://quests.json"

func load_quest(path: String, save_state: Dictionary) -> Quest:
	var tasks = []
	for file_name in FileUtil.getFilesAt(path):
		tasks.push_back(FileUtil.getContentAsJson(file_name))
	return Quest.from(path, tasks, save_state)

func load_quests(path: String) -> Array:
	if !path.ends_with("/"):
		path = path + "/"
	var _quests = []
	var _saves = save_state()
	for dir in DirAccess.get_directories_at(path):
		var quest_path = path + dir
		if !quest_path.ends_with("/"):
			quest_path = quest_path + "/"
		var quest = load_quest(quest_path, _saves.get(quest_path, {}))
		_quests.push_back(quest)
		quest_matcher[dir] = quest.title
	return _quests

func attach_quests(questlog: VBoxContainer):
	for quest in get_quests():
		if !quest:
			continue
		questlog.add_child(quest)
		quest.refresh_data()

func get_quest(name: String) -> Quest:
	var _quests = get_quests()
	for _q in _quests:
		if quest_matcher.get(name, name) == _q.title:
			return _q
	return null

func get_quests() -> Array:
	quests = quests.filter(func(o): return is_instance_valid(o))
	if quests.is_empty():
		reload_quests()
	return quests

func reload_quests():
	quests = load_quests("res://data/quests")

func get_active_quests() -> Array:
	return get_quests().filter(func(q): q.status == Quest.Status.ACTIVE)

func save_progress(_quest: Quest):
	var content = save_state()
	content[_quest.path] = _quest.save_dict()
	var file = FileAccess.open(_savePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(content, "\t"))

func save_state() -> Dictionary:
	var json = FileUtil.getContentAsJson(_savePath, false)
	return json if json else {}
