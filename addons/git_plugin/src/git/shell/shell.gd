#============================================================
#    Shell Program
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 12:53:05
# - version: 4.2.1.stable
#============================================================
## 执行命令操作
class_name GitPlugin_Shell


## 请求执行完成
signal request_finished(id: int, command: Array, result: Dictionary)


## 执行功能
func execute(id, command: Array):
	var origin = command.duplicate()
	var result = _execute(command)
	request_finished.emit(id, origin, result)


func _execute(command: Array) -> Dictionary:
	assert(false, "必须重写")
	return {}

