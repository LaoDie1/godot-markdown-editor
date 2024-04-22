#============================================================
#    Terminal
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 12:56:04
# - version: 4.2.1.stable
#============================================================
# Linux / MacOS 平台
extends GitPlugin_Shell

var _regex = RegEx.new()

func _init():
	_regex.compile("^\\s*git(?<else>\\s\\S+)")


func _execute(command):
	# 获取 git 
	var h = command[0]
	var re = _regex.search(h)
	if re:
		h = "git"
		command[0] = re.get_string("else")
	else:
		command[0] = ""
	
	# 执行
	var output = []
	var error = OS.execute(h, command, output, true)
	return {
		"error": error,
		"output": output,
	}
