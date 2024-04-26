#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:53:36
# - version: 4.3.0.dev5
#============================================================
extends Node


var config_file_path : String = OS.get_config_dir().path_join("Godot/.markdown_editor_config.cfg")
var config_file : ConfigFile = ConfigFile.new()
var data_file : DataFile = DataFile.instance(
	OS.get_config_dir().path_join("Godot/Markdown Editor/.config.cfg"),
	DataFile.BYTES, 
	{
		
	}
)

var font : Font
var top_font_size : int = 14
var font_size : int = 18
var accent_color : Color = Color(0.7578, 0.5261, 0.2944, 1)
var text_color : Color = Color(0,0,0,0.8)
var line_spacing : float = 2

var opened_file_paths : Array = []


#============================================================
#  内置
#============================================================
func _init():
	ScriptUtil.init_class_static_value(ConfigKey, true)
	Engine.get_main_loop().auto_accept_quit = false
	
	var path : String = config_file_path
	if FileAccess.file_exists(path):
		var err = config_file.load(path)
		if err == OK:
			_init_config()
			
		else:
			push_error( "Error opening configuration file: ", error_string(err) )
	else:
		print("没有配置文件")

func _enter_tree() -> void:
	if Engine.get_main_loop().current_scene is Control:
		font = Engine.get_main_loop().current_scene.get_theme_default_font()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_update_config()
		var err = config_file.save(config_file_path)
		if err != OK:
			push_error( "Error saving configuration file: ", error_string(err) )
		else:
			print("已保存配置文件：", config_file_path)
		Engine.get_main_loop().quit.call_deferred(0)



#============================================================
#  自定义
#============================================================
var _config_propertys : Array = [
	"top_font_size", "font_size", "accent_color", "text_color", "line_spacing",
]

func _init_config():
	#print( config_file.encode_to_text() )
	opened_file_paths = get_opened_files()
	for property in _config_propertys:
		if config_file.has_section_key("", property):
			self[property] = config_file.get_value("", property)


func _update_config():
	set_value(ConfigKey.Path.opened_files, opened_file_paths)
	for property in _config_propertys:
		config_file.set_value("", property, self[property])


func get_value(path: String, default = null):
	if path.begins_with("/"):
		path = path.substr(1)
	var values = path.split("/")
	return config_file.get_value(values[0], values[1], default)


func set_value(path: String, value):
	if path.begins_with("/"):
		path = path.substr(1)
	var values = path.split("/")
	config_file.set_value(values[0], values[1], value)


func add_opened_file(file_path: String) -> bool:
	if not opened_file_paths.has(file_path):
		opened_file_paths.append(file_path)
		set_value(ConfigKey.Path.opened_files, opened_file_paths)
		return true
	return false

func get_opened_files() -> Array:
	return get_value(ConfigKey.Path.opened_files, [])

