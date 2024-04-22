#============================================================
#    Top Down Fall
#============================================================
# - author: zhangxuetu
# - datetime: 2023-08-28 12:16:10
# - version: 4.0
#============================================================
## 自上而下类型游戏节点坠落
class_name TopDownFall
extends Node


## 弹射出去
signal catapulted
## 停落在地面上，不再弹跳
signal falled_on_floor


@export var target : Node2D


var velocity : Vector2 = Vector2()
var origin_pos_y : float = 0
var falling_speed : float = 150


#============================================================
#  内置
#============================================================
func _ready():
	if target == null:
		push_error("没有设置控制的目标节点")
	set_physics_process(false)


func _physics_process(delta):
	if velocity != Vector2.ZERO:
		# 冲刺速度衰减
		velocity.x = lerpf(velocity.x, 0, 0.04)
		# 增加坠落速度
		velocity.y += falling_speed * delta
		# 移动
		target.global_position += velocity * delta
		
		# 落在地上，反弹
		if target.global_position.y > origin_pos_y:
			if velocity.y > 0:
				velocity.y *= -1 * 0.7 # 0.7 为反弹的值
			if abs(velocity.y) <= falling_speed * delta:
				set_physics_process(false)
				self.falled_on_floor.emit()
				return
		
	else:
		set_physics_process(false)
		self.falled_on_floor.emit()


#============================================================
#  自定义
#============================================================
## 获取与地面高度距离
func get_distance_to_floor() -> float:
	return origin_pos_y - target.global_position.y

static func calculate_initial_velocity(
	P0: Vector2, # 起始点
	P1: Vector2, # 目标点
	g: float,  # 重力
	theta: float # 发射弧度
) -> float:
	if P0 == P1:
		return 0
	
	var x = P1.x - P0.x
	var y = P1.y - P0.y
	var v0 = sqrt((g * x * x) / (2 * cos(theta) * cos(theta) * (x * tan(theta) - y)))
	return v0


static func calculate_launch_angle(
	P0: Vector2, 
	P1: Vector2, 
	g: float,  # 重力
	v0: float  # 速度
) -> Dictionary:
	var x = P1.x - P0.x
	var y = P1.y - P0.y
	var v0_squared = v0 * v0
	var under_root = v0_squared * v0_squared - g * (g * x * x + 2 * y * v0_squared)
	
	var result = {"has_solution": false, "theta1": 0.0, "theta2": 0.0}
	
	if under_root >= 0:
		var root = sqrt(under_root)
		var denominator = g * x
		result.theta1 = atan((v0_squared + root) / denominator)
		result.theta2 = atan((v0_squared - root) / denominator)
		result.has_solution = true
	
	return result


func apply_force(v: Vector2):
	assert(is_instance_valid(target), "不是有效的目标节点")
	if not is_inside_tree():
		await ready
	assert(v != Vector2(NAN, NAN))
	origin_pos_y = target.global_position.y
	velocity = v
	set_physics_process(true)
	self.catapulted.emit()


func apply_force_by_angle(p2: Vector2, angle: float):
	var p1 : Vector2 = Vector2(0, 0)
	p2 -= target.global_position
	var g : float = falling_speed
	var speed : float = calculate_initial_velocity(p1, p2, g, angle)
	apply_force(Vector2.LEFT.rotated(angle) * speed)


func apply_force_by_speed(p2: Vector2, speed: float):
	var p1 : Vector2 = target.global_position
	var g : float = falling_speed
	var result = calculate_launch_angle(p1, p2, g, speed)
	if not result.is_empty():
		var angle : float = [result["theta1"], result["theta2"]].pick_random()
		apply_force(Vector2.LEFT.rotated(angle) * speed)

