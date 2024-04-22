#============================================================
#	Move Controller
#============================================================
# @datetime: 2022-5-18 20:44:32
#============================================================
## 移动控制器
##
## 连接 moved 信号实现控制方式，然后通过调用 move 开头的方法进行移动。
class_name MoveController
extends Node2D


## 移动状态发生改变
signal move_state_changed(state: bool)
## 方向发生改变
signal direction_changed(direction: Vector2)
## 已移动
signal moved(vector: Vector2)


@export var enabled : bool = true:
	set(v):
		enabled = v
		if not is_inside_tree():
			await ready
		set_physics_process(enabled)
		_moving = false
		
## 移动速度
@export var move_speed : float = 100.0
## 加速度。只在调用 [method move_direction] 方法时执行加速度，最大速度为 [member move_speed]
@export_range(0.0, 60.0, 0.001, "or_greater")
var acceleration : float = 60.0
## 摩擦力。速度会根据摩擦力慢慢减慢，如果为0，则没有摩擦力，会一直向前滑行移动。
@export_range(0.0, 60.0, 0.001, "or_greater") 
var friction : float = 60.0


## 当前移动的移动向量
var motion_velocity := Vector2(0,0) :
	set(v):
		motion_velocity = v


# 实时移动速度
var _move_speed := 0.0
# 是否正在移动
var _moving := false :
	set(value):
		if _moving != value:
			_moving = value
			self.move_state_changed.emit(_moving)

var _current_direction := Vector2.ZERO
var _last_direction := Vector2.ZERO
var _last_move_vector : Vector2 = Vector2.ZERO


#============================================================
#   Set/Get
#============================================================
## 是否正在移动
func is_moving() -> bool:
	return _moving

## 获取移动的方向
func get_last_direction() -> Vector2:
	return _last_direction

## 获取当前移动速度
func get_current_move_speed() -> float:
	return _move_speed

func get_last_move_vector() -> Vector2:
	return _last_move_vector


#============================================================
#   内置
#============================================================
func _physics_process(delta):
	_move()

func _to_string():
	return "%s:<%s#%s>" % [name, "MoveController", get_instance_id()]


#============================================================
#   自定义
#============================================================
## 移动线程
func _move() -> void:
	# 移动向量
	if _moving and _current_direction:
		_move_speed = lerp(_move_speed, move_speed, acceleration * get_physics_process_delta_time() )
		motion_velocity = _current_direction * _move_speed
	
	_last_move_vector = motion_velocity
	_last_direction = _current_direction
	self._moving = (_move_speed != 0)
	self.moved.emit(motion_velocity)
	
	# 移动后
	if _move_speed != 0:
		_move_speed = lerpf(_move_speed, 0.0, friction * get_physics_process_delta_time())
	_current_direction = Vector2.ZERO
	motion_velocity = Vector2(0, 0)


## 更新方向
##[br]
##[br][code]direction[/code]  更新到的方向
func update_direction(direction: Vector2):
	if _current_direction != direction:
		_current_direction = direction
		self.direction_changed.emit(_current_direction)


## 根据方向移动 
##[br]
##[br][code]direction[/code]  移动的方向
func move_direction(direction: Vector2):
	if enabled and direction != Vector2.ZERO:
		update_direction(direction.normalized())
		_moving = true


## 根据向量移动 
##[br]
##[br][code]velocity[/code]  移动向量
func move_vector(velocity: Vector2):
	if enabled:
		move_direction(velocity.normalized())
		_move_speed = velocity.length()
		motion_velocity = velocity
		_moving = true

