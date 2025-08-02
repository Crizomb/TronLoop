@tool
extends Path3D
class_name RoadPath
@export_tool_button("update_control_points") var action = update_control_points
@export var tilt_scale : float = 0.0005

func modulo_get_point_position(i):
	return curve.get_point_position(posmod(i, curve.point_count))

func update_control_points():
	if curve.point_count < 2:
		return
	
	for i in range(0, curve.point_count):
		var prev = modulo_get_point_position(i) - modulo_get_point_position(i - 1)
		var next = modulo_get_point_position(i + 1) - modulo_get_point_position(i)
		var prev_dir = prev.normalized()
		var next_dir = next.normalized()
		var tangent_length = next.length() / 3 
		var tangent = (prev_dir + next_dir)
		
		tangent.y = 0
		tangent = tangent.normalized()
		curve.set_point_in(i, -tangent * tangent_length)
		curve.set_point_out(i, tangent * tangent_length)
		
		var tilt = -prev.cross(next).y * tilt_scale  
		curve.set_point_tilt(i, tilt)
