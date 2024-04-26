#============================================================
#    Data Res
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-28 18:52:38
# - version: 4.0
#============================================================
## 用于保存数据文件
##
##示例：
##[codeblock]
##extends Node
##
##var data_file : DataFile
##
##func _init():
##    data_file = DataFile.instance(
##        file_path, 
##        DataFile.STRING, 
##        {
##            "key1": value,
##            "key2": value,
##        }
##    )
##
##func _exit_tree():
##    data_file.save()
##[/codeblock]
class_name DataFile
extends Object

enum {
	BYTES,
	STRING,
}

var file_path : String
var data : Dictionary
var data_format : int = BYTES # 保存的文件的数据格式


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
	
	FileUtil.make_dir_if_not_exists(file_path.get_base_dir())
	
	var data : Dictionary = Engine.get_meta(KEY)
	if not data.has(file_path):
		var data_file = DataFile.new()
		data_file.file_path = file_path
		data_file.data_format = data_format
		if FileAccess.file_exists(file_path):
			match data_format:
				BYTES:
					data_file.data = FileUtil.read_as_bytes_to_var(file_path)
				STRING:
					data_file.data = FileUtil.read_as_str_var(file_path)
		else:
			data_file.data = default_data
		data[file_path] = data_file
	return data[file_path]


## 保存数据
func save() -> void:
	FileUtil.make_dir_if_not_exists(file_path.get_base_dir())
	match data_format:
		BYTES:
			FileUtil.write_as_bytes(file_path, data)
		STRING:
			FileUtil.write_as_str_var(file_path, data)

func has_value(key) -> bool:
	return data.has(key)

## 获取数据值
func get_value(key, default = null):
	if not data.has(key):
		data[key] = default
	return data[key]

## 设置数据
func set_value(key, value):
	data[key] = value

func remove_value(key) -> bool:
	return data.erase(key)

## 获取数据
func get_data() -> Dictionary:
	return data

func get_keys() -> Array:
	return data.keys()

