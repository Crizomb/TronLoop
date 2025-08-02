extends Node


const LEVELS = [preload("res://scenes/levels/level1.tscn")]

var current_level = 0

@export var nb_checkpoints := 3
@export var max_lap := 3

var current_checkpoint := 0
var current_lap := 0

func checkPointEnter(check_point_id):
	if check_point_id != current_checkpoint:
		return
	
	if check_point_id == 0:
		current_lap += 1
		current_checkpoint += 1
	else:
		current_checkpoint += 1 
		current_checkpoint %= nb_checkpoints
	
	if (current_lap == max_lap):
		endTrack()
		return

func endTrack():
	print("end")
	current_lap = 0
	current_checkpoint = 0
