#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:53:36
# - version: 4.3.0.dev5
#============================================================
## 配置
extends Node


var data_file : DataFile = DataFile.instance(
	OS.get_config_dir().path_join("Godot/Markdown Editor/.config.data"),
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
	_init_config()

func _enter_tree() -> void:
	if Engine.get_main_loop().current_scene is Control:
		font = Engine.get_main_loop().current_scene.get_theme_default_font()

func _exit_tree() -> void:
	print("exit")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_update_config()
		data_file.save()
		Engine.get_main_loop().quit.call_deferred(0)



#============================================================
#  自定义
#============================================================
var _config_propertys : Array = [
	"top_font_size", "font_size", "accent_color", "text_color", "line_spacing",
]

func _init_config():
	var propertys = DataUtil.array_to_dictionary( ScriptUtil.get_property_name_list(get_script()) )
	
	for property in _config_propertys:
		if data_file.has_value(property):
			self[property] = data_file.get_value(property)
	opened_file_paths = get_opened_files()


func _update_config():
	set_value(ConfigKey.Path.opened_files, opened_file_paths)
	for property in _config_propertys:
		data_file.set_value(property, self[property])


func get_value(path: String, default = null):
	return data_file.get_value(path, default)


func set_value(path: String, value):
	data_file.set_value(path, value)


func add_opened_file(file_path: String) -> bool:
	if not opened_file_paths.has(file_path):
		opened_file_paths.append(file_path)
		set_value(ConfigKey.Path.opened_files, opened_file_paths)
		return true
	return false


func get_opened_files() -> Array:
	return get_value(ConfigKey.Path.opened_files, [])

