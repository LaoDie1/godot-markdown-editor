#============================================================
#	Move To Point
#============================================================
# @datetime: 2022-7-31 12:59:58
#============================================================
## 移动到位置。添加到 [MoveToPoints] 节点下，即可自动连接其移动信号。
class_name MoveToPoint
extends Node2D


signal ready_move(to_position: Vector2) ## 准备移动到位置
signal moved(direction: Vector2) ## 移动到方向
signal arrived ## 到达位置
signal stopped ## 停止


## 在这个距离内则视为到达了位置
@export var arrive_distance : float = 100.0
## 更新移动方向的间隔时间
@export var update_direction_time : float = 0.1:
	set(v):
		update_direction_time = v
		if update_direction_time < get_physics_process_delta_time():
			update_direction_time = get_physics_process_delta_time()


@onready var _to_point : Vector2 = global_position

var _last_rot : float = INF
var _to_dir : Vector2 = Vector2.ZERO
var _time : float = 0.0
var _arrived_squared_distance : float:
	get: return pow(arrive_distance, 2)


#============================================================
#   SetGet
#============================================================
## 是否正在执行
func is_running() -> bool:
	return is_physics_processing()

## 获取目的地的方向
func get_move_to_direction() -> Vector2:
	return _to_dir

## 获取移动到的位置
func get_move_to_position() -> Vector2:
	return _to_point

## 获取剩余距离
func get_distance_left() -> float:
	return self.global_position.distance_to(_to_point)

## 是否到达可移动范围内
func is_in_range(point: Vector2) -> bool:
	return self.global_position.distance_squared_to(point) <= _arrived_squared_distance


#============================================================
#   内置
#============================================================
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		set_process(false)
	if arrive_distance == 0:
		push_warning("MoveToPoint 节点的 'arrive_distance' 属性为 0，这很有可能会导致到达位置附近时发生抖动")
	
	if update_direction_time < get_physics_process_delta_time():
		update_direction_time = get_physics_process_delta_time()


func _ready() -> void:
	set_physics_process(false)
	
	# 如果父节点为 MoveToPoints 则自动连接信号
	if get_parent() is MoveToPoints:
		var move_to_points : MoveToPoints = get_parent()
		move_to_points.moved_next.connect(self.to)
		move_to_points.move_finished.connect(self.stop)
		move_to_points.stopped.connect(self.stop)
		
		self.arrived.connect(move_to_points.next)
		self.stopped.connect(move_to_points.stop)


func _physics_process(delta):
	_time += delta
	if _time >= update_direction_time:
		_time -= update_direction_time
		_update_move_direction()
	
	if not self.global_position.distance_squared_to(_to_point) <= _arrived_squared_distance:
		if _last_rot != global_rotation:
			_update_move_direction()
		self.moved.emit(_to_dir)
		
	else:
		_time = 0
		set_physics_process(false)
		self.arrived.emit()


#============================================================
#   自定义
#============================================================
#  更新移动方向
func _update_move_direction() -> void:
	_last_rot = global_rotation
	_to_dir = global_position.direction_to(_to_point)


##  移动到位置
##[br]
##[br][code]global_point[/code]  移动到的位置
func to(global_point: Vector2) -> void:
	if global_point != _to_point or not is_physics_processing():
		_time = 0
		_to_point = global_point
		self.ready_move.emit(_to_point)
		set_physics_process(true)
		_update_move_direction()
		
		# 使用 set_physics_process(true) 时，中间有一帧停留时间，需要手动调用一次
		_physics_process.call_deferred(get_physics_process_delta_time())


##  停止
func stop() -> void:
	_to_point = global_position
	set_physics_process(false)
	if is_physics_processing():
		self.stopped.emit()

