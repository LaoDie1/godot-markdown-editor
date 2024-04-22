#============================================================
#    Data Res
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-28 18:52:38
# - version: 4.0
#============================================================
## 用于保存数据文件
class_name DataFile
extends Object


var _file_path : String
var _data : Dictionary


#============================================================
#  内置
#============================================================
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		FileUtil.if_not_exists_make_dir(_file_path.get_base_dir())
		FileUtil.write_as_bytes(_file_path, _data)


#============================================================
#  自定义
#============================================================
## 实例化数据文件
##[br]
##[br]如果有这个文件，则会自动读取这个文件的数据，这个文件必须是 [Dictionary] 类型的数据
static func instance(_file_path: String, default_data: Dictionary = {}) -> DataFile:
	const KEY = &"DataFile_datas"
	if not Engine.has_meta(KEY):
		Engine.set_meta(KEY, {})
	
	var data : Dictionary = Engine.get_meta(KEY)
	if not data.has(_file_path):
		var data_file = DataFile.new()
		data_file._file_path = _file_path
		if FileAccess.file_exists(_file_path):
			var v = FileUtil.read_as_bytes_to_var(_file_path)
			data_file._data = v
		else:
			data_file._data = default_data
		data[_file_path] = data_file
	return data[_file_path]


## 队列删除
func queue_free() -> void:
	Engine.get_main_loop().queue_delete(self)


## 保存数据
func save() -> void:
	_if_not_exists_make_dir(_file_path.get_base_dir())
	_write_as_bytes(_file_path, _data)


## 获取数据值
func get_value(key, default = null):
	if not _data.has(key):
		_data[key] = default
	return _data[key]


## 添加数据项
func add_item(key, value):
	_data[key] = value


## 获取数据
func get_data() -> Dictionary:
	return _data



#============================================================
#  辅助方法
#============================================================
## 如果目录不存在，则进行创建
##[br]
##[br][code]return[/code] 如果不存在则进行创建并返回 [code]true[/code]，否则返回 [code]false[/code]
static func _if_not_exists_make_dir(dir_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
		return true
	return false


## 写入为二进制文件
static func _write_as_bytes(_file_path: String, data) -> bool:
	var bytes = var_to_bytes_with_objects(data)
	var file := FileAccess.open(_file_path, FileAccess.WRITE)
	if file:
		file.store_buffer(bytes)
		file.flush()
		return true
	return false


## 读取字节数据
static func _read_as_bytes(_file_path: String):
	if FileAccess.file_exists(_file_path):
		var file = FileAccess.open(_file_path, FileAccess.READ)
		if file:
			return file.get_file_as_bytes(_file_path)
	return null

## 读取字节数据，并转为原来的数据
static func _read_as_bytes_to_var(_file_path: String):
	var bytes = _read_as_bytes(_file_path)
	if bytes:
		return bytes_to_var_with_objects(bytes)
	return null


