#============================================================
#    Priority Queue
#============================================================
# - author: zhangxuetu
# - datetime: 2023-07-19 00:55:27
# - version: 4.0
#============================================================
## 优先级队列
##
##输出列表会按照优先级组别输出每个项
class_name PriorityQueue


# 优先级对应的item列表
var _priority_to_item_list : Dictionary = {}
# 排序后的先级
var _sorted_priority_keys : Array = []
# 排好顺序的item的缓存列表
var _all_items_cache: Array = []
# 是否需要排序
var _sort_required : bool = false


#============================================================
#  自定义
#============================================================
func append(priority: int, item):
	if not _priority_to_item_list.has(priority):
		_sorted_priority_keys.clear()
		_priority_to_item_list[priority] = []
	
	Array(_priority_to_item_list[priority]).append(item)
	_sort_required = true


func append_array(priority: int, array: Array):
	for item in array:
		append(priority, item)


func has_priority(priority: int) -> bool:
	return _priority_to_item_list.has(priority)


func erase(priority: int, item) -> void:
	if _priority_to_item_list.has(priority):
		Array(_priority_to_item_list[priority]).erase(item)
		_all_items_cache.erase(item)


func erase_items(priority: int) -> void:
	_priority_to_item_list.erase(priority)
	_all_items_cache.clear()
	_sort_required = true


func remove(item) -> bool:
	var list : Array
	var idx : int 
	for priority in _priority_to_item_list:
		list = _priority_to_item_list[priority]
		idx = list.find(item)
		if idx > -1:
			list.remove_at(idx)
			_all_items_cache.erase(item)
			return true
	return false

func remove_all():
	_sorted_priority_keys.clear()
	_priority_to_item_list.clear()
	_all_items_cache.clear()


## 获取这个优先级的所有项
func get_items_by_priority(priority: int) -> Array:
	if _priority_to_item_list.has(priority):
		return _priority_to_item_list[priority]
	return []

## 返回根据优先级排序后的所有项
func get_all_item() -> Array:
	if _sort_required:
		_all_items_cache.clear()
		_sorted_priority_keys = _priority_to_item_list.keys()
		_sorted_priority_keys.sort()
		for key in _sorted_priority_keys:
			_all_items_cache.append_array(_priority_to_item_list[key])
	return _all_items_cache


#============================================================
#  迭代器
#============================================================
var _curr_key
var _curr_idx : int = 0

func _iter_init(arg) -> bool:
	if not _priority_to_item_list.is_empty():
		if _sorted_priority_keys.is_empty():
			_sorted_priority_keys = _priority_to_item_list.keys()
			_sorted_priority_keys.sort()
		_curr_key = 0
		_curr_idx = 0
		return true
	return false

func _iter_next(arg) -> bool:
	_curr_idx += 1
	if _curr_idx >= _priority_to_item_list[_sorted_priority_keys[_curr_key]].size():
		_curr_key += 1
		_curr_idx = 0
	return _curr_key < _sorted_priority_keys.size()

func _iter_get(arg):
	return _priority_to_item_list[_sorted_priority_keys[_curr_key]][_curr_idx]
