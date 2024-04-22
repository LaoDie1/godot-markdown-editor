#============================================================
#    Lighting
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-10 19:51:35
# - version: 4.x
#============================================================
## 闪电
class_name Lighting
extends Line2D


const CURVE = preload("curve.tres")


## 闪电播放速度
@export var speed : float = 0.003
## 最小 x 位置
@export var x_min : float = -3
## 最大 x 位置
@export var x_max : float = 3
## 最小 y 间距
@export var distance_min : float = 5
## 最大 y 间距
@export var distance_max : float = 10 


func _enter_tree():
	if self.width_curve == null:
		self.width_curve = CURVE


##  播放闪电
func play(length: float, hide_time: float = 0.25) -> void:
	self.points.clear()
	
	var list : PackedVector2Array = PackedVector2Array()
	# 初始点居中
	list.append(Vector2((x_min + x_max)/2, 0))
	
	var y : float = 0
	while true:
		var dir : int = [-1, 1].pick_random()
		var x : float = randf_range(x_min, x_max)
		y += randf_range(distance_min, distance_max)
		if y < length:
			list.append(Vector2(x, y))
			self.points = list
		else:
			var last = list[list.size() - 1]
			list[list.size() - 1].x = last.x / 2.0
			list.append(Vector2(0, length))
			
			self.points = list
			break
		
		if speed > 0.001:
			if speed <= 0.005 and randf() <= speed * 200:
				continue
			await get_tree().create_timer(speed).timeout
	
	if hide_time > 0:
		get_tree().create_timer(hide_time).timeout.connect( func():
			create_tween().tween_property(self, "modulate:a", 0, 0.25)
		)
	

