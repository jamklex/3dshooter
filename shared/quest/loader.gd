extends Object

class_name QuestLoader

static var quest_matcher: Dictionary = {}

static func load_quest(path: String, unlocked: bool) -> Quest:
	if !path.ends_with("/"):
		path = path + "/"
	var tasks = []
	for file_name in FileUtil.getFilesAt(path):
		tasks.push_back(FileUtil.getContentAsJson(file_name))
	return Quest.from(tasks, unlocked)

static func load_quests(path: String) -> Array:
	if !path.ends_with("/"):
		path = path + "/"
	var quests = []
	for dir in DirAccess.get_directories_at(path):
		var quest = load_quest(path + dir, dir == "tutorial")
		quests.push_back(quest)
		quest_matcher[dir] = quest.title
	return quests

static func show_quests(questlog: VBoxContainer, quests: Array):
	for quest in quests:
		if !quest:
			continue
		questlog.add_child(quest)
		quest.refresh_data()

static func get_quest(name: String) -> Quest:
	var _quests = WorldUtil.get_quests()
	for _q in _quests:
		if quest_matcher.get(name, name) == _q.title:
			return _q
	return null

static func get_active_quests() -> Array:
	return WorldUtil.get_quests().filter(func(q): q.status == Quest.Status.ACTIVE)
