#============================================================
#    Timeline
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-24 23:10:53
# - version: 4.1
#============================================================
class_name TimeLine
extends Node


## 执行完这个阶段时发出这个信号
signal executed_stage(stage, data)
## 手动停止执行
signal stopped
## 暂停执行
signal paused
## 继续执行
signal resumed
## 执行完成
signal finished


## process 执行方式
enum ProcessExecuteMode {
	PROCESS, ## _process 执行
	PHYSICS, ## _physics_process 执行
}

enum {
	UNEXECUTED, ## 未执行
	EXECUTING, ## 执行中
	PAUSED, ## 暂停中
}


## 时间阶段名称。这关系到 [method execute] 方法中的数据获取的时间数据
@export var stages : Array = []
## process 执行方式。如果设置为 [member PROCESS] 或 [member PHYSICS] 以外的值，
## 则当前节点的线程将不会执行
@export var process_execute_mode : ProcessExecuteMode = ProcessExecuteMode.PROCESS


var _last_data : Dictionary
var _point : int = -1:
	set(v):
		if _point != v:
			_point = v
			if _point >= 0 and _point < stages.size():
				self.executed_stage.emit(stages[_point], _last_data)
var _time : float
var _execute_state : int = UNEXECUTED:
	set(v):
		if _execute_state == v:
			return
		
		_execute_state = v
		match _execute_state:
			UNEXECUTED:
				set_process(false)
				set_physics_process(false)
			EXECUTING:
				if process_execute_mode == ProcessExecuteMode.PROCESS:
					set_process(true)
				elif process_execute_mode == ProcessExecuteMode.PHYSICS:
					set_physics_process(true)
			PAUSED:
				set_process(false)
				set_physics_process(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		set_process(false)
		set_physics_process(false)

func _process(delta):
	_exec(delta)

func _physics_process(delta):
	_exec(delta)

func _exec(delta):
	_time -= delta
	while _time <= 0:
		_point += 1
		if _point < stages.size():
			_time += _last_data[stages[_point]]
		else:
			_point = -1
			_execute_state = UNEXECUTED
			self.finished.emit()
			return

func get_time_left():
	return _time

func get_last_data() -> Dictionary:
	return _last_data

func get_last_stage():
	return stages[_point]

## 执行功能。这个数据里需要有 [member stages] 中的 key 的数据，且需要是 [int] 或 [float]
## 类型作为判断执行的时间。否则默认时间为 0
func execute(data: Dictionary):
	_last_data = data
	_point = 0
	if not stages.is_empty():
		_execute_state = EXECUTING
		for stage in stages:
			_last_data[stage] = float(data.get(stage, 0))
		# 执行时会先执行一下
		_time = _last_data[stages[0]]
		_exec(0)
		
	else:
		printerr("没有设置 stages，必须要设置每个执行的阶段的 key 值！")

## 获取执行状态
func get_execute_state():
	return _execute_state

## 是否正在执行
func is_executing():
	return _execute_state == EXECUTING

## 停止执行
func stop():
	if _execute_state == EXECUTING:
		_execute_state = UNEXECUTED
		self.stopped.emit()

## 暂停执行
func pause():
	if _execute_state == EXECUTING:
		_execute_state = PAUSED

## 恢复执行
func resume():
	if _execute_state == PAUSED:
		_execute_state = EXECUTING
		self.resumed.emit()

## 跳跃到这个阶段
func goto(stage):
	if _execute_state == EXECUTING:
		if stages.has(stage):
			_point = stage
			_time = _last_data[stages[0]]
		else:
			printerr("stages 中没有 ", stage, ". 所有 stage: ", stages)
