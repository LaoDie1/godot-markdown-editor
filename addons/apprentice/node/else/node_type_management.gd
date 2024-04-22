#============================================================
#    Node Type Management
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-14 12:35:39
# - version: 4.0
#============================================================
##管理控制 Area2D 检测到的节点，并根据添加的类型的条件进行判断并分类记录，
##以用于根据类型获取对应分类后的节点列表
##
##[codeblock]
### ground 类型的节点的条件
##NodeTypeManagement.add_type(&"ground", func(node):
##    return (节点是 xx 类型且射线可以检测到)
##)
### 获取这个类型的所有节点
##NodeTypeManagement.get_nodes_by_type(&"ground")
##[/codeblock]
##
##这样做到可以达到统一管理这些节点的条件的目的
class_name NodeTypeManagement
extends Node


signal found_enemy(type, node: Node) # 发现的敌人
signal lost_node(type, node: Node)
signal type_node_changed(type)


## 指定检测节点的区域节点
@export_node_path("Area2D", "Area3D") var target_area : NodePath:
	set(v):
		target_area = v
		__update_connect()
## 是否记录 Area 节点
@export var record_area : bool = true: 
	set(v):
		record_area = v
		__update_connect()
## 是否记录 Body 节点
@export var record_body : bool = false:
	set(v):
		record_body = v
		__update_connect()


var _conditions : Array[Callable] = []
var _node_to_types_map : Dictionary = {}
var _type_to_data_map : Dictionary = {}
var _target_area : Node
var _tmp_cache_filter_nodes : Dictionary = {}


func _ready():
	__update_connect()
	Engine.get_main_loop().physics_frame.connect(func():
		_tmp_cache_filter_nodes.clear()
	)


func __update_connect():
	if not is_inside_tree():
		await ready
	
	if _target_area:
		if _target_area.area_entered.is_connected(__node_entered):
			_target_area.area_entered.disconnect(__node_entered)
		if _target_area.area_exited.is_connected(__node_exited):
			_target_area.area_exited.disconnect(__node_exited)
		
		if _target_area.body_entered.is_connected(__node_entered):
			_target_area.body_entered.disconnect(__node_entered)
		if _target_area.body_exited.is_connected(__node_exited):
			_target_area.body_exited.disconnect(__node_exited)
	
	_target_area = get_node_or_null(target_area)
	if _target_area == null:
#		printerr("[NodeTypeManagement] 没有指定节点")
		return
	
	if record_area:
		if not _target_area.area_entered.is_connected(__node_entered):
			_target_area.area_entered.connect(__node_entered)
		if not _target_area.area_exited.is_connected(__node_exited):
			_target_area.area_exited.connect(__node_exited)
	
	if record_body:
		if not _target_area.body_entered.is_connected(__node_entered):
			_target_area.body_entered.connect(__node_entered)
		if not _target_area.body_exited.is_connected(__node_exited):
			_target_area.body_exited.connect(__node_exited)


func __node_entered(node: Node):
	for condition in _conditions:
		if not condition.call(node):
			return
	
	var types : Array = []
	_node_to_types_map[node] = types
	var data : Dictionary
	for type in _type_to_data_map:
		data = _type_to_data_map[type]
		if data["condition"].call(node):
			data["list"].append(node)
			types.append(type)
			self.found_enemy.emit(type, node)
			self.type_node_changed.emit(type)


func __node_exited(node: Node):
	var types = _node_to_types_map.get(node)
	if types is Array:
		_node_to_types_map.erase(node)
		for type in types:
			# 移除节点
			_type_to_data_map[type]["list"].erase(node)
			self.lost_node.emit(type, node)
			self.type_node_changed.emit(type)

## 添加总控制条件，如果不符合条件则不记录这个节点
func add_condition(condition: Callable):
	_conditions.append(condition)

##  添加节点类型
##[br]
##[br][code]type[/code]  类型
##[br][code]condition[/code]  过滤方法。需要返回一个 bool 的值用于判断节点是否符合这个类型
func add_type(type, condition: Callable):
	assert(not (type is String and type == ""), "不能设置为空")
	_type_to_data_map[type] = {
		"condition": condition,
		"list": [],
	}

func get_condition(type) -> Callable:
	return _type_to_data_map[type]["condition"]

func has_type(type) -> bool:
	return _type_to_data_map.has(type)

## 移除类型
func remove_type(type):
	_type_to_data_map.erase(type)

## 获取检测到的所有节点
func get_all_node() -> Array:
	return _node_to_types_map.keys()

## 获取这个类型的节点列表。使用懒加载的方式执行获取，在获取时才进行过滤一次
func get_nodes_by_type(type) -> Array:
	if not _type_to_data_map.has(type) or _node_to_types_map.is_empty():
		return []
	if not _tmp_cache_filter_nodes.has(type):
		var condition_method = _type_to_data_map[type]["condition"]
		_tmp_cache_filter_nodes[type] = _node_to_types_map.keys().filter(condition_method)
	return _tmp_cache_filter_nodes[type]

## 获取这些类型的节点
func get_nodes_by_types(types: Array) -> Array:
	var list = []
	for type in types:
		list.append_array(get_nodes_by_type(type))
	return list

## 这个类型的节点列表是否为空
func is_empty(type) -> bool:
	return get_nodes_by_type(type).is_empty()

## 这个类型中存在有这个节点
func exists_node_in_type(type, node: Node) -> bool:
	return get_nodes_by_type(type).has(node)

## 是否存在节点
func exists_node() -> bool:
	return not _node_to_types_map.is_empty()

