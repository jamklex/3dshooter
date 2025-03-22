extends Node
class_name SoundUtil

const SOUNDS_PATH: String = "res://assets/sounds/"
const MP3_EXT = ".mp3"
const IMPORT_FILE_EXT = ".import"

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
			return ResourceLoader.load(FileUtil.getFilesAt(file).filter(func(f: String): return f.ends_with(IMPORT_FILE_EXT)).pick_random().replace(IMPORT_FILE_EXT,""))
		if file.ends_with(IMPORT_FILE_EXT):
			return ResourceLoader.load(file.replace(IMPORT_FILE_EXT,""))
	return null

static func read_sound(path: String):
	return AudioStreamMP3.load_from_file(path)

static func playAtConstantPitch(player: AudioStreamPlayer3D, name: SoundName, pitch: float = 1.0):
	var old_pitch = player.get_pitch_scale()
	player.set_stream(getSound(name))
	player.set_pitch_scale(pitch)
	player.play()
	player.set_pitch_scale(old_pitch)

static func playAtRandomPitch(player: AudioStreamPlayer3D, name: SoundName):
	playAtConstantPitch(player, name, randomPitch())

static func randomPitch() -> float:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100)
	
