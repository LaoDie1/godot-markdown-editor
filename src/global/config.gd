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
	var default_value : Dictionary = {
		"font_size": 18,
		"accent_color": Color(0.7578, 0.5261, 0.2944, 1),
		"text_color": Color(1,1,1,0.8),
		"font_color": Color(1,1,1,0.9),
		"line_spacing": 8,
		"current_dir": "",
		"opened_files": {},
	}
	var data_file_path : String = OS.get_config_dir().path_join("Godot/MarkdownEditor/.config.data")
	data_file = DataFile.instance(data_file_path, DataFile.BYTES, default_value)
	
	## TEST
	#data_file.data.clear()
	#data_file.data = default_value
	
	# 设置配置属性
	ScriptUtil.init_class_static_value(ConfigKey, 
		func(script:GDScript, path, property: String):
			# 可绑定属性
			var property_item = BindPropertyItem.new(property)
			property_item.update( data_file.get_value(property) )
			property_item.bind_method(func(value):
				data_file.set_value(property, value)
			)
			bind_property_list.append(property_item)
			# 设置到这个脚本类中
			script.set(property, property_item)
	)


func _enter_tree() -> void:
	if Engine.get_main_loop().current_scene is Control:
		var font : Font = Engine.get_main_loop().current_scene.get_theme_default_font()
		ConfigKey.Display.font.update( font )
	Engine.get_main_loop().auto_accept_quit = false
	
	ConfigKey.Display.line_spacing.update(8)
	ConfigKey.Display.font_path.update("")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		data_file.save()
		JsonUtil.print_stringify(data_file.get_data())
		
		await Engine.get_main_loop().process_frame
		Engine.get_main_loop().quit.call_deferred(0)


func add_open_file(path) -> bool:
	var dict = ConfigKey.Path.opened_files.value()
	if not dict.has(path):
		dict[path] = null
		return true
	return false
