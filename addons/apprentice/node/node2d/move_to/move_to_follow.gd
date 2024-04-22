#============================================================
#    Move To Follow
#============================================================
# - datetime: 2022-09-12 12:49:28
#============================================================
##  移动到跟随者的位置
class_name MoveToFollow
extends Node2D


@export var to : CanvasItem
@export var speed : float = 100.0
@export var update_time : float = 1.0 : 
	set(v):
		update_time = v
		_timer.wait_time = update_time
@export var arrive_distance : float = 10.0 :
	set(v):
		arrive_distance = v
		_move_to.arrive_distance = arrive_distance


@onready var _delta = 1.0 / float(Engine.physics_ticks_per_second)


var _timer := Timer.new()
var _move_to := MoveToPoint.new()


func _init() -> void:
	_timer.wait_time = update_time
	_timer.autostart = true
	_timer.one_shot = false
	_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_timer.timeout.connect(func():
		if self.to:
			self._move_to.to(self.to.global_position)
	)
	
	_move_to.arrive_distance = arrive_distance
	_move_to.moved.connect(_move_to_target)
	
	add_child(_timer)
	add_child(_move_to)


func _ready() -> void:
	_timer.timeout.emit()
	_timer.start()


func _move_to_target(direction: Vector2):
	global_position = global_position.move_toward(global_position + direction * speed,  speed * _delta)

