#============================================================
#    Detect Area
#============================================================
# - author: zhangxuetu
# - datetime: 2023-08-03 21:49:19
# - version: 4.0
#============================================================
## 检测对象区域
class_name DetectArea2D
extends Area2D


## 检测到的节点
signal detected_node(node: Node2D)
## 时间结束检测完成
signal finished


## 自动检测区域内的节点。设置时间如果超过 0，则会自动间隔这个时间进行发出检测信号。
## 如果时间短于物理帧时间，则会多次调用（TODO: 待测试）
@export_range(0, 1, 0.001, "or_greater", "hide_slider") 
var auto_detect_time : float = 0.0:
	set(v):
		auto_detect_time = max(v, 0)
		if not is_inside_tree():
			await ready
		set_physics_process(auto_detect_time > 0)
		if auto_detect_time <= 0:
			_time_left = 0
## [member auto_detect_time] 时间超过 0 自动调用检测方法时的检测持续时间
@export var auto_detect_duration: float = 0.0
## 只自动调用一次
@export var one_shot : bool = false
## 可以检测到 Area2D
@export var detect_area : bool = true:
	set(v):
		detect_area = v
		if not is_inside_tree():
			return
		_update_conncet_signal()
## 可以检测到 PhysicsBody2D 相关的物理节点
@export var detect_body : bool = true:
	set(v):
		detect_body = v
		if not is_inside_tree():
			return
		_update_conncet_signal()

var _time_left : float = 0.0
var _cache : Dictionary = {}
var _detected_nodes : Dictionary = {}
var _readied_update_conncet_signal = FuncUtil.on_ready(func():
	set_physics_process(auto_detect_time > 0)
	_update_conncet_signal()
)


#============================================================
#  内置
#============================================================
func _physics_process(delta):
	_time_left -= delta
	if _time_left <= 0:
		_time_left = 0
		if auto_detect_time > 0:
			# 如果时间非常短，比物理帧间隔时间还要短，则进行多次调用
			if auto_detect_time < delta:
				for i in floori( delta / auto_detect_time) - 1:
					detects(0)
			# 进行自动检测
			detects(auto_detect_duration)
			# 一次性调用
			if one_shot:
				auto_detect_time = 0
		else:
			set_physics_process(false)
		self.finished.emit()
		_detected_nodes.clear()


#============================================================
#  自定义
#============================================================
func _update_conncet_signal():
	if detect_area and not is_connected("area_entered", _detect_enter):
		area_entered.connect(_detect_enter)
	elif not detect_area and is_connected("area_entered", _detect_enter):
		area_entered.disconnect(_detect_enter)
	
	if detect_body and not is_connected("body_entered", _detect_enter):
		body_entered.connect(_detect_enter)
	elif not detect_body and is_connected("body_entered", _detect_enter):
		body_entered.disconnect(_detect_enter)


func _detect_enter(node: Node2D, ignore_time_left: bool = false):
	if (
		(ignore_time_left or _time_left > 0) 
		and not _detected_nodes.has(node)
	):
		_detected_nodes[node] = null
		self.detected_node.emit(node)


## 获取调用 [method detects] 这段时间内检测到的节点
func get_detected_nodes() -> Array[Node2D]:
	if not _detected_nodes.is_empty():
		var list = _detected_nodes \
			.keys() \
			.filter(func(node): return is_instance_valid(node))
		return Array(list, TYPE_OBJECT, &"Node2D", null)
	else:
		return Array([], TYPE_OBJECT, &"Node2D", null)

## 存在检测到的节点。需要 [method detects] 调用时间内使用，否则会一直为 false
func exists_detect_node() -> bool:
	return not _detected_nodes.is_empty()

## 是否在这段时间检测到这个节点
func is_detected_node(node) -> bool:
	return _detected_nodes.has(node)

## 获取剩余检测时间
func get_detect_time_left() -> float:
	return _time_left

## 检测节点。检测到的对象会以 [signal detected_node] 信号发出
func detects(time: float = 0):
	if not is_instance_valid(self):
		return
	if time < 0:
		assert(time == -1, "没有设置时间")
		return
	
	_time_left = time
	_detected_nodes.clear()
	set_physics_process(_time_left >= 0)
	
	if detect_area:
#		print_debug("检测到节点", [ owner, ": ", get_overlapping_areas().map(func(node): return node.owner) ])
		for node in get_overlapping_areas():
			_detect_enter(node, true)
	if detect_body:
		for node in get_overlapping_bodies():
			_detect_enter(node, true)

