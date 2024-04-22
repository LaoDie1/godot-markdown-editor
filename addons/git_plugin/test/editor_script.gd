#============================================================
#    Editor Script
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 23:31:14
# - version: 4.2.1.stable
#============================================================
@tool
extends EditorScript


func _run() -> void:
	print( is_valid_file_path("addons/git_plugin/src/icon.tres") )


static func is_valid_file_path(path: String):
	return (not path.begins_with(" ") and FileAccess.file_exists(path))


func test02():
	var text : String = "娣诲姞鎻掍欢鍒扮紪杈戝櫒涓?"
	print( str(text.unicode_at(0)) )


func test01():
	var regex = RegEx.new()
	regex.compile(
		"((?<type>\\w+):\\s+)?"
		+ "("
		+ "(?<origin>.*?)\\s->\\s(?<current>.*)"  # 文件重命名或发生了移动
		+ "|(?<path>.*)" # 文件内容发生改动
		+ ")"
	)
	
	#var result = regex.search("renamed:    addons/git_plugin/src/panel/init_panel.gd -> addons/git_plugin/src/panel/init_panel/init_panel.gd")
	var result = regex.search("modified:   addons/git_plugin/src/panel/commit_panel/remotes.tscn")
	print("type: ", result.get_string("type"))
	
	print("origin: ", result.get_string("origin"))
	print("current: ", result.get_string("current"))
	
	print("path: ", result.get_string("path"))
	
	
	return
	
	

