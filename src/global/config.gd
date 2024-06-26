#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:53:36
# - version: 4.3.0.dev5
#============================================================
## 配置
extends Node


var data_file : DataFile
var bind_property_list : Array[BindPropertyItem] = []


#============================================================
#  内置
#============================================================
func _init():
	# data_file 默认属性值
	var default_value : Dictionary = {
		"font_size": 18,
		"accent_color": Color(0.7578, 0.5261, 0.2944, 1),
		"text_color": Color(1,1,1,0.8),
		"font_color": Color(1,1,1,0.9),
		"line_spacing": 4,
		"current_dir": "",
		"opened_files": {},
	}
	# 加载上次保存的数据
	var data_file_path : String = OS.get_config_dir().path_join("Godot/MarkdownEditor/.config.data")
	data_file = DataFile.instance(data_file_path, DataFile.BYTES, default_value)
	data_file.set_value("line_spacing", 4)
	
	# 设置数据到当前配置的属性
	ScriptUtil.init_class_static_value(ConfigKey, 
		func(script:GDScript, path, property: String):
			# 绑定属性对象
			var property_item = BindPropertyItem.new(property, data_file.get_value(property))
			property_item.bind_method(func(value):
				# 修改属性时更新到 data_file
				data_file.set_value(property, value)
			)
			# 设置到这个脚本类中
			script.set(property, property_item)
			bind_property_list.append(property_item)
	)


func _enter_tree() -> void:
	if Engine.get_main_loop().current_scene is Control:
		var font : Font = Engine.get_main_loop().current_scene.get_theme_default_font()
		ConfigKey.Display.font.set_value( font )
	ConfigKey.Display.font_path.set_value("")


func _exit_tree():
	# 保存数据
	data_file.save()


func add_open_file(path) -> bool:
	var dict : Dictionary = ConfigKey.Path.opened_files.get_value()
	if not dict.has(path):
		dict[path] = null
		return true
	return false
