#============================================================
#    Event Controller
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-06 13:42:01
# - version: 4.0
#============================================================
class_name EventController
extends Node


signal occurred(event, data) ##发生了事件


enum {
	QUEUE,
	CONDITION,
}

var _events : Dictionary = {}


func _physics_process(delta):
	for data in _events:
		# 检查条件
		if not data[CONDITION].is_empty():
			for condition in data[CONDITION]:
				if not condition.call():
					continue
		for queue in data[QUEUE]:
			occurred.emit(queue, data)
		data[QUEUE].clear()


## 添加事件触发条件
func add_toggle_condition(event, method: Callable):
	if not _events.has(event):
		register_event(event)
	_events[event][CONDITION].append(method)


func register_event(event):
	_events[event] = {
		QUEUE: [],
		CONDITION: [],
	}


## 添加到事件触发队列
func queue_toggle(event, data):
	if _events.has(event):
		_events[event][QUEUE].append([event, data])
		return true
	return false

