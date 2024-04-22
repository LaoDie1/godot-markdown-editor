#============================================================
#    Auto Load Config
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-24 00:28:10
# - version: 4.0
#============================================================
## 自动加载配置
extends Node


const CONFIG_PATH = "res://auto_config"


func _ready():
	# 扫描配置路径，加载配置
	if DirAccess.dir_exists_absolute(CONFIG_PATH):
		var files = DirAccess.get_files_at(CONFIG_PATH)
		for file in files:
			var path = CONFIG_PATH.path_join(file)
			var script = load(path)
			if script is GDScript:
				var list = ScriptUtil.get_extends_link(script)
				if list.has((AutoConfig as GDScript).resource_path):
					var object = script.new() as AutoConfig
					object._config()
					add_child(object)
