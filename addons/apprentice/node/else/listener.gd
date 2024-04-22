#============================================================
#    Listener
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-11 21:58:43
# - version: 4.0
#============================================================
##  信号监听器
##[br]
##[br]根据优先级进行执行方法。主要可以用于随意切入信号的执行，在不同的信号执行的时机进行连接方法。
##[br]
##[br]比如默认连接一个 [code]attack[/code] 信号，如果我想在 [code]attack[/code] 执行默
##认的方法前判断是否以进行攻击，则可以连接时设置优先级比默认的 0 要小，然后在方法里进行判断，
##如果不能执行攻击方法，则调用 [method prevent_signal] 方法进行打断这个信号的执行
class_name Listener
extends Node


## 已监听信号
signal listened(id, _signal: Signal, method: Callable, priority: int)
## 已打断执行
signal prevented(id, _signal: Signal)


## 默认几个优先级级别
enum Priority {
	BEFORE = -10,  ## 在信号发出之前执行
	DEFAULT = 0, ## 默认信号发出时执行
	AFTER = 10, ## 在信号发出之后执行
}

# 连接时的 ID 对应断开这个方法的回调方法
var _connect_id_to_cancel_callback : Dictionary = {}
# 信号对应信号优先级的类数据
var _signal_to_priority : Dictionary = {}


#============================================================
#  信号优先级执行
#============================================================
class SignalPriority:
	## 已打断信号的执行
	signal prevented
	
	# 当前执行的唯一ID（自增的）
	var _execution_id : Array = [0]
	# 优先级对应的回调列表
	var _priority_to_callable : Dictionary = {}
	# 优先级值列表
	var _prioritys : Array[int] = []
	# 是否打断状态
	var _prevent_status : Dictionary = {}
	
	func _init(_signal: Signal):
		_SignalUtil.connect_array_arg_callable(_signal, func(params: Array):
			# 使用唯一ID判断打断状态，防止在回调方法里打断后再次调用这个信号
			_execution_id[0] += 1
			var id : int = _execution_id[0]
			_prevent_status[id] = false
			# 开始执行
			var list : Array[Callable]
			for priority in _prioritys:
				list = _priority_to_callable[priority]
				for method in list:
					if _prevent_status[id]:
						self.prevented.emit()
						return
					method.callv(params)
			_prevent_status.erase(id)
		)
	
	## 添加这个优先级的 [Callable]。返回移除这个 [Callable] 的回调
	func add(method: Callable, priority: int) -> Callable:
		if not _priority_to_callable.has(priority):
			_priority_to_callable[priority] = Array([], TYPE_CALLABLE, "", null)
			_prioritys.append(priority)
			_prioritys.sort()
		_priority_to_callable[priority].append(method)
		return func(): Array(_priority_to_callable[priority]).erase(method)
	
	## 打断执行
	func prevent() -> void:
		# 打断信号当前执行ID
		_prevent_status[_execution_id[0]] = true
		



#============================================================
#  信号工具
#============================================================

class _SignalUtil:
	
	const SIGNAL_CONN_CALLV = """extends RefCounted
# 参数
var {CALLABLE}: Callable
func {METHOD}({from_arg}):
	{CALLABLE}.call([{from_arg}])
"""
	
	const SIGNAL = "SIGNAL"
	const METHOD = "METHOD"
	const CALLABLE = "CALLABLE"
	
	## 获取这个值，如果没有执行回调并存为这个回调返回的值
	static func get_value_or_set(dict: Dictionary, key, not_exists_set: Callable):
		if dict.has(key) and not typeof(dict[key]) == TYPE_NIL:
			return dict[key]
		else:
			dict[key] = not_exists_set.call()
			return dict[key]
	
	## 获取元数据作为单例数据
	static func singleton_dict(meta_key: StringName, default: Dictionary = {}) -> Dictionary:
		if Engine.has_meta(meta_key):
			return Engine.get_meta(meta_key)
		else:
			Engine.set_meta(meta_key, default)
			return default
	
	## 引用目标对象，防止引用丢失而消失。用在 [RefCounted] 类型的对象
	##[br]
	##[br][code]object[/code] 要引用的对象
	##[br][code]depend[/code] 指定的依赖象。如果这个对象消失，则指定的引用对象也随之消失
	static func ref_target(object: RefCounted, depend: Object):
		const key = "_SignalUtil_ref_target_data"
		if depend.has_meta(key):
			var list = depend.get_meta(key) as Array
			list.append(object)
		else:
			var list = [object]
			depend.set_meta(key, list)
	
	## 获取信号参数的数量
	static func get_argument_num(_signal: Signal) -> int:
		var data : Dictionary = singleton_dict("_SignalUtil_get_argument_num")
		return get_value_or_set(data, _signal, func():
			# 获取这个信号的参数数量
			var signal_name = _signal.get_name()
			var object = _signal.get_object()
			for d in object.get_signal_list():
				if d['name'] == signal_name:
					var arg_num = d["args"].size()
					data[_signal] = arg_num
					return arg_num
			return 0
		)
	
	## 创建调用回调的 callv 方法的代理执行对象
	static func create_array_param_script(from_signal_arg_num: int) -> GDScript:
		var map_data : Dictionary = singleton_dict("_SignalUtil_create_array_param_script")
		return get_value_or_set(map_data, from_signal_arg_num, func():
			var script = GDScript.new()
			var code = SIGNAL_CONN_CALLV.format({
				"METHOD": METHOD,
				"CALLABLE": CALLABLE,
				"from_arg": ", ".join( range(from_signal_arg_num).map( func(i): return "arg" + str(i) ) ),
			})
			script.source_code = code
			script.reload()
			return script
		)
	
	##  连接到这个方法，参数转为数组作为单个参数调用方法。
	##[br]
	##[br][code]from_signal[/code]  连接的信号
	##[br][code]callable[/code]  信号连接到的方法回调，这个方法需要有个 [Array] 参数接收信号的参数列表
	static func connect_array_arg_callable(from_signal: Signal, callable: Callable) -> Callable:
		var from_arg_num = get_argument_num(from_signal)
		var script = create_array_param_script(from_arg_num)
		
		# 连接信号
		var proxy = script.new() as Object
		proxy[CALLABLE] = callable
		from_signal.connect(proxy[METHOD])
		
		# 引用对象，防止消失
		var from_signal_object : Object = from_signal.get_object() as Object
		ref_target(proxy, from_signal_object)
		
		return proxy[METHOD]



#============================================================
#  自定义
#============================================================
static func _generate_id(data_list: Array) -> StringName:
	var list = []
	for i in data_list:
		list.append(hash(i))
	return ",".join(list).sha1_text()


## 监听事件
##[br]
##[br][code]_signal[/code]  监听的信号
##[br][code]method[/code]  触发时执行的方法
##[br][code]priority[/code]  执行的方法的优先级
##[br][code]additional[/code]  额外的生成 ID 时的参数，连接同样的方法，但是可能连接不同的参数，而指定的额外参数
##[br][code]id[/code]  指定监听的ID，默认会自动生成
##[br][code]return[/code]  返回监听的 ID
func listen(
	_signal: Signal, 
	method: Callable, 
	priority: int = Priority.DEFAULT, 
	additional:Array=[], 
	id: StringName = &""
) -> StringName:
	if id == &"":
		additional.append_array([_signal, method, priority])
		id = _generate_id(additional)
	
	# 这个监听的管理对象
	var signal_priority : SignalPriority
	if _signal_to_priority.has(_signal):
		signal_priority = _signal_to_priority[_signal]
	else:
		signal_priority = SignalPriority.new(_signal)
		signal_priority.prevented.connect(func():
			self.prevented.emit(id, _signal)
		)
		_signal_to_priority[_signal] = signal_priority
	
	# 添加记录这个连接的方法
	if not _connect_id_to_cancel_callback.has(id):
		_connect_id_to_cancel_callback[id] = Array([], TYPE_CALLABLE, "", null)
	var remove_callback : Callable = signal_priority.add(method, priority)
	_connect_id_to_cancel_callback[id].append(remove_callback)
	
	self.listened.emit(id, _signal, method, priority)
	
	return id


## 是否有这个 ID
func has_id(id: StringName) -> bool:
	return _connect_id_to_cancel_callback.has(id)


## 取消监听
func cancel(id: StringName) -> void:
	assert(has_id(id), "没有这个连接")
	var remove_callbacks : Array[Callable] = _connect_id_to_cancel_callback[id]
	for remove_callback in remove_callbacks:
		remove_callback.call()
	_connect_id_to_cancel_callback.erase(id)


## 取消所有监听
func cancel_all() -> void:
	for id in _connect_id_to_cancel_callback:
		cancel(id)


## 打断执行
func prevent_signal(_signal: Signal) -> void:
	var signal_priority: SignalPriority = _signal_to_priority[_signal]
	signal_priority.prevent()

