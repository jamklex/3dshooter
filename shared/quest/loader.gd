extends Object

class_name QuestLoader

static func load_quest(path: String) -> Quest:
	if !path.ends_with("/"):
		path = path + "/"
	var tasks = []
	for file_name in FileUtil.getFilesAt(path):
		tasks.push_back(FileUtil.getContentAsJson(file_name))
	return Quest.from(tasks)

static func load_quests(path: String) -> Array:
	if !path.ends_with("/"):
		path = path + "/"
	var quests = []
	for dir in DirAccess.get_directories_at(path):
		quests.push_back(load_quest(path + dir))
	return quests
