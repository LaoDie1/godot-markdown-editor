#============================================================
#    Circle 2D
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-15 14:52:45
# - version: 4.1
#============================================================
@tool
class_name Circle2D
extends Node2D


## 圆形半径
@export_range(0.001,1,0.001,"or_greater","hide_slider") var radius : float = 10.0:
	set(v): radius = v; queue_redraw()
@export_range(-180, 180, 0.001, "degrees") var start_angle : float = -180.0:
	set(v): start_angle = v; queue_redraw()
@export_range(-180, 180, 0.001, "degrees") var end_angle : float = 180.0:
	set(v): end_angle = v; queue_redraw()
## 圆形绘制的点数。这将影响圆形的平滑度
@export_range(3,512,1) var point_count : int = 32
## 抗锯齿
@export var antialiased : bool = false:
	set(v): antialiased = v; queue_redraw()

@export_subgroup("Full", "full_")
## 是否进行填充
@export var full : bool = true:
	set(v): full = v; queue_redraw()
## 填充颜色
@export var full_color : Color = Color.WHITE:
	set(v): full_color = v; queue_redraw()

@export_subgroup("Border","border_")
## 是否有线条
@export var border : bool = true:
	set(v): border = v; queue_redraw()
## 线条宽度
@export var border_width : float = 1.0:
	set(v): border_width = v; queue_redraw()
## 线条颜色
@export var border_color: Color = Color.BLACK:
	set(v): border_color = v; queue_redraw()
## 线条空白间距
@export_range(0, 120) var border_separation : float = 0:
	set(v): border_separation = v; queue_redraw()
## 线条线段长度
@export_range(0, 120) var border_segment_length: float = 0:
	set(v): border_segment_length = v; queue_redraw()
## 虚线条线段点数
@export_range(0, 64, 1) var border_point_count: int = 8:
	set(v): border_point_count = v; queue_redraw()


func _enter_tree():
	queue_redraw()


func _draw():
	if start_angle != end_angle:
		if full:
			if start_angle + end_angle == 0:
				draw_circle(Vector2.ZERO, radius, full_color)
			else:
				var dir : Vector2 = Vector2.RIGHT.rotated(deg_to_rad(start_angle)) * radius
				var offset_angle : float = deg_to_rad((end_angle - start_angle)) / point_count
				
				var points = PackedVector2Array()
				for i in point_count:
					points.append(dir)
					dir = dir.rotated(offset_angle)
				draw_polygon(points, [full_color])
			
		if border:
			if border_separation == 0 or border_segment_length == 0:
				draw_arc(Vector2.ZERO, radius, deg_to_rad(start_angle), deg_to_rad(end_angle), point_count, border_color, border_width, antialiased)
			else:
				var left_or_right = signf(end_angle - start_angle)
				var step = (border_segment_length + border_separation) * left_or_right
				
				for point in range(start_angle, end_angle, step):
					draw_arc(Vector2.ZERO, radius, deg_to_rad(point), deg_to_rad(point + border_segment_length), border_point_count, border_color, border_width, antialiased)
