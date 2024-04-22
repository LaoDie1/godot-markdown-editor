#============================================================
#    Data Management
#============================================================
# - author: zhangxuetu
# - datetime: 2023-10-17 22:58:11
# - version: 4.1
#============================================================
## 数据管理
##
##通过 [method generate_id] 获取 [Dictionary] 类型的数据指定的几个 key 生成的 id，
##然后加这个物品的数据。或者更方便的方式通过 [method get_data_by_key_value] 获取对应
##键值的数据，例如
##[codeblock]
### 获取 id_keys 为 ["name", "level"] 的对应的数据 
##DataManagement.get_data_by_key_value({
##    "name": "item name",
##    "level: 2,
##})
##[/codeblock]
class_name DataManagement
extends Node


##  数据发生改变
##[br]
##[br] - [code]id[/code]  数据的 ID
##[br] - [code]previous[/code]  改变前的数据值
##[br] - [code]current[/code]  当前的数据值
signal data_changed(id, previous, current)
## 新添加数据
signal newly_added_data(id, data)
## 移除了数据
signal removed_data(id, data)


## 唯一 ID key。根据 key 添加、修改或获取时，会根据这两个 key 的值生成对应的 id 值。
## 这个值应设置为永远不会改变且具有唯一性的值的 key；或想要通过其他属性相同想通过不同的属性
## 进行区分的值，比如不同 level 的物品不是同一数据
@export var id_keys : Array = []


# id 对应的数据映射
var _id_to_data_map : Dictionary = {}
# 数据ID的回调列表映射
var _id_monitor_callback_map : Dictionary = {}


#============================================================
#  自定义
#============================================================
##  获取所有数据，id 对应的值
func get_data_map() -> Dictionary:
	return _id_to_data_map

## 获取所有数据
func get_data_list() -> Array:
	return _id_to_data_map.values()


##  初始化设置数据
##[br]
##[br][code]data[/code]  设置的数据。[member get_data_map] 保存的数据调用这个方法实现数据加载.
func init_data(data: Dictionary):
	for id in data:
		set_data(id, data[id])


## 监听指定id的数据。如果这个 id 的数据发生改变或新增，则会调用这个方法。这个方法回调需要有两个参数
##[br] - previous 之前这个ID的值
##[br] - current 当前这个ID的值
func listen(id, callback: Callable):
	get_monitor_callback(id).append(callback)


## 获取监听回调列表
func get_monitor_callback(id) -> Array:
	if not _id_monitor_callback_map.has(id):
		_id_monitor_callback_map[id] = []
	return _id_monitor_callback_map[id]


## 根据所给数据和应 key 生成数据的 id
##[br]
##[br][code]data[/code]  数据
##[br][code]keys[/code]  数据中的key
##[br][code]return[/code]  返回数据中这些 key 对应 value 列表的 hash 值作为 id
func generate_id(data: Dictionary, keys : Array = []):
	if keys.is_empty():
		if id_keys.is_empty():
			keys = data.keys()
		else:
			keys = id_keys
	var values = []
	for key in keys:
		values.append(hash(data.get(key)))
	return PackedByteArray(values).hex_encode()


## 查找数据
##[br]
##[br][code]method[/code]  过滤数据方法。这个方法需要有一个参接收每个数据，并判断是否符合要查找的数据，
##并返回 [bool] 类型的判断结果值
##[br][code]return[/code]  返回所有符合条件的数据
func filter(method: Callable) -> Dictionary:
	if _id_to_data_map.is_empty():
		return {}
	var result = {}
	for id in _id_to_data_map:
		if method.call(_id_to_data_map[id]):
			result[id] = _id_to_data_map[id]
	return result


##  设置属性值
##[br]
##[br][code]force_change[/code]  强制进行修改，这会发出 [signal data_changed] 信号。
##一般在原来的 [Dictionary] 没有改变引用，只改变了某些key的数据的时候设置这个参数为
## [code]true[/code]
func set_data(id, value, force_change: bool = false):
	if _id_to_data_map.has(id):
		var _tmp_value = _id_to_data_map.get(id)
		if _tmp_value != value or force_change:
			_id_to_data_map[id] = value
			for callback in get_monitor_callback(id):
				callback.call(_tmp_value, value)
			self.data_changed.emit(id, _tmp_value, value)
	else:
		_id_to_data_map[id] = value
		for callback in get_monitor_callback(id):
			callback.call(null, value)
		self.newly_added_data.emit(id, value)
		self.data_changed.emit(id, null, value)


## 修改数据
func alter_data(id, property, value):
	var data = get_data(id)
	if typeof(data) != TYPE_NIL:
		if data is Dictionary or (data is Object and property in data):
			if data.get(property) != value:
				data[property] = value
				set_data(id, data, true)
		else:
			data[property] = value
			set_data(id, data, true)


## 获取这个数据的某个属性值
func get_data_property(id, property, default = null):
	var data = get_data(id)
	if typeof(data) != TYPE_NIL:
		return data[property]
	return default


##  获取属性值
##[br]
##[br][code]default[/code]  如果没有这个属性时返回的默认值
func get_data(id, default = null):
	return _id_to_data_map.get(id, default)

## 获取这个键值的ID的数据。例如 [member id_keys] 的值为 name，则获取这个对应 name 的值
## 的参数为 {"name": 对应name的值}
func get_data_by_key_value(key_value: Dictionary):
	var id = generate_id(key_value, id_keys)
	return get_data(id)


##  是否存在有这个属性
func has_data(id) -> bool:
	return _id_to_data_map.has(id)

##  移除数据
func remove_data(id):
	if _id_to_data_map.has(id):
		var value = _id_to_data_map[id]
		_id_to_data_map.erase(id)
		self.removed_data.emit(id, value)
		self.data_changed.emit(id, value, null)
	else:
		push_error("没有这个ID的物品：%s" % id)


## 添加数据
func add_data(id, data):
	set_data(id, data)


## 添加字典数据。可以自动获取设置 id
##[br]
##[br][code]data[/code]  数据值
##[br][code]keys[/code]  从这几个值中获取的数据生成id，如果没有则默认以 [member id_keys]
##的值生成id，如果 [member id_keys] 为空，则全部的 keys 数据的 hash 值作为 id
func add_data_by_keys(data: Dictionary, keys: Array = []):
	var id = generate_id(data, keys)
	set_data(id, data)
	return id


## 根据字典中的 key 移除数据
func remove_data_by_keys(data: Dictionary, keys: Array = []):
	var item_id = generate_id(data, keys)
	remove_data(item_id)


## 获取数据并转为 [bool] 类型
func get_data_as_bool(id, default : bool = false) -> bool:
	return bool(_id_to_data_map.get(id, default))

## 获取数据并转为 [int] 类型
func get_data_as_int(id, default : int = 0) -> int:
	return int(_id_to_data_map.get(id, default))

## 获取数据并转为 [float] 类型
func get_data_as_float(id, default : float = 0.0) -> float:
	return float(_id_to_data_map.get(id, default))

## 获取数据并转为 [int] 类型
func get_data_as_str(id, default : String = "") -> String:
	return str(_id_to_data_map.get(id, default))

## 获取分组后的数据。例如获取所有不同类型的武器的分组数据
##[codeblock]
##var groups_data = DataManagement.get_groups_data(["weapon_type"])
##var group_data = groups_data["weapon_type"]
##var weapon_types = group_data.keys()
##print("数据中的所有武器的类型：", weapon_types)
##for weapon_type in weapon_types:
##     print(weapon_type, " 类型所有数据：", group_data[weapon_type])
##[/codeblock]
func get_groups_data(groups: Array) -> Dictionary:
	var groups_data = {}
	var value
	for group in groups:
		var group_data = {}
		for data in get_data_list():
			value = data.get(group)
			if value:
				if not group_data.has(value):
					group_data[value] = []
				group_data[value].append(value)
		groups_data[group] = group_data
	return groups_data


## 获取这个组中的类型的数据分类后的数据列表
func get_group_data(group) -> Dictionary:
	var value
	var group_data = {}
	for data in get_data_list():
		value = data.get(group)
		if value:
			if not group_data.has(value):
				group_data[value] = []
			group_data[value].append(data)
	return group_data
