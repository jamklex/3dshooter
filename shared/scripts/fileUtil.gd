extends Node
class_name FileUtil


static func getContentAsString(filePath:String):
	if not FileAccess.file_exists(filePath):
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	return file.get_as_text()
	
static func getContentAsJson(filePath:String):
	return JSON.parse_string(getContentAsString(filePath))
