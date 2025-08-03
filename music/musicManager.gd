extends AudioStreamPlayer

const MENU_MUSIC = preload("res://music/508004__rokzroom__otherworlds-2.wav")

const LEVEL_MUSICS = [
	preload("res://music/cool-retro-synthwave-type-beat-into-the-future-213802.mp3"),
	preload("res://music/retro-synthwave-background-soundtrack-341853.mp3"), 
	preload("res://music/dark-synthwave-neon-nights-251682.mp3")
	]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func launch_level_music(num_lvl):
	stream = LEVEL_MUSICS[num_lvl]
	bus = "Music"
	play()
	
func launch_menu_music():
	stream = MENU_MUSIC
	bus = "Music"
	play()
