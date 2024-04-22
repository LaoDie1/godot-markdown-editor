#============================================================
#    Surround
#============================================================
# - datetime: 2022-09-12 12:30:26
#============================================================
##  节点环绕
class_name Surround
extends Node2D


@export var speed : float = 100.0
## 围绕这个节点旋转
@export var a : Node2D:
	set(v):
		a = v 
		_update_data.call_deferred()
## 这个节点进行旋转
@export var b : Node2D:
	set(v):
		b = v
		_update_data.call_deferred()
@export var distance : float = 0.0


var deg : float = 0.0
var w : float = 0.0


func _ready() -> void:
	set_process(false)
	_update_data.call_deferred()


func _update_data():
	if a and b:
		#distance = b.position.distance_to(self.to_local(a.global_position))
		w = speed / distance
		set_process(true)
	else:
		set_process(false)


func _process(delta: float) -> void:
	deg -= w * delta
	b.position = polar_to_cartesian(distance, deg)
	b.position += self.to_local(a.global_position)


## 极坐标到笛卡尔坐标
func polar_to_cartesian(r:float, th: float) -> Vector2:
	return Vector2(r * cos(th), r * sin(th))


