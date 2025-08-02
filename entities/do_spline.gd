@tool
extends Path3D
class_name RoadPath
@export_tool_button("update_control_points") var action = update_control_points

func update_control_points():
	if curve.point_count < 2:
		return
	
	
	# Start point: out control based on next point
	var dir = (curve.get_point_position(1) - curve.get_point_position(0)).normalized()
	var tangent_length = dir.length() / 3 
	
	curve.set_point_out(0, dir * tangent_length)
	
	# Intermediate points: in and out controls based on adjacent points
	for i in range(1, curve.point_count - 1):
		var prev_dir = (curve.get_point_position(i) - curve.get_point_position(i - 1)).normalized()
		var next_dir = (curve.get_point_position(i + 1) - curve.get_point_position(i)).normalized()
		tangent_length = next_dir.length() / 3 
		var tangent = (prev_dir + next_dir)
		tangent.y = 0
		tangent = tangent.normalized()
		curve.set_point_in(i, -tangent * tangent_length)
		curve.set_point_out(i, tangent * tangent_length)
