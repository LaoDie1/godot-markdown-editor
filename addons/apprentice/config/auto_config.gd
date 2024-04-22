#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-24 00:28:39
# - version: 4.0
#============================================================
## 继承这个脚本，保存在 res://auto_config 目录下，则会自动调用这个脚本的 [method _config] 方法
class_name AutoConfig
extends Node

const CONFIG_PATH = "res://auto_config"


static func __data() -> Dictionary:
	const KEY = &"__ConfigClass_Data"
	if Engine.has_meta(KEY):
		return Engine.get_meta(KEY)
	else:
		Engine.set_meta(KEY, {})
		return Engine.get_meta(KEY)

static func get_data(key, default = null):
	return __data().get(key, default)

static func set_data(key, value):
	__data()[key] = value


func _config():
	pass


