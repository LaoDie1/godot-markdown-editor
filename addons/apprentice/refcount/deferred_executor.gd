#============================================================
#    Deferred Executor
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-09 21:52:49
# - version: 4.0
#============================================================
## 队列执行器
##
##执行的回调方法会在当前帧结束时才开始执行，在此之前多次调用不会重复执行
class_name DeferredExecutor


var _callback : Dictionary = {} # 执行功能队列
var _executing = false


##  执行功能。功能都会在帧结束后统一执行
##[br]
##[br][code]callback[/code]  执行的功能回调
##[br][code]id[/code]  这个功能唯一ID，如果ID重复则不执行，默认为null
func execute(callback: Callable, id = null):
	if _callback.has(id):
		return
	_callback[id] = callback
	if _executing:
		return 
	_executing = true
	_execute.call_deferred()


func _execute():
	var list = _callback.values()
	_executing = false
	_callback.clear()
	
	for callback in list:
		callback.call()

