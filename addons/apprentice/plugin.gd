#============================================================
#    Plugin
#============================================================
# - datetime: 2022-08-28 23:28:30
#============================================================
@tool
extends EditorPlugin


const AutoLoadConfigClass = preload("config/auto_config.gd")


var __added_type := {}


func _enter_tree() -> void:
	add_autoload_singleton("AutoLoadConfig", "res://addons/apprentice/config/auto_load_config.gd")
	# Autoload 脚本
	var autoload_path = get_script().resource_path.get_base_dir().path_join("autoload")
	var autoload_dir = DirAccess.open(autoload_path)
	var autoload_names = []
	for file in autoload_dir.get_files():
		if file.get_extension() == "gd":
			var autoload_name : String = file.get_file() \
				.get_basename() \
				.to_pascal_case()
			add_autoload_singleton(autoload_name, autoload_path.path_join(file))
			autoload_names.append(autoload_name)
	
	tree_exiting.connect(func():
		for autoload_name in autoload_names:
			remove_autoload_singleton(autoload_name)
	)
	
	# 自定义 Config 脚本
	var current_path =  get_script().resource_path.get_base_dir() as String
	if not DirAccess.dir_exists_absolute(AutoLoadConfigClass.CONFIG_PATH):
		DirAccess.make_dir_recursive_absolute(AutoLoadConfigClass.CONFIG_PATH)
		get_editor_interface().get_resource_filesystem().scan()
		
		var to = AutoLoadConfigClass.CONFIG_PATH.path_join("example_config.gd")
		DirAccess.copy_absolute(current_path.path_join("config/example_config.gd"), to)


func _exit_tree() -> void:
	remove_autoload_singleton("AutoLoadConfig")
