extends Node
class_name FileUtil

static var cache = {} as Dictionary

static func getContentAsString(filePath:String, cached:bool = true) -> String:
	if cached and cache.has(filePath):
		return cache.get(filePath)
	if not FileAccess.file_exists(filePath):
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	cache[filePath] = content
	return content

static func getContentAsJson(filePath:String, cached:bool = true):
	var strContent = getContentAsString(filePath, cached)
	if strContent.is_empty():
		strContent = "{}"
	return JSON.parse_string(strContent)

static func getFilesAt(folder:String) -> Array[String]:
	if !folder.ends_with("/"):
		folder = folder + "/"
	if cache.has(folder):
		return cache.get(folder)
	var files = [] as Array[String]
	for file in DirAccess.get_files_at(folder):
		file = file.replace(".remap", "")
		files.push_back(folder + file)
	cache[folder] = files
	return files
