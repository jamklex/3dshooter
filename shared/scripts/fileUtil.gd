extends Node
class_name FileUtil

static var cache = {} as Dictionary

static func getContentAsString(filePath:String):
	if cache.has(filePath):
		return cache.get(filePath)
	if not FileAccess.file_exists(filePath):
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	cache[filePath] = content
	return content

static func getContentAsJson(filePath:String):
	return JSON.parse_string(getContentAsString(filePath))
