extends Node
class_name SoundUtil

const SOUNDS_PATH: String = "res://assets/sounds/"
const MP3_EXT = ".mp3"

enum SoundName {
	ENEMY_ATTACK,
	PLAYER_DAMAGE,
	PLAYER_STEP,
	AMBIENT_HOME,
	AMBIENT_MISSION,
	ENEMY_AGGRESSIVE,
	ENEMY_IDLE,
	ENEMY_DEAD,
	LOOT_PICKUP,
	PLAYER_DEAD,
	ROUND_START,
	SPAWN_PING
}

static func getSound(name: SoundName) -> AudioStreamMP3:
	var soundLocation = SOUNDS_PATH + SoundName.keys()[name].to_lower().replace("_", "-")
	for file in FileUtil.getFilesAt(SOUNDS_PATH, true):
		if !file.begins_with(soundLocation):
			continue
		if file == soundLocation:
			return read_sound(FileUtil.getFilesAt(file).filter(func(f: String): return f.ends_with(MP3_EXT)).pick_random())
		if file.ends_with(MP3_EXT):
			return read_sound(file)
	return null

static func read_sound(path: String):
	print("using: " + path)
	return AudioStreamMP3.load_from_file(path)
