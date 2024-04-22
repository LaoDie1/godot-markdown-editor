#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:53:36
# - version: 4.3.0.dev5
#============================================================
extends Node


@onready var font : Font = Engine.get_main_loop().current_scene.get_theme_default_font()


var top_font_size : int = 14
var font_size : int = 18
var accent_color : Color = Color(0.7578, 0.5261, 0.2944, 1)
var text_color : Color = Color(0,0,0,0.8)
var line_spacing : float = 2

var config_file_path : String:
	get: 
		return OS.get_cache_dir().path_join("Godot/.markdown_editor_config.cfg")
var config_file : ConfigFile = ConfigFile.new()


#============================================================
#  内置
#============================================================
func _init():
	init_class_static_value(ConfigKey, true)
	Engine.get_main_loop().auto_accept_quit = false


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var err = config_file.save(config_file_path)
		if err != OK:
			push_error( "Error saving configuration file: ", error_string(err) )
		else:
			print("已保存配置文件：", config_file_path)
		Engine.get_main_loop().quit.call_deferred(0)


func _enter_tree():
	var path : String = config_file_path
	if FileAccess.file_exists(path):
		var err = config_file.load(path)
		if err != OK:
			push_error( "Error opening configuration file: ", error_string(err) )
	else:
		print("没有配置文件")



#============================================================
#  自定义
#============================================================
func init_class_static_value(script: GDScript, is_path_key: bool):
	var class_regex = RegEx.new()
	class_regex.compile("^class\\s+(?<class_name>\\w+)\\s*:")
	var var_regex = RegEx.new()
	var_regex.compile("static\\s+var\\s+(?<var_name>\\w+)")
	
	# 分析
	var p_name = script.new()
	var data : Dictionary = {}
	var last_class : String = ""
	var last_var_list : Array
	var lines = script.source_code.split("\n")
	var result : RegExMatch
	for line in lines:
		result = class_regex.search(line)
		if result:
			# 类名
			last_class = result.get_string("class_name")
			last_var_list =[]
			data[last_class] = last_var_list
		else:
			# 变量名
			result = var_regex.search(line)
			if result:
				var var_name = result.get_string("var_name")
				if last_class != "":
					last_var_list.append(var_name)
				else:
					p_name.set(var_name, var_name.to_lower())
	
	# 设置值
	var const_map = script.get_script_constant_map()
	var object : Object
	for c_name:String in data:
		object = const_map[c_name].new()
		var property_list = data[c_name]
		for property:String in property_list:
			if is_path_key:
				object[property] = StringName("/" + c_name.to_lower() + "/" + property.to_lower())
			else:
				object[property] = StringName(property.to_lower())


func get_value(path: String, default = null):
	if path.begins_with("/"):
		path = path.substr(1)
	var values = path.split("/")
	return config_file.get_value(values[0], values[1], default)


func set_value(path: String, value):
	if path.begins_with("/"):
		path = path.substr(1)
	print("<修改配置> ", path, ": ", value)
	var values = path.split("/")
	config_file.set_value(values[0], values[1], value)
