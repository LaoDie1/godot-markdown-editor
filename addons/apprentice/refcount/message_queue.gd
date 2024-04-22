#============================================================
#    Message Queue
#============================================================
# - datetime: 2023-02-08 13:21:40
#============================================================
## 消息队列
##
##创建一个 [code]chat[/code] 队列的消息，并创建监听器处理消息内容：
##[codeblock]
##var producer := MessageQueue.create_producer("chat")
#### 监听器处理消息内容
##var monitor := MessageQueue.create_monitor("chat", 
##    func(message):
##        print("获取消息：", message)
##,  MessageQueue.DEFAULT_CHANNEL, MessageQueue.Process.TIMER, 1
##)
##[/codeblock]
##[br]调用 [code]producer[/code] 对象的 [method MessageQueue.Producer.send_message] 方法进行发送消息
##[codeblock]
##producer.send_message("一条消息内容")
##producer.send_message(Node.new())
##producer.send_message({"action": "move_to", "pos": Vector(100, 100)})
##[/codeblock]
##[br]或接调用 [MessageQueue] 类的 [method MessageQueue.send_message] 方法进行发送数据，调用 
##[method MessageQueue.get_message] 进行获取数据
class_name MessageQueue


## 线程执行类型
enum Process {
	## _physics_process 线程类型
	PHYSICS = Timer.TIMER_PROCESS_PHYSICS,
	## _process 线程型
	IDLE = Timer.TIMER_PROCESS_IDLE,  
	## 计时器间隔时间执行
	TIMER = 2,
}

enum {
	## 默认消息通道
	DEFAULT_CHANNEL = 0
}


## 消息队列
class DataQueue:
	var message_data = {}
	var id_point_map = {}
	
	# 消息所在位置
	var p : int = 0
	# 最大指针位置，最大消息容量
	var max_p : int = 0x7FFFFFFFFFFFFFFF
	
	func _init(max_count: int = 600):
		self.max_p = max_count
	
	func add_message(message) -> void:
		if message == null:
			push_warning("不能添加 null 数据")
			return 
		
		message_data[p] = message
		if message_data.size() >= max_p:
			# 丢弃之前的消息
			message_data.erase(p - max_p)
		p += 1
	
	# 获取这个 id 上一次所在的消息位置
	func get_last_point(id) -> int:
		return id_point_map.get(id, 0)
	
	# 是否这个 id 指针没有到达最新的位置
	func has_data(id) -> bool:
		return get_last_point(id) < p
	
	# 获取这个id的消息队列，如果消息已经获取完，则会返回 null
	func get_data(id):
		var id_p = get_last_point(id)
		if id_p < p:
			var message = message_data.get(id_p)
			id_p += 1
			id_point_map[id] = id_p
			return message
		return null


## 消息数据库
class MessageDatabase:
	extends Object
	
	var _connect_data : Dictionary = {}
	
	func get_message_queue(queue_name) -> DataQueue:
		if _connect_data.has(queue_name):
			return _connect_data[queue_name] as DataQueue
		else:
			_connect_data[queue_name] = DataQueue.new()
			return _connect_data[queue_name] as DataQueue
	
	func has_message(queue_name, channel) -> bool:
		return get_message_queue(queue_name).has_data(channel)
	
	func get_message(queue_name, channel):
		var queue = get_message_queue(queue_name)
		return queue.get_data(channel)
	
	func send_message(queue_name, message) -> void:
		get_message_queue(queue_name).add_message(message)


## 消息生产者
class Producer:
	var _message_database : MessageDatabase
	var _queue_name
	
	func _init(database: MessageDatabase, queue_name):
		self._message_database = database
		self._queue_name = queue_name
	
	func send_message(message) -> void:
		_message_database.send_message(_queue_name, message)


## 消息消费者
class Consumer:
	var _message_database : MessageDatabase
	var _queue_name
	var _channel : int
	
	static func create_new_channel():
		# 用数组的方式是因为可以引用数据，通过索引进行修改
		const key = "MessageMonitor_Consumer_init_channels"
		var channels : Array
		if Engine.has_meta(key):
			return Engine.get_meta(key)
		else:
			channels = [0]
			Engine.set_meta(key, channels)
		channels[0] += 1
		return channels[0]
	
	func _init(database: MessageDatabase, queue_name, channel : int = -1):
		self._message_database = database
		self._queue_name = queue_name
		self._channel = (
			channel
			if channel != -1
			else create_new_channel()
		)
	
	# 是否有新消息
	func has_message() -> bool:
		return _message_database.has_message(_queue_name, _channel)
	
	# 获取消息
	func get_message():
		return _message_database.get_message(_queue_name, _channel)


##  消息监听器，自动进行监听是否有消息，并行消费
class Monitor:
	extends Object
	
	var _process_signal: Signal
	var _callback : Callable
	var _timer : Timer
	
	func _init( database: MessageDatabase, 
		queue_name, 
		callback: Callable, 
		channel : int = DEFAULT_CHANNEL,
		process_type : int = Process.IDLE,
		interval: int = 0.1
	):
		var consumer = Consumer.new(database, queue_name, channel)
		_callback = (func():
			# 如果有消息就立马进行消费处理
			if consumer.has_message():
				callback.call(consumer.get_message())
		)
		
		# 连接线程
		if process_type == Process.IDLE or process_type == Process.PHYSICS:
			self._process_signal = (
				Engine.get_main_loop().process_frame
				if process_type == Timer.TIMER_PROCESS_IDLE
				else Engine.get_main_loop().physics_frame
			)
		elif process_type == Process.TIMER:
			var timer = Timer.new()
			timer.wait_time = interval
			timer.autostart = true
			timer.one_shot = false
			self._process_signal = timer.timeout
			if Engine.get_main_loop():
				Engine.get_main_loop().root.add_child.call_deferred(timer)
			else:
				# 如果刚启动游戏，还没加载出主线程，则延迟添加节点
				(func():
					Engine.get_main_loop().root.add_child.call_deferred(timer)
				).call_deferred()
			
			if timer.is_inside_tree():
				timer.start()
			self._timer = timer
		
		self._process_signal.connect(_callback)
	
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			# 这个对象被删除时将会断开这个方法的执行
			_process_signal.disconnect(_callback)
			if is_instance_valid(_timer):
				_timer.queue_free()
	


#============================================================
#  自定义
#============================================================
static func _get_database() -> MessageDatabase:
	const key = "MessageMonitor_get_database_dict"
	if Engine.has_meta(key):
		return Engine.get_meta(key) as MessageDatabase
	else:
		var database = MessageDatabase.new()
		Engine.set_meta(key, database)
		return database 

## 发送消息，消息数据可以是任何类型的
static func send_message(queue_name, message) -> void:
	_get_database().send_message(queue_name, message)

## 获取消息
static func get_message(queue_name, channel = 0):
	return _get_database().get_message(queue_name, channel)

## 是否有消息
static func has_message(queue_name, channel = 0) -> bool:
	return _get_database().has_message(queue_name, channel)

## 创建消息生产者
static func create_producer(queue_name) -> Producer:
	return Producer.new(_get_database(), queue_name)

## 创建消息消费者
static func create_consumer(queue_name) -> Consumer:
	return Consumer.new(_get_database(), queue_name)

## 创建消息监听器
##[br]
##[br][code]queue_name[/code]  队列名称
##[br][code]callable[/code]  获取到消息时的回调方法，这个方法需要一个参数用于接收消息内容
##[br][code]channel[/code]  监听器的 channel，如果有多个相同 channel 的监听器，则会同时对消息队列进行消费
##[br][code]process_type[/code]  线程处理类型
##[br][code]interval[/code]  如果 process_type 参数值为 [member MessageQueue.Process.TIMER]，则设置这个计时器间隔进行消费的时间
static func create_monitor(
	queue_name, 
	callable: Callable, 
	channel : int = DEFAULT_CHANNEL,
	process_type : int = Process.IDLE,
	interval: int = 0.1
) -> Monitor:
	return Monitor.new( _get_database(), queue_name, callable, channel, process_type, interval )

