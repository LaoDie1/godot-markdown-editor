#============================================================
#    Condition Management
#============================================================
# - author: zhangxuetu
# - datetime: 2023-08-17 13:14:45
# - version: 4.0
#============================================================
class_name ConditionManagement
extends Node


var _data : Dictionary = {}


func append(group, callback: Callable):
	if not _data.has(group):
		_data[group] = []
	Array(_data[group]).append(callback)
	return callback


func erase(group, callback: Callable) -> bool:
	if _data.has(group):
		Array(_data[group]).erase(callback)
		return true
	return false


func check(group, parameters: Array = []) -> bool:
	if not _data.has(group):
		# 没有添加判断条件，默认为 true
		return true
	
	var tmp = []
	for callback in Array(_data[group]):
		if Callable(callback).is_valid():
			if not Callable(callback).callv(parameters):
				return false
		else:
			# 方法无效则添加到临时列表准备移除
			tmp.push_back(callback)
	
	if not tmp.is_empty():
		tmp.reverse()
		for callback in tmp:
			erase(group, callback)
	
	return true

