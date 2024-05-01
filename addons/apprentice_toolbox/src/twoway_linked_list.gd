#============================================================
#    Twoway Linked List
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 23:55:36
# - version: 4.3.0.dev5
#============================================================
## 双向链表。不能有重复的值，适用于 Object 类型的操作
class_name TwowayLinkedList


var first = null    # 第一个
var last = null     # 末尾
var left : Dictionary = {}   # 左边对应下一个
var right : Dictionary = {}  # 右边对应上一个
var count : int = 0


#============================================================
#  自定义
#============================================================
## 添加
func append(object):
	if first == null:
		first = object
	set_next(last, object)
	set_previous(object, last)
	last = object
	count += 1

func has_object(object) -> bool:
	return left.has(object) or right.has(object)

## 移除
func erase(object):
	if has_object(object):
		var previous = get_previous(object)
		var next = get_next(object)
		set_next(previous, next)
		set_previous(next, previous)
		if object == first:
			first = next
		elif object == last:
			last = previous
		left.erase(object)
		right.erase(object)
		count -= 1
		return true
	return false


# 插入对象到 [param to] 节点之前
func insert_before(object, to):
	if to != null:
		var previous = get_previous(to)
		# (排列图示) previous | object | to 
		set_previous(object, previous)
		set_next(previous, object)
		set_next(object, to)
		set_previous(to, object)
		
		if previous == first:
			first = object
		count += 1
		
	else:
		append(object)


# 插入对象到 [param to] 节点之后
func insert_after(object, to):
	if to != null:
		var next = get_next(to)
		# (排列图示) to | object | next 
		set_previous(next, object)
		set_next(object, next)
		set_previous(object, to)
		set_next(to, object)
		if to == last:
			last = object
		count += 1
		
	else:
		append(object)


## 合并节点，并返回中间合并的项
func merge(from, to) -> Array:
	# from | next 
	var next = get_next(to)
	var list : Array = []
	var result = find_next(from, func(item):
		list.append(item)
		return item == to
	)
	if result == null:
		# 没有找到 to 节点
		return []
	for item in list:
		left.erase(item)
		right.erase(item)
	set_previous(next, from)
	set_next(from, next)
	return list


func set_next(object, next):
	if typeof(object) != TYPE_NIL:
		left[object] = next

func set_previous(object, previous):
	if typeof(object) != TYPE_NIL:
		right[object] = previous

func get_first():
	return first

func get_last():
	return last

func get_count() -> int:
	return count

func get_previous(object):
	return right.get(object, null)

func get_next(object):
	return left.get(object, null)

func get_list() -> Array:
	var list : Array = []
	var curr = first
	var map = {}
	while typeof(curr) != TYPE_NIL:
		list.append(curr)
		curr = get_next(curr)
	return list


## 向后遍历。若想带有结束条件，请使用 [method find_next] 方法
##[br]
##[br]- [param method]  这个方法需要有一个参数接收每个项
##[br]- [param include_self]  遍历时是否包含传入的 [param object] 参数
func for_next(object, method: Callable, include_self : bool = false):
	var curr = (object if include_self else get_next(object))
	while typeof(curr) != TYPE_NIL:
		method.call(curr)
		curr = get_next(curr)


## 向前遍历。若想带有结束条件，请使用 [method find_previous] 方法
##[br]
##[br]- [param method]  这个方法需要有一个参数接收每个项
##[br]- [param include_self]  遍历时是否包含传入的 [param object] 参数
func for_previous(object, method: Callable, include_self : bool = false):
	var curr = (object if include_self else get_previous(object))
	while typeof(curr) != TYPE_NIL:
		method.call(curr)
		curr = get_previous(curr)


## 向后搜索
##[br]
##[br]- [param method]  这个方法需要有一个参数接收每个项，方法返回 [code]true[/code] 即可终止循环
##[br]- [param include_self]  遍历时是否包含传入的 [param object] 参数
func find_next(object, method: Callable, include_self : bool = false):
	var curr = (object if include_self else get_next(object))
	var result
	while typeof(curr) != TYPE_NIL:
		result = method.call(curr)
		if result is bool and result:
			return curr
		curr = get_next(curr)
	return curr


## 向前搜索
##[br]- [param method]  这个方法需要有一个参数接收每个项，方法返回 [code]true[/code] 即可终止循环
##[br]- [param include_self]  遍历时是否包含传入的 [param object] 参数
func find_previous(object, method: Callable, include_self : bool = false):
	var curr = (object if include_self else get_previous(object))
	var result
	while typeof(curr) != TYPE_NIL:
		result = method.call(curr)
		if result is bool and result:
			return curr
		curr = get_previous(curr)
	return curr


