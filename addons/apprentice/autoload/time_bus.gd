#============================================================
#    Time Bus
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-29 12:30:28
# - version: 4.0
#============================================================
## 时间总线
extends Node


var _id : int = 0 # 添加监听时间的唯一的自增ID
var _id_to_data : Dictionary = {} # ID 对应的 item 数据


class _TaskItem:
	var id
	var current_time : int = 0
	var max_time : int = 0
	var callback : Callable
	
	var interval : float:
		set(v):
			interval = v
			max_time = int(v * 1000)


#============================================================
#  内置
#============================================================
func _physics_process(delta):
	delta *= 1000
	var item : _TaskItem 
	for id in _id_to_data:
		item = _id_to_data[id]
		item.current_time += delta
		if item.current_time > item.max_time:
			# 到达时间
			item.current_time -= item.max_time
			if is_instance_valid(item) and item.callback.is_valid() and not item.callback.is_null():
				var result = item.callback.call()
				# 返回 false 则会进行移除
				if (result is bool and not result):
					remove_task.call_deferred(item.id)
					item.free()
			else:
#				print("[ TimedPoller ] Callable 源对象无效，移除任务. ", [ "ID = ", item["id"] ])
				remove_task.call_deferred(item.id)


#============================================================
#  自定义
#============================================================
func has_task(id: int) -> bool:
	return _id_to_data.has(id)


func get_task_time_left(id: int) -> float:
	var item = get_task_data(id)
	if item:
		return (item.max_time - item.current_time) / 1000.0
	return 0.0


func get_task_data(id: int) -> _TaskItem:
	if has_task(id):
		return _id_to_data[id]
	return null


func update_task_interval(id: int, interval: float) -> void:
	var item := get_task_data(id)
	if item:
		item.interval = interval
	else:
		push_error("没有这个ID的任务: ", id)


## 添加任务
##[br]
##[br][code]interval[/code]  间隔时间
##[br][code]callback[/code]  回调方法。如果回调结果为 false，则会结束任务
##[br][code]offset_time[/code]  刚开始偏移的时间。可以让一些多个相同间隔时间的任务在不同开始时间执行回调方法
##[br][code]return[/code]  返回这个任务的ID
func add_task(interval: float, callback: Callable, offset_time: float = 0.0) -> int:
	# 记录数据
	_id += 1
	
	# 返回ID
	var item = _TaskItem.new()
	item.id = _id
	item.callback = callback
	item.interval = interval
	item.current_time = offset_time
	_id_to_data[_id] = item
	
	return _id


##  移除掉这个任务
##[br]
##[br][code]id[/code]  这个任务的Id
##[br][code]return[/code]  返回是否移除成功
func remove_task(id: int) -> bool:
	if has_task(id):
		_id_to_data.erase(id)
		return true
	return false


## 移除所有任务
func remove_all_task():
	_id_to_data.clear()
	_id = 0

