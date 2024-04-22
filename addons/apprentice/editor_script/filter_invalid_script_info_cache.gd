#============================================================
#    Filter invalid script info cache
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-22 23:43:28
# - version: 4.0
#============================================================
## 过滤掉无效的脚本缓存数据，防止添加节点时控制台输出 
##[br][code]Condition "inherits.is_empty()" is true.[code]
##[br]之类的信息。执行完需要重新启动编辑器
@tool
extends EditorScript


func _run():
	
	var path = "res://.godot/global_script_class_cache.cfg"
	
	var string = FileUtil.read_as_string(path) as String
	string = string.right(string.length() - 5)
	if string:
		var list : Array[Dictionary] = str_to_var(string)
		
		# 过滤掉失效的脚本
		var script_path : String
		var exists : Array[Dictionary]
		print("[ %s ] 失效的脚本信息：" % ScriptUtil.get_object_script_path(self).get_file() )
		for info in list:
			script_path = info['path']
			if FileAccess.file_exists(script_path):
				exists.append(info)
			else:
				print("  >> clear: ", info)
		print("=".repeat(70))
		FileUtil.write_as_string(path, "list=" + var_to_str(exists))
		print("[ %s ] 执行完成，需要重启编辑器生效" % ScriptUtil.get_object_script_path(self).get_file() )
	else:
		print("没有读取到文本")
	

