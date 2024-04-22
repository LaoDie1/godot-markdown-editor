#============================================================
#    GlobalEvent
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-20 23:43:30
# - version: 4.0
#============================================================
## 全局事件（测试）
##
## 与信号同的是，这个是作为全局进行连接调用，且ID可以是任意值
##[br]示例
##[codeblock]
### 返回的 id 是一个取消监听的回调 id.call() 可以取消监听事件
##var id = GlobalEvent.listen("测试", func(params):
##    print("测试监听数据！ params = ", params)
##)
##[/codeblock]
##[br]发送数据
##[codeblock]
##GlobalEvent.send("测试", {value = 123456})
##[/codeblock]
class_name GlobalEvent


## 监听标识
enum {
	DEFAULT,	## 默认监听方式
	ONE_SHOT,	## 调用一次之后消失
	TIME,		## 时间结束后消失。需要传入 [float] 参数作为时间长度
	COUNTRE,	## 调用达到次数后消失。需要传入 [int] 参数作为调用次数
	UNTIL,		## 符合条件才执行。需要传入 [Callable] 参数。这个参数返回 [bool] 类型的值。这个在调用时进行判断，如果条件不符合则会消失
}

const _ListenClassMap : Dictionary = {
	DEFAULT: ListenExecutorBase,
	ONE_SHOT: ListenExecutor_OneShot,
	TIME: ListenExecutor_Time,
	COUNTRE: ListenExecutor_Counter,
	UNTIL: ListenExecutor_Until,
}



#============================================================
#  数据类
#============================================================
class ListenExecutorBase:
	## 默认基础的监听方式
	signal finished
	
	var callable : Callable
	
	func _init(callable: Callable, flag_param):
		self.callable = callable
	
	func execute(params):
		callable.call(params)


class ListenExecutor_OneShot:
	## 一次性的
	extends ListenExecutorBase
	
	func execute(params):
		callable.call(params)
		finished.emit()


class ListenExecutor_Time:
	## 有持续时间的
	extends ListenExecutorBase
	
	func _init(callable: Callable, param: float):
		super._init(callable, param)
		assert(param > 0, "时间不能少于 0！")
		Engine.get_main_loop() \
			.create_timer(param) \
			.timeout.connect( func(): self.finished.emit() )


class ListenExecutor_Counter:
	## 有最大次数的
	extends ListenExecutorBase
	
	var count : int = 0
	
	func _init(callable: Callable, param: int):
		super._init(callable, param)
		assert(param > 0, "数量必须超过 0！")
		self.count = param
	
	func execute(params):
		callable.call(params)
		count -= 1
		if count <= 0:
			finished.emit()


class ListenExecutor_Until:
	## 有执行条件的，直到不符合条件，则监听消失
	extends ListenExecutorBase
	
	var  condition : Callable
	
	func _init(callable: Callable, param: Callable):
		super._init(callable, param)
		assert(param.is_valid(), "回调必须是有效的！")
		self.condition = param
	
	func execute(params):
		if condition.call(params):
			callable.call(params)
		else:
			finished.emit()


#============================================================
#  SetGet
#============================================================
# 获取事件数据
static func _get_data() -> Dictionary:
	const KEY = &"Event_get_data_dict"
	if not Engine.has_meta(KEY):
		Engine.set_meta(KEY, {})
	return Engine.get_meta(KEY)


## 获取这个组的监听的回调列表
static func get_group_list(group) -> Array[ListenExecutorBase] :
	var data = _get_data()
	var list : Array[ListenExecutorBase] 
	if data.has(group):
		list = data[group]
	else:
		list = []
		data[group] = list
	return list


## 监听一个组
##[br]
##[br][code]group[/code]  监听的组
##[br][code]callable[/code]  这个组的回调，这个方法需要有一个参数
##[br] - params 接收方法参数数据
##[br][code]listen_flag[/code]  监听标识。监听方式
##[br][code]flag_params[/code]  监听标识所需参数。
##[br][code]return[/code]  返回取消连接的回调作为id
static func listen(
	group, 
	callable: Callable, 
	listen_flag: int = DEFAULT, 
	flag_params = null
) -> Callable:
	assert(_ListenClassMap.has(listen_flag), "错误的连接标识！")
	
	# 创建这个类型的对象
	var _class = _ListenClassMap[listen_flag]
	var item : ListenExecutorBase = _class.new(callable, flag_params)
	var list : Array[ListenExecutorBase] = get_group_list(group)
	list.append(item)
	
	var id : Callable = func(): 
		list.erase(item)
	item.finished.connect(id)
	return id


##  发送一个事件消息
##[br]
##[br][code]group[/code] 发送到的组
##[br][code]data[/code]  参数数据
static func send(group, data = null) -> void:
	var list : Array[ListenExecutorBase] = get_group_list(group)
	for listen_data in list:
		listen_data.execute(data)


## 取消这个组的所有监听
##[br]
##[br][code]return[/code] 返回移除的数量
static func cancel_all(group) -> int:
	var list = get_group_list(group)
	var count = list.size()
	list.clear()
	return count

