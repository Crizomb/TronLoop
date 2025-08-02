extends Area3D
class_name CheckPoint
@export var check_point_id : int = 0



func _on_body_entered(body: Node3D) -> void:
	if body is not Car:
		return
		
	CheckPointManager.checkPointEnter(check_point_id)
	
	
	
