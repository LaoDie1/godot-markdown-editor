#============================================================
#    One Process Executor
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-12 23:03:19
# - version: 4.0
#============================================================
## 一次帧执行器
##
##只在一帧内执行一次，多次执行只会在第一次执行，且返回值也是第一次执行的值
class_name OneProcessExecutor


enum {
	PROCESS,
	PHYSICS,
}


var _process_mode : int = PROCESS
var _callback : Dictionary = {} # 执行功能队列
var _result : Dictionary = {}


func _init(process_mode: int = PROCESS):
	self._process_mode = process_mode


##  执行功能
##[br]
##[br][code]callback[/code]  执行的功能回调
##[br][code]id[/code]  这个功能唯一ID，如果ID重复则不执行，默认为 null
func execute(callback: Callable, id = null):
	if not _callback.has(id):
		_callback[id] = callback
		_execute(id)
	return _result[id]


func _execute(id):
	# 执行
	_result[id] = Callable(_callback[id]).call()
	
	if _process_mode == PROCESS:
		await Engine.get_main_loop().process_frame
	else:
		await Engine.get_main_loop().physics_frame
	
	_callback.erase(id)
	_result.erase(id)

