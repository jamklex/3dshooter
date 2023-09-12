extends Node
class_name FileUtil

static var cache = {} as Dictionary

static func getContentAsString(filePath:String):
	if not FileAccess.file_exists(filePath):
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	return file.get_as_text()

static func getContentAsJson(filePath:String):
	if(!cache.has(filePath)):
		cache[filePath] = JSON.parse_string(getContentAsString(filePath))
	return cache.get(filePath)
