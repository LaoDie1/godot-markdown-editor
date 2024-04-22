#============================================================
#    Executor
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 13:09:01
# - version: 4.2.1.stable
#============================================================
# 接收用户命令，进行异步处理
# 这个节点不能是 Node 类型，否则添加到场景后，异步功能不能使用
class_name GitPlugin_Executor
extends RefCounted


const CommandPrompt = preload("shell/command_prompt.gd")
const Terminal = preload("shell/terminal.gd")


static var instance : GitPlugin_Executor:
	get:
		if instance == null:
			instance = GitPlugin_Executor.new()
		return instance

static var _incr_id : int = 0

# 使用命令请求后的结果
var _id_to_request_result_cache : Dictionary = {}

var thread: Thread
var shell : GitPlugin_Shell


#============================================================
#  内置
#============================================================
func _init() -> void:
	match OS.get_name():
		"Linux", "macOS":
			shell = Terminal.new()
		"Windows":
			shell = CommandPrompt.new()
		_:
			assert(false, "不支持这个平台：" + OS.get_name())
	
	# 命令处理完成
	shell.request_finished.connect(_on_shell_request_finish, Object.CONNECT_DEFERRED)



#============================================================
#  自定义
#============================================================
# 执行命令，返回数据结果的 ID。
func _exec_command(command: Array) -> int:
	if thread != null:
		thread.wait_to_finish()
	thread = Thread.new()
	# 执行 shell 命令
	_incr_id += 1
	thread.start(shell.execute.bind(_incr_id, command))
	return _incr_id


##[kbd]command[/kbd]  执行命令
##[br][kbd]max_wait_time[/kbd]  最大等待时间，超过这个时间则返回空数据
##[br][kbd]enable_handle[/kbd]  允许进行数据处理
static func execute(command: Array, max_wait_time: float = 30.0, enable_handle: bool = true) -> Dictionary:
	print("=".repeat(60))
	print_debug(" >>> 执行命令: ", " ".join(command) )
	print()
	
	var id = instance._exec_command(command.duplicate(true))
	var result = await instance.get_request_result(id, max_wait_time)
	if result:
		# 处理执行结果
		var data : Dictionary = {}
		data["error"] = result["error"]
		var output = result["output"][0].strip_edges(false, true)
		if output == "":
			data["output"] = []
		else:
			if enable_handle:
				# FIXME 修复中文乱码
				data["output"] = output.split("\n") # 切分为行
			else:
				data["output"] = [output]
		return data
		
	else:
		return {
			"error": ERR_INVALID_DATA,
			"output": []
		}


## 获取这个ID请求的结果，超时返回 [code]null[/code]
func get_request_result(id: int, max_wait_time: float) -> Variant:
	max_wait_time = int(max(0.001, max_wait_time) * 1000)
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < max_wait_time:
		await Engine.get_main_loop().process_frame
		if _id_to_request_result_cache.has(id):
			var result = _id_to_request_result_cache[id]
			_id_to_request_result_cache.erase(id) # 请求到结果，清除结果缓存
			return result
	return null


#============================================================
#  连接信号
#============================================================
func _on_shell_request_finish(id: int, command: Array, result: Dictionary):
	print_debug(" <<< 执行结束: ", " ".join(command), "")
	print()
	
	self._id_to_request_result_cache[id] = result
	
	var error = result["error"]
	if error != OK:
		printerr("执行失败：", 
			error, " ", error_string(error), " ", 
			str(result["output"][0]).strip_edges() 
		)
	
	if self.thread != null:
		self.thread.wait_to_finish()
		self.thread = null

