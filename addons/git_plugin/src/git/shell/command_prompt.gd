#============================================================
#    Command Prompt
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 12:56:11
# - version: 4.2.1.stable
#============================================================
# Windows CMD
extends GitPlugin_Shell


func _execute(command: Array):
	var c = ["/C"]
	c.append_array(command)
	var output = []
	var error = OS.execute("CMD.exe", c, output, true)
	return {
		"error": error,
		"output": output,
	}
