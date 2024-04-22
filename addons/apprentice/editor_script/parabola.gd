#============================================================
#    Parabola
#============================================================
# - datetime: 2023-02-26 15:11:28
#============================================================
## 抛物线。抛物线效果显示
@tool
class_name Parabola
extends EditorScript


# 重力加速度
var g : float = 9.8
# 轨迹绘制点
var points : Array[Vector2] = []


func _run():
	
	var points = execute( Vector2(-5, 9), Vector2(0, 0), 20 )
	
	# 显示
	var root = EditorUtil.get_edited_scene_root()
	var line = root.get_node("Line2D") as Line2D
	line.points = points
	
	print( Time.get_datetime_string_from_system(), "   ", points )
	


##  execute
##[br]
##[br][code]mouse_pos[/code]  鼠标拖拽位置，离中心的小球越远施加的力越大
##[br][code]start_pos[/code]  目标起始位置
##[br][code]point_num[/code]  获取的点生成的点数量
func execute(mouse_pos, start_pos, point_num: int) -> Array[Vector2]:
	# 设置离地高度
	var height = start_pos.y
	
	# 最大力
	var max_force : float = 500.0
	# 限制最大长度
	if MathUtil.distance_to(start_pos, mouse_pos) > max_force:
		mouse_pos = start_pos + (mouse_pos - start_pos).normalized() * max_force
	
	# 力度
	var release_force : float = 10.0
	# 施加的力
	var release_velocity = (start_pos - mouse_pos) * release_force
	
	# 落地最大水平位移
	var S = release_velocity.x * (release_velocity.y / g
		+ sqrt((pow(release_velocity.y, 2) / g / g) + 2 * height / g )
	)
	
	# 轨迹点间隔
	var x_unit = float(S / point_num)
	points.append(start_pos)
	
	for i in range(1, 20):
		var pos = Vector2()
		pos.x = start_pos.x
		pos.y = get_path_y(start_pos, release_velocity)
		points.append(pos)
		
		# 重力作用
		release_velocity += Vector2(0, g)
		start_pos.x += i * x_unit
		start_pos = pos + release_velocity
	
	return points


func get_path_y(current_pos: Vector2, current_velocity: Vector2) -> float:
	var y = (current_velocity.y / current_velocity.x) * (current_pos.x - current_pos.x) \
		- ( g * pow(current_pos.x - current_pos.x, 2)) / ( 2 * pow(current_velocity.x, 2) ) \
		+ current_pos.y
	return y
	
