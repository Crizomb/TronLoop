extends Node

@export var nb_checkpoints := 3
@export var max_lap := 3

signal new_lap(value)
signal end_track

var current_checkpoint := 0
var current_lap := 0

func checkPointEnter(check_point_id):
	if check_point_id != current_checkpoint:
		return
	
	if check_point_id == 0:
		current_lap += 1
		current_checkpoint += 1
		new_lap.emit(current_lap)
	else:
		current_checkpoint += 1 
		current_checkpoint %= nb_checkpoints
	
	if (current_lap == max_lap+1):
		endTrack()

func endTrack():
	print("end")
	current_lap = 0
	current_checkpoint = 0
	end_track.emit()
