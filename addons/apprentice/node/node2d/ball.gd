#============================================================
#    Ball
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-16 00:04:36
# - version: 4.0
#============================================================
## 球
##
##可以反弹，像 [RigidBody] 类似，但是是简单的小球功能而已
class_name Ball
extends CharacterBody2D


## 最大重力坠落速度
@export var max_gravity_speed : float = 350
## 重量。影响到坠落速度
@export_range(0, 1, 0.001, "hide_slider", "or_greater") var weight : float = 0.5
## 弹性。反弹时速度衰减
@export var elasticity : float = 0.45
## 阻力。影响到移动速度
@export var resistance : float = 0.5


var last_velocity : Vector2


func _physics_process(delta):
	velocity.y = lerp(velocity.y, max_gravity_speed, weight * delta)
	last_velocity = velocity
	if move_and_slide():
		var normal = get_last_slide_collision().get_normal()
		velocity = last_velocity.bounce(normal) * elasticity
	
	velocity.x = lerp(velocity.x, 0.0, resistance * delta)


