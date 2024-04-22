#============================================================
#    Sprint
#============================================================
# - datetime: 2023-02-13 12:50:11
#============================================================
extends Node2D


signal moved(vector: Vector2)


## 衰减速度
@export_range(0, 1, 0.001, "or_greater")
var attenuation : float = 0.0


var _velocity: Vector2 = Vector2(0,0)



func _ready():
	if _velocity:
		start(_velocity)


func _physics_process(delta):
	if _velocity != Vector2.ZERO:
		_velocity = lerp( _velocity, Vector2.ZERO, attenuation * delta)
		self.moved.emit(_velocity)
	else:
		set_physics_process(false)


func start(vector: Vector2):
	_velocity = vector
	set_physics_process(true)

