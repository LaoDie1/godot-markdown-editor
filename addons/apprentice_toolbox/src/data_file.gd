#============================================================
#    Data File
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 11:52:24
# - version: 4.2.1
#============================================================
## 用于保存数据。
##
##示例：添加一个配置节点 [b]config.gd[/b] 脚本，添加到 [b]自动加载[/b] 中，即可快速创建程序的配置数据
##[codeblock]
##extends Node
##
##var data_file : DataFile = DataFile.instance(data_file_path)
##var exclude_config_propertys : Array[String] = ["exclude_config_propertys", "data_file"]
##
### Custom data
##var files: Array
##var current_path: String
##
##func _init():
##    # 加载 Config 数据
##    data_file.update_object_property(self, exclude_config_propertys)
##
##func _exit_tree() -> void:
##    # 保存 Config 数据
##    data_file.set_value_by_object(self, exclude_config_propertys)
##    data_file.save()
##[/codeblock]
class_name DataFile
extends RefCounted


signal value_changed(key, previous_value, value)


enum {
	BYTES,   ## 原始数据
	STRING,  ## 字符串类型数据。但对部分数据类型转换后会出现转换错误问题
}

## 文件所在路径
var file_path : String
## 数据
var data : Dictionary
## 保存的文件的数据格式
var data_format : int = BYTES


#============================================================
#  自定义
#============================================================
## 实例化数据文件
##[br]
##[br]如果有这个文件，则会自动读取这个文件的数据，这个文件必须是 [Dictionary] 类型的数据
static func instance(file_path: String, data_format : int = BYTES, default_data: Dictionary = {}) -> DataFile:
	const KEY = &"DataFile_datas"
	if not Engine.has_meta(KEY):
		Engine.set_meta(KEY, {})
	
	make_dir_if_not_exists(file_path.get_base_dir())
	
	var data : Dictionary = Engine.get_meta(KEY)
	if not data.has(file_path):
		var data_file = DataFile.new()
		data_file.file_path = file_path
		data_file.data_format = data_format
		if FileAccess.file_exists(file_path):
			match data_format:
				BYTES:
					data_file.data = read_as_bytes_to_var(file_path)
				STRING:
					data_file.data = read_as_str_var(file_path)
		data_file.data.merge(default_data, false)
		data[file_path] = data_file
	return data[file_path]


## 保存数据
func save():
	make_dir_if_not_exists(file_path.get_base_dir())
	match data_format:
		BYTES:
			return write_as_bytes(file_path, data)
		STRING:
			return write_as_str_var(file_path, data)

## 是否存在有这个 key 的数据
func has_value(key) -> bool:
	return data.has(key)

## 获取数据值
func get_value(key, default = null):
	if not data.has(key):
		data[key] = default
	return data[key]

## 设置数据
func set_value(key, value):
	if data.has(key):
		var previous = data[key]
		if typeof(previous) != typeof(value) or previous != value:
			data[key] = value
			value_changed.emit(key, null, value)
	else:
		data[key] = value
		value_changed.emit(key, null, value)

## 移除这个 key 的值
func remove_value(key) -> bool:
	return data.erase(key)

## 获取数据
func get_data() -> Dictionary:
	return data

## 获取数据的所有的 key
func get_keys() -> Array:
	return data.keys()

## 设置到对象这些属性
func update_object_property(object: Object, exclude_propertys: Array = []):
	for key in data:
		if (not exclude_propertys.has(key) 
			and key in object
		):
			object.set(key, data[key])

## 根据对象的脚本的属性设置值
func set_value_by_object(object: Object, exclude_propertys: Array = []):
	var script = object.get_script() as GDScript
	if script == null:
		return
	var p_name : String
	for p_data in script.get_script_property_list():
		p_name = p_data["name"]
		if not p_name in exclude_propertys and p_name in object:
			set_value(p_name, object[p_name])



#============================================================
#  文件操作
#============================================================
## 如果目录不存在，则进行创建
##[br]
##[br][code]return[/code] 如果不存在则进行创建并返回 [code]true[/code]，否则返回 [code]false[/code]
static func make_dir_if_not_exists(dir_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(dir_path):
		if DirAccess.make_dir_recursive_absolute(dir_path) == OK:
			return true
	return false

## 读取字节数据
static func read_as_bytes(file_path: String) -> PackedByteArray:
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			return file.get_file_as_bytes(file_path)
	return PackedByteArray()

## 读取字节数据，并转为原来的数据
static func read_as_bytes_to_var(file_path: String):
	var bytes = read_as_bytes(file_path)
	if not bytes.is_empty():
		return bytes_to_var_with_objects(bytes)
	return null

## 读取字符串并转为变量数据
static func read_as_str_var(file_path: String):
	var text = FileAccess.get_file_as_string(file_path)
	return str_to_var(text)


## 写入为二进制文件
static func write_as_bytes(file_path: String, data) -> bool:
	var bytes = var_to_bytes_with_objects(data)
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_buffer(bytes)
		file.flush()
		return true
	return false

## 写入字符串变量数据
static func write_as_str_var(file_path: String, data):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var text = var_to_str(data)
		file.store_string(text)
		file.flush()
		return true
	return false
