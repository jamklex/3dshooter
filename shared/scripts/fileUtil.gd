extends Node
class_name FileUtil

static var cache = {} as Dictionary

static func getContentAsString(filePath:String, cached:bool = true) -> String:
	if cached and FileUtil.cache.has(filePath):
		return FileUtil.cache.get(filePath)
	if not FileAccess.file_exists(filePath):
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	FileUtil.cache[filePath] = content
	return content

static func getContentAsJson(filePath:String, cached:bool = true, defaultContent:String = "{}"):
	var strContent = getContentAsString(filePath, cached)
	if strContent.is_empty():
		strContent = defaultContent
	return JSON.parse_string(strContent)
	
static func saveJsonContent(filePath:String, json:Variant):
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(json, "\t"))
	FileUtil.cache[filePath] = JSON.stringify(json)

static func getFilesAt(folder:String, withFolders: bool = false) -> Array[String]:
	if !folder.ends_with("/"):
		folder = folder + "/"
	if FileUtil.cache.has(folder):
		return FileUtil.cache.get(folder)
	var files = [] as Array[String]
	var _files = DirAccess.get_files_at(folder)
	if withFolders:
		_files.append_array(DirAccess.get_directories_at(folder))
	for file in _files:
		file = file.replace(".remap", "")
		files.push_back(folder + file)
	FileUtil.cache[folder] = files
	return files
