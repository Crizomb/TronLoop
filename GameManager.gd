extends Node

const MAIN_MENU = preload("res://scenes/Menu.tscn")
const LEVELS = [preload("res://scenes/levels/level1.tscn"), preload("res://scenes/levels/level2.tscn"), preload("res://scenes/levels/level3.tscn")]

func launch_level(num_lvl):
	get_tree().paused = false
	MusicManager.launch_level_music(num_lvl)
	get_tree().change_scene_to_packed(LEVELS[num_lvl])

func launch_menu():
	get_tree().paused = false
	MusicManager.launch_menu_music()
	get_tree().change_scene_to_packed(MAIN_MENU)
