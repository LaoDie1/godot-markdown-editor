#============================================================
#    Multi Split Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 23:37:27
# - version: 4.3.0.dev5
#============================================================
## 多节点排列
class_name MultiSplitContainer
extends Control


## 水平排列
@export var horizontal : bool = true
## 排列节点
@export var scene : PackedScene
## 间隔距离
@export var separation : int = 8
## 节点长度
@export var length : int = 200
## 右侧扩展宽度
@export var right_expand_width : int = 300


## 子项
var item_list : TwowayLinkedList = TwowayLinkedList.new()


#============================================================
#  内置
#============================================================
func _init() -> void:
	resized.connect(
		func():
			if horizontal:
				for item: Control in item_list.get_list():
					item.size.y = self.size.y
			else:
				for item: Control in item_list.get_list():
					item.size.x = self.size.x
	)


#============================================================
#  自定义
#============================================================
func get_items() -> Array:
	return item_list.get_list()


func _offset_backward(from_item: Control, offset: int):
	item_list.for_next(from_item, func(node: Control):
		node.position.x -= offset
	)
	_update_mini_width()


func _update_mini_width():
	var last : Control = item_list.get_last()
	custom_minimum_size.x = (
		last.position.x 
		+ last.size.x 
		+ separation * item_list.get_count()
	) + right_expand_width


func create_item() -> Control:
	var item : Control = scene.instantiate() as Control
	add_child(item)
	var item_axis : int = Vector2.AXIS_X if horizontal else Vector2.AXIS_Y
	# 大小
	item.size[item_axis] = length
	# 位置
	var last = item_list.get_last()
	if last:
		var offset = last.position[item_axis] + last.size[item_axis] + separation
		item.position[item_axis] = offset
	# 更新大小
	var last_length : Array[float] = [ item.size[item_axis] ]
	item.resized.connect(func():
		_offset_backward(item, last_length[0] - item.size[item_axis])
		last_length[0] = item.size[item_axis]
	)
	# 其他
	item_list.append(item)
	item.tree_exited.connect(remove.bind(item))
	_update_mini_width()
	return item


func remove(item: Control):
	var next : Control = item_list.get_next(item)
	if next:
		# 后面的节点向前偏移
		_offset_backward(item, next.position.x - item.position.x)
	item_list.erase(item)
	if item.is_inside_tree():
		remove_child(item)
	_update_mini_width()	
