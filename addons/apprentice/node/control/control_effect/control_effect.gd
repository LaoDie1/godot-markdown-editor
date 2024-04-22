#============================================================
#    Control Effect
#============================================================
# - datetime: 2023-02-25 20:26:41
#============================================================
class_name ControlEffect
extends Control


signal finished


enum {
	TARGET,
	CHILDREN,
}


@export var auto_toggle : bool = false
## 操作的目标节点
@export var target_node : Control
## 控制目标节点或者控制目标节点的所有子节点
@export_enum("Target", "Children") var mode : int = 0
## 执行持续时间
@export var duration : float = 1.0
## 间隔执行时间
@export var interval : float = 0.0
## 延迟执行时间
@export var delay_time : float = 0.0

var _state : bool = false
var _origin_data : Dictionary = {}
var _timer := Timer.new()


#============================================================
#  SetGet
#============================================================
## 获取原始数据
func get_origin_data(node: Control):
	var id = hash(node)
	return _origin_data[id]

func _add_origin_data(node: Control):
	_origin_data[hash(node)] = _get_origin_data(node)

func _remove_origin_data(node: Control):
	_origin_data.erase(node)

func get_node_list() -> Array:
	if mode == TARGET:
		if target_node:
			return [target_node]
		return []
	else:
		return target_node.get_children()


#============================================================
#  内置
#============================================================
func _ready():
	update_node_origin()
	_add_origin_data(target_node)
	target_node.child_entered_tree.connect(func(node):
		if node is Control:
			_add_origin_data(node)
	)
	target_node.child_exiting_tree.connect(func(node):
		if node is Control:
			_remove_origin_data(node)
	)
	
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(func(): self.finished.emit() )
	
	if auto_toggle:
		execute.call_deferred(true)


#============================================================
#  自定义
#============================================================
## 更新原始数据信息
func update_node_origin():
	_add_origin_data(target_node)
	for node in get_node_list():
		if node is Control:
			_add_origin_data(node)


func is_executing() -> bool:
	return _state


func execute(state: bool = true) -> void:
	if not _can_execute(state):
		return
	_state = state
	
	if delay_time > 0:
		await get_tree().create_timer(delay_time).timeout
	
	_execute_before()
	
	var list = get_node_list()
	_timer.start(duration + interval * list.size() - 1)
	
	if state:
		for child in list:
			if not _state:
				return
			if child is Control:
				_add_origin_data(child)
				_execute_handle(child, state)
				if interval > 0:
					await get_tree().create_timer(interval).timeout
	else:
		for child in list:
			if _state:
				return
			if child is Control:
				_execute_handle(child, state)
				if interval > 0:
					await get_tree().create_timer(interval).timeout
	
	_execute_after()

## 返回这个节点的初始置
func _get_origin_data(node: Control):
	pass


##  是否可以执行
##[br]
##[br][code]ready_state[/code]  装备执行的状态
func _can_execute(ready_state: bool) -> bool:
	return true


func _execute_before() -> void:
	pass


## 执行节点控制节点时的操作
func _execute_handle(node: Control, state: bool) -> void:
	pass


func _execute_after() -> void:
	pass


