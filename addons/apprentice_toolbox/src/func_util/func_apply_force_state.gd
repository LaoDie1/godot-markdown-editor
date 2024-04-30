#============================================================
#    Func Apply Force State
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-19 16:27:17
# - version: 4.0
#============================================================
class_name FuncApplyForceState


## 当前移动速度。手动修改这个值并不会有效果
var speed : float = 0.0 : set=set_speed
## 当前移动向量
var _velocity : Vector2 = Vector2(0,0)
## 当前衰减速度
var attenuation : float = 0.0
## 是否结束
var finish : bool = false


func set_speed(v: float):
	speed = v
	_velocity = _velocity.limit_length(v)


func get_speed() -> float:
	return speed


func get_velocity() -> Vector2:
	return _velocity


func update_velocity(v: Vector2):
	_velocity = v

