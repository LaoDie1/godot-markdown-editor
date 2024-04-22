#============================================================
#    Git Diff
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 22:46:39
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Diff


static func execute():
	var result = await GitPlugin_Executor.execute(["git", "diff"])
	return _handle_result(result["output"])


static var _regex_diff : RegEx:
	get:
		if _regex_diff == null:
			_regex_diff = RegEx.new()
			_regex_diff.compile("^diff --git a(?<a>.*?) b(?<b>.*?)")
		return _regex_diff

static func _handle_result(output: Array):
	var list = []
	var group = []
	for line:String in output:
		if _regex_diff.search(line) == null:
			group.append(line)
		else:
			if not group.is_empty():
				list.append(group)
			group = []
			group.append(line)
	# 分组
	if not group.is_empty():
		list.append(group)
	
	return list



## 比较文件的差异
static func diff_file(commit_id: String, file_path: String):
	var result = await GitPlugin_Executor.execute(["git", "diff", commit_id, file_path])
	
