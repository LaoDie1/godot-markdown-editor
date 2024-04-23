#============================================================
#    Func Util
#============================================================
# - datetime: 2022-12-08 23:25:09
# - version: 4.x
#============================================================
## 执行回调方法工具类
##
##这个工具类可以通过调用执行 execute 开头的方法以方便的执行一些比较另类的操作。
##[br]
##[br]比如控制节点向目标移动一小段距离：
##[codeblock]
##var duration = 1.0
##var speed = 50.0
##FuncUtil.execute_fragment_process(duration, func():
##    var dir = Node2D.global_position.direction_to(target.global_position)
##    Node2D.global_position += dir * speed * get_physics_process_delta_time()
##, Node2D)
##[/codeblock]
class_name FuncUtil


class BaseExecutor extends Timer:
	var _finished_callable := Callable()
	
	func _add_to_scene(to: Node = null):
		if to == null or not is_instance_valid(to):
			to = Engine.get_main_loop().current_scene
		to.add_child(self)
	
	func _finished():
		if _finished_callable.is_valid():
			_finished_callable.call()
	
	# 设置完成回调
	func set_finish_callback(callback: Callable):
		_finished_callable = callback
		return self
	
	func _exit_tree():
		if is_instance_valid(self):
			queue_free()
	
	# 直接清除
	func kill():
		stop()
		queue_free()
	
	func add_to(node: Node) -> BaseExecutor:
		return self


#============================================================
#  执行对象
#============================================================
# 普通的按照线程执行的对象
class ExecutorObject extends BaseExecutor:
	
	var _finish : bool = false
	var _condition : Callable = func(): return true
	var _callable : Callable
	
	func _init(callback: Callable, process_callback):
		_callable = callback
		# 时间结束调用完成删除自身
		self.timeout.connect(_finished, Object.CONNECT_ONE_SHOT)
		self.process_callback = process_callback
	
	func _ready():
		self.start()
		self.set_process(process_callback == Timer.TIMER_PROCESS_IDLE)
		self.set_physics_process(process_callback == Timer.TIMER_PROCESS_PHYSICS)
	
	func _process(delta):
		if ( 
			_condition.call() 
			and is_instance_valid(_callable.get_object())
		):
			_callable.call()
		else:
			queue_free()

	func _physics_process(delta):
		if (
			_condition.call() 
			and is_instance_valid(_callable.get_object())
		):
			_callable.call()
		else:
			queue_free()
	
	func _finished():
		super._finished()
		_finish = true
		self.queue_free()
		set_physics_process(false)
		set_process(false)
	
	## 设置执行完成时调用的方法
	func set_finish_callback(callback: Callable) -> ExecutorObject:
		super.set_finish_callback(callback)
		return self
	
	## 设置执行时中断并结束的条件
	func set_finish_condition(condition: Callable) -> ExecutorObject:
		_condition = condition
		return self


#============================================================
#  一次性回调
#============================================================
class _OnceTimer extends BaseExecutor:
	var _callable: Callable
	
	func _init(callback: Callable, delay_time: float, over_time: float):
		_callable = callback
		self.timeout.connect(_finished)
		self.one_shot = true
		self.ready.connect(func():
			if delay_time > 0:
				await Engine.get_main_loop().create_timer(delay_time).timeout
			callback.call()
			if over_time > 0:
				self.wait_time = over_time
				self.start(over_time)
			else:
				self.timeout.emit()
		, Object.CONNECT_ONE_SHOT)
	
	func _finished():
		super._finished()
		self.queue_free()
	


#============================================================
#  间隔执行计时器
#============================================================
class _IntermittentTimer extends BaseExecutor:
	
	var _amount_left : int = 0
	var _max_count: int = 0
	var _callable : Callable
	
	## 剩余数量
	func get_amount_left() -> int:
		return _amount_left
	
	## 获取最大次数
	func get_max_amount() -> int:
		return _max_count
	
	func _init(callback: Callable, max_count: int) -> void:
		assert(max_count > 0, "最大执行次数必须超过0！")
		_max_count = max_count
		_amount_left = max_count
		_callable = callback
		self.timeout.connect(func():
			callback.call()
			if _amount_left > 1:
				_amount_left -= 1
			else:
				self.stop()
				_finished()
				self.queue_free()
		)
	
	## 执行结束调用这个回调
	func set_finish_callback(callback: Callable) -> _IntermittentTimer:
		_finished_callable = callback
		return self


#============================================================
#  列表时间间隔执行计时器
#============================================================
class _IntermittentListTimer extends BaseExecutor:
	var _list = []
	var _callable : Callable = Callable()
	var _executed_callable: Callable = Callable()
	var _time : float
	
	func _init(list: PackedFloat64Array, callback: Callable):
		_list = list
		_list.reverse()
		_callable = callback
		self.timeout.connect(func():
			if not _callable.is_null():
				_callable.call()
			if not _executed_callable.is_null():
				_executed_callable.call(_time)
			self._next()
		)
	
	func _enter_tree():
		_next()
	
	func _next() -> void:
		if _list.size() == 0:
			_finished()
			self.queue_free()
			return
		
		_time = _list.pop_back()
		if _time == 0:
			self.timeout.emit()
		else:
			self.start(_time)
	
	# 每个时间执行结束之后，调用这个方法，这个方法需要有一个 [float] 参数接收这次结束的时间的值
	func executed(callback: Callable) -> _IntermittentListTimer:
		_executed_callable = callback
		return self
	
	## 完全执行结束调用这个回调
	func set_finish_callback(callback: Callable) -> _IntermittentListTimer:
		super.set_finish_callback(callback)
		return self
	


#============================================================
#  自定义
#============================================================
## 执行一个片段线程
##[br]
##[br][code]duration[/code]  持续时间
##[br][code]callback[/code]  每帧执行的回调方法，这个方法无需参数和返回值
##[br][code]params[/code]  传入方法的参数值
##[br][code]process_callback[/code]  线程类型：0 physics 线程 [constant Timer.TIMER_PROCESS_PHYSICS]
##，1 普通 process 线程 [constant Timer.TIMER_PROCESS_IDLE]
##[br][code]to_node[/code]  执行这个功能的节点依附于这个节点。建议传入这个参数，否则如果
##callback 参数中处理的对象如果是无效的，会导致游戏闪退。
##[br]
##[br][code]return[/code]  返回执行对象
static func execute_fragment_process(
	duration: float,
	callback: Callable, 
	process_callback : int = Timer.TIMER_PROCESS_PHYSICS,
	to_node: Node = null
) -> ExecutorObject:
	var timer := ExecutorObject.new(callback, process_callback)
	timer.wait_time = duration
	if not is_instance_valid(to_node):
		timer._add_to_scene()
	else:
		to_node.add_child(timer)
	return timer


##  间歇性执行
##[br]
##[br][code]interval[/code]  间隔执行时间
##[br][code]count[/code]  执行次数
##[br][code]callback[/code]  回调方法
##[br][code]immediate_execute_first[/code]  立即执行第一个
##[br][code]to_node[/code]  执行这个功能的节点依附于这个节点。建议传入这个参数，否则如果
##callback 参数中处理的对象如果是无效的，会导致游戏闪退。
##[br]
##[br][code]return[/code]  返回执行的计时器
static func execute_intermittent(
	interval: float, 
	count: int, 
	callback: Callable,
	immediate_execute_first: bool = false, 
	process_callback : int = Timer.TIMER_PROCESS_PHYSICS,
	to_node: Node = null
) -> _IntermittentTimer:
	if immediate_execute_first:
		count -= 1
	var timer := _IntermittentTimer.new(callback, count)
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = true
	timer.process_callback = process_callback
	if to_node == null:
		if callback.get_object() is Node:
			to_node == callback.get_object()
	timer._add_to_scene(to_node)
	if interval > 0:
		if immediate_execute_first:
			timer.timeout.emit()
	else:
		for i in count:
			timer.timeout.emit()
	return timer


##  根据传入的时间列表间歇执行
##[br]
##[br][code]interval_list[/code]  时间列表
##[br][code]callback[/code]  回调方法
##[br][code]return[/code]  返回间歇执行计时器对象
static func execute_intermittent_by_list(
	interval_list: PackedFloat64Array, 
	callback: Callable = Callable()
) -> _IntermittentListTimer:
	var timer =  _IntermittentListTimer.new(interval_list, callback)
	timer.one_shot = true
	timer.autostart = false
	timer._add_to_scene()
	return timer


## 没别的，仅仅调用一下这个回调。
##[br]
##[br][code]callback[/code]  回调方法
static func execute(callback: Callable):
	return callback.call()

## 延迟调用
static func execute_deferred(callback: Callable):
	callback.call_deferred()

## 等待一帧执行
static func execute_process_frame(callback: Callable):
	Engine.get_main_loop().process_frame.connect(callback, Object.CONNECT_ONE_SHOT)

static func execute_physics_frame(callback: Callable):
	Engine.get_main_loop().physics_frame.connect(callback, Object.CONNECT_ONE_SHOT)


## 节点在场景中时信号才连接调用一次这个 [Callable]，如果节点已经在场景中，则直接调用 [Callable] 方法
##[br]
##[br][code]_signal[/code]  信号
##[br][code]callback[/code]  回调方法
static func execute_once(_signal: Signal, callback: Callable):
	_signal.connect(callback, Object.CONNECT_ONE_SHOT)


## 如果这个节点在场景时则直接调用这个方法，否则在节点发出 [signal Node.tree_entered] 信号后调用这个方法。
## 如果 callable 方法是 [Node] 类型节点下的方法则可以不用传入 node 参数，会自动获取这个 [Callable]
## 方法的实际对象，否则需要传入 node 参数值
static func on_enter_tree(callback: Callable, node: Node = null):
	if node == null:
		assert(callback.get_object() is Node, "node 参数为 null 时，callable 方法源对象必须是 Node 类型")
		node = callback.get_object()
	
	if node.is_inside_tree():
		callback.call()
	else:
		if node.tree_entered.is_connected(callback):
			return 0
		node.tree_entered.connect(callback, Object.CONNECT_ONE_SHOT)
	return OK

## 如果这个节点在场景时则直接调用这个方法，否则在节点发出 [signal Node.tree_exiting] 信号后调用这个方法。
static func on_exit_tree(callback: Callable, node: Node = null) -> Error:
	if node == null:
		assert(callback.get_object() is Node, "node 参数为 null 时，callable 方法源对象必须是 Node 类型")
		node = callback.get_object()
	
	if not node.is_inside_tree():
		callback.call()
	else:
		if node.tree_exiting.is_connected(callback):
			return FAILED
		node.tree_exiting.connect(callback, Object.CONNECT_ONE_SHOT)
	return OK

## 如果这个节点在场景时则直接调用这个方法，否则在节点发出 [signal Node.ready] 信号后调用这个方法。
## 如果 callable 方法是 [Node] 类型节点下的方法则可以不用传入 node 参数，会自动获取这个 [Callable]
## 方法的实际对象，否则需要传入 node 参数值
static func on_ready(callback: Callable, node: Node = null) -> Error:
	if node == null:
		assert(callback.get_object() is Node, "node 参数为 null 时，callable 方法源对象必须是 Node 类型")
		node = callback.get_object()
	if node.is_inside_tree():
		callback.call()
	else:
		if node.ready.is_connected(callback):
			return FAILED
		node.ready.connect(callback, Object.CONNECT_ONE_SHOT)
	return OK


##  自动注入属性，在节点发出 tree_entered 信号之后开始注入属性
##[br]
##[br][code]root[/code]  设置的根节点
##[br][code]by_name[/code]  根据节点名注入属性
##[br][code]by_class[/code]  根据节点的类注入属性
##[br][code]all_child[/code]  扫描所有节点，如果为false则仅扫描当前子节点
static func auto_inject(
	root: Node, 
	by_name: bool = true, 
	by_class: bool = false,
	all_child: bool = true,
) -> Error:
	if not is_instance_valid(root):
		printerr("[ FuncUtil ] auto_inject: ", root, '是个无效的对象')
		return FAILED
	
	var callback = func():
		var prop_list : Array = []
		if by_class:
			for data in ScriptUtil.get_property_data_list(root.get_script()):
				if (data['type'] == TYPE_OBJECT 
					and data['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE
				):
					prop_list.append(data['name'])
		
		var nodes = NodeUtil.get_all_child(root) \
			if all_child \
			else root.get_children()
		for child in nodes:
			if by_name:
				var property = child.name
				if property in root and root[property] == null:
					root[property] = child
			
			if by_class:
				var property : String 
				for i in range(prop_list.size()-1, -1, -1):
					property = prop_list[i]
					if root[property] == null:
						root[property] = child
					# 如果赋值功，则移除掉
					if root[property]:
						prop_list.remove_at(i)
	
	if root.is_inside_tree():
		callback.call()
	else:
		root.tree_entered.connect(callback)
	
	return OK


## 根据节点路径注入节点
##[br]
##[br][code]node[/code]  设置属性的节点
##[br][code]property_to_node_path_map[/code]  属性对应的要获取的节点的路径。key 为属性，
##value 为节点路径
##[br][code]get_path_to_node[/code]  根据这个节点获取这个路径节点，如果为 [code]null[/code]，
##则默认为当前方法的 node 参数的值
##[br][code]set_node_callable[/code]  如何获取设置节点的方法，这个方法需要有两个参数，第一个参数为
##[String] 类型接收属性名，第二个为 [NodePath] 类型，用于接收节点路径，返回一个 [Node] 类型的数据
static func inject_by_path_map(
	node: Node, 
	property_to_node_path_map: Dictionary, 
	get_path_to_node: Node = null
):
	if get_path_to_node == null:
		get_path_to_node = node
	
	on_enter_tree(func():
		var node_path : NodePath
		for prop in property_to_node_path_map:
			node_path = property_to_node_path_map[prop]
			# 获取节点设置属性
			node[prop] = get_path_to_node.get_node_or_null(node_path)
	, node)


##  根据节点路径设置属性。获取到的节点会赋值给对应节点名的变量
##[br]
##[br][code]node[/code]  设置属性的节点
##[br][code]node_path_list[/code]  节点路径列表，如果有这个节点名称的属性，则进行设置
##[br][code]get_path_to_node[/code]  根据这个节点获取这个路径的节点，如果为 null，则默认为
##target_node 参数值
static func inject_by_path_list(
	target_node: Node, 
	node_path_list: PackedStringArray, 
	get_path_to_node: Node = null
):
	on_enter_tree(func():
		var prop_to_node_path_map := {}
		var prop : String
		for node_path in node_path_list:
			prop = str(node_path).get_file().replace("%", "")
			if prop in target_node:
				prop_to_node_path_map[prop] = node_path
			else:
				printerr(target_node, " 节点中没有这个属性：", prop)
		inject_by_path_map(target_node, prop_to_node_path_map, get_path_to_node)
	, target_node)


##  场景唯一节点名对应属性名
##[br]
##[br][code]node[/code]  设置属性的节点
##[br][code]prefix[/code]  属性前缀。如果为空字符串，则默认筛选注入全部 Object 类型属性
static func inject_by_unique(
	node: Node,
	prefix: String = "", 
	get_path_to_node: Node = null
):
	on_enter_tree(func():
		# 获取这个前缀的属性名
		var property_list = (node.get_property_list()
			.filter(func(data): return \
				data['type'] == TYPE_OBJECT \
				and data['usage'] == PROPERTY_USAGE_SCRIPT_VARIABLE \
				and ( prefix == "" or data['name'].begins_with(prefix))
			,)
			.map(func(data): return data['name'] )
		)
		var prop_to_node_path_map = {}
		for prop in property_list:
			prop_to_node_path_map[prop] = "%" + prop.trim_prefix(prefix)
		if get_path_to_node == null:
			get_path_to_node = node
		var node_path
		for property in prop_to_node_path_map:
			node_path = prop_to_node_path_map[property]
			if not node[property]:
				node[property] = get_path_to_node.get_node_or_null(node_path)
	, node)

##  遍历列表
##[br]
##[br][code]list[/code]  列表
##[br][code]callback[/code]  回调方法，这个方法需要有个参数：
##[br] - item [Variant] 类型参数，用于接收这个索引的列表项的值
##[br] - idx  [int] 类型参数，用于接收索引
##[br][code]step[/code]  间隔步长，如果超过0则正序行，如果低于0则倒序执行
##[br] 比如扫描当前对象脚本下的所有 gd 文件
##[codeblock]
##var dir = ScriptUtil.get_object_script_path(self).get_base_dir()
##var files = FileUtil.scan_file(dir)
##FuncUtil.foreach(files, func(file: String, idx: int):
##    if file.get_extension() == "gd":
##        print(file, "\t", file.get_file())
##)
##[/codeblock]
static func foreach(list: Array, callback: Callable, step: int = 1) -> void:
	if step > 0:
		for i in range(0, list.size(), step):
			callback.call(list[i], i)
	elif step < 0:
		for i in range(list.size()-1, -1, step):
			callback.call(list[i], i)
	else:
		assert(false, "错误的 step 参数值，值不能为 0！")


## 循环遍历执行
##[br]
##[br][code]list[/code]  遍历的列表
##[br][code]callback[/code]  回调方法。这个方法可以设置参数的型，而普通 [code]for[/code]
##循环需要指定类型，否则不能设置参数类型。或者直接调用某个统一的方法，去遍历执行。
##[br]
##[br]示例，控制节点列表移动：
##[codeblock]
##FuncUtil.forexec(node_list, RoleUtil.control_move)
##[/codeblock]
static func forexec(list: Array, callback: Callable):
	for item in list:
		callback.call(item)


##  遍历字典。使用这个方法的好处是 callback 里的参数可以设置类型，参数有代码提示
##[br]
##[br][code]dict[/code]  字典数据
##[br][code]callback[/code]  回调方法。这个方法需要有两个参数，一个 key，一个 value
static func for_dict(dict: Dictionary, callback: Callable):
	for key in dict:
		callback.call( key, dict[key] )


##  遍历向量。从开始到结束位置
##[br]
##[br][code]from[/code]  起始点
##[br][code]to[/code]  结束点
static func for_vector2(from: Vector2, to: Vector2, callback: Callable):
##[br][code]callback[/code]  回调方法
	var direction = from.direction_to(to)
	callback.call(from)
	for i in from.distance_to(to):
		from += direction
		callback.call(from)


## 遍历向量。这个 [code]callback[/code] 回调要有一个 [Vector2i] 类型的参数
##[br]
##[br][b]注意：[/b]这个遍历是一条直线，而不是矩形。如果遍历整个矩形，请使用 [method for_rect]
##方法
static func for_vector2i(from: Vector2i, to: Vector2i, callback: Callable):
	var a = Vector2(from)
	var b = Vector2(to)
	var direction = a.direction_to(b)
	callback.call(from)
	for i in floor(a.distance_to(b)):
		a += direction
		callback.call(Vector2i(a.round()))


## 遍历 rect。[code]callback[/code] 回调方法需要有一个 [Vector2] 类型的参数的回调。
##[br]
##[br][b]注意：[/b]这是以 [x, y] 的范围进行遍历，而不是 [x, y)，是包含最后的 y 的
static func for_rect(rect: Rect2, callback: Callable) -> void:
	for y in range(rect.position.y, rect.end.y + 1):
		for x in range(rect.position.x, rect.end.x + 1):
			callback.call(Vector2(x, y))

## 回调方法中要有一个参数接收一个 [Vector2i] 类型的值
static func for_rect_i(rect: Rect2i, callback: Callable) -> void:
	for y in range(rect.position.y, rect.end.y + 1):
		for x in range(rect.position.x, rect.end.x + 1):
			callback.call(Vector2i(x, y))

## 回调方法中要有一个参数接收一个 [float] 类型的 x 值
static func for_rect_x(rect: Rect2, callback: Callable) -> void:
	for x in range(rect.position.x, rect.end.x + 1):
		callback.call(x)

## 回调方法中要有一个参数接收一个 [float] 类型的 y 值
static func for_rect_y(rect: Rect2, callback: Callable) -> void:
	for y in range(rect.position.y, rect.end.y + 1):
		callback.call(y)


##  遍历 rect 四周。一般用于将地图四周围起来
##[br]
##[br][code]rect[/code]  矩形值
##[br][code]callback[/code]  回调方法，这个方法需要有一个 [Vector2] 类型的参数接收回调，
## 如果需要的是 [Vector2i] 类型，则将参数指定为 Vector2i 类型即可
static func for_rect_around(rect: Rect2, callback: Callable):
	var rect_range_dir : Array = [
		[rect.position.x, rect.end.x, Vector2i.RIGHT],	# 从左到右
		[rect.position.y, rect.end.y, Vector2i.DOWN],	# 从上到下
		[rect.end.x, rect.position.x, Vector2i.LEFT],	# 从右到左
		[rect.end.y, rect.position.y, Vector2i.UP],	# 从下到上
	]
	var coords : Vector2i = rect.position
	var from
	var to
	for list in rect_range_dir:
		from = list[0]
		to = list[1]
		for i in abs(from - to):
			callback.call(coords)
			coords += list[2]


## 圆形遍历。这个回调方法需要有个 [Vector2i] 或 [Vector2] 类型的参数
static func for_rect_circle(rect: Rect2, radius: float, callback: Callable):
	var center = rect.get_center()
	var raidus_squared = pow(radius, 2)
	for_rect_i(Rect2i(rect), func(v: Vector2i):
		if (Vector2(v) - center).length_squared() <= raidus_squared:
			callback.call(v)
	)


##  递归处理对象。要确保有归出的条件，返回否值进行归出，比如 [code]null, false, [], {}[/code]，
##不返回值默认为 null 只遍历一层就结束。
##[br]
##[br][code]object[/code]  递归的对象或对象列表
##[br][code]callback[/code]  这个方法用于接收要递归的对象，并返回下一个要递归的对象或数组。
##[br]
##[br]示例，遍历所有子节点：
##[codeblock]
##var list = []
##FuncUtil.recursion(self, func(node):
##    list.append(node)
##    return node.get_children()
##)
##print(list)
##[/codeblock]
static func recursion(object, callback: Callable) -> void:
	var last = (object if object is Array else [object] )
	while true:
		var next_list = []
		if last:
			for i in last:
				var items = callback.call(i)
				if items:
					if items is Array:
						next_list.append_array(items)
					else:
						next_list.append(items)
			last = next_list
		else:
			break


## 合并字典。深度进行合并，里面所有有关字典的数据都可以被合并
##[br]
##[br][code]from[/code]  数据来源
##[br][code]to[/code]  合并数据到这个字典上
##[br][code]callback[/code]  用于合并的方法。这个方法需要有以下几个参数：
##[br]  * from_parent 参数为 from 中嵌套的 key 的父级值
##[br]  * to_parent 参数为 to 中嵌套的 key 的父级值
##[br]  * key 为递归遍历的 from 数据中的每个 key 键
##[br]  * from_value 为递归遍历的 from 数据中的每个 key 的值
##[br]  * to_value 参数为 to_parent （父级字典数据）下的 key 键的数据
##[br]
##[br]比如将字典 from 合并到字典 to 中：
##[codeblock]
##FuncUtil.merge_dict(from, to, func(from_parent: Dictionary, to_parent: Dictionary, key, from_value, to_value):
##    # 如果存在这个 key 的数据
##    if to_parent.has(key):
##        if to_parent[key] is Dictionary and from_value is Dictionary:
##            # 如果存在的数据是个字典，则进行合并
##            to_parent[key].merge(from_value)
##        else:
##            # 其他情况不合并（原因：to_parent 字典中已经有值这里就不想再给他替换了）
##            pass
##    else:
##        # 没有这个数据则直接添加
##        to_parent[key] = from_value
##)
##[/codeblock]
static func merge_dict(from: Dictionary, to: Dictionary, callback: Callable) -> void:
	var call = [null] # 匿名函数在使用面的数据的时候，需要是引用类型的，所以要用数组或字典
	
	call[0] = func(from_parent: Dictionary, to_parent: Dictionary, key, from_value, to_value, ):
		callback.call(from_parent, to_parent, key, from_value, to_value, )
		if from_value is Dictionary:
			for from_child_key in from_value:
				call[0].call(
					from_value,
					to_value, 
					from_child_key, 
					from_value[from_child_key],  
					to_value.get(from_child_key) #if to_value is Dictionary else null, 
				)
	
	for key in from:
		call[0].call( 
			from,
			to, 
			key, 
			from[key],
			to.get(key) #if to is Dictionary else null, 
		)


## 监听执行
##[br]
##[br][code]condition[/code]  执行结束条件方法
##[br][code]execute_callback[/code]  执行功能
##[br][code]finish_callable[/code]  执行结束时的回调
static func monitor(condition: Callable, execute_callback: Callable, finish_callable: Callable = Callable()):
	execute_fragment_process(INF, execute_callback ) \
	.set_finish_condition(condition) \
	.set_finish_callback(
		func():
			if finish_callable.is_valid():
				finish_callable.call()
	)


## 施加力
##[br]
##[br][code]init_vector[/code]  初始移动速度
##[br][code]attenuation[/code]  衰减速度
##[br][code]motion_callable[/code]  控制运动的回调。这个方法需要接收一个 [FuncApplyForceState] 类型的数据，
##利用里面的数据控制节点
##[br][code]target[/code]  执行功能的节点的依赖目标，如果这个目标死亡，则执行结束
##[br][code]duration[/code]  持续时间
static func apply_force(init_vector: Vector2, attenuation: float, motion_callable: Callable, target: Node2D = null, duration : float = INF):
	var state := FuncApplyForceState.new()
	state.speed = init_vector.length()
	state.update_velocity(init_vector)
	state.attenuation = attenuation
	
	# 控制运动
	var timer = DataUtil.get_ref_data(null)
	timer.value = execute_fragment_process(duration, func():
		if attenuation > 0:
			state.speed = state.speed - attenuation
		if (
			state.finish
			or state.speed <= 0 
			or (target != null and not is_instance_valid(target))
		):
			timer.value.queue_free()
			return
		
		# 运动回调
		motion_callable.call(state)
		
	, Timer.TIMER_PROCESS_PHYSICS, target)


##  曲线缓动。按照曲线上的 y 值设置对应属性
##[br]
##[br][code]curve[/code]  曲线资源对象
##[br][code]object[/code]  修改性的对象
##[br][code]property_path[/code]  属性路径
##[br][code]duration[/code]  持续时间
##[br][code]scale[/code]  属性缩放值
static func tween_curve(curve: Curve, 
	object: Object, 
	property_path: NodePath, 
	duration: float,
	scale: float = 1, 
):
	const TIME = 0
	const SCENE = 1
	var proxy = [0.0, Engine.get_main_loop().current_scene]
	execute_fragment_process(duration, 
		func():
			var ratio : float = proxy[TIME] / duration
			object.set_indexed(property_path, curve.sample_baked(ratio) * scale)
			proxy[TIME] += proxy[SCENE].get_process_delta_time()
	, Timer.TIMER_PROCESS_IDLE
	, object if object is Node else Engine.get_main_loop().current_scene
	).set_finish_callback(func(): 
		object.set_indexed(property_path, curve.sample_baked(1) * scale)
	)


## 执行 Curve 曲线的比值的 tween
##[br]
##[br][code]curve[/code]  曲线资源对象。一般是创建一个 [Curve] 文件或使用对象的 [Curve] 类型的属性的值作为参数值
##[br][code]object[/code]  控制对象
##[br][code]property_path[/code]  控制属性
##[br][code]final_val[/code]  执行完到达的最终值
##[br][code]duration[/code]  执行时间
##[br][code]reverse[/code]  颠倒获取曲线值
##[br][code]init_val[/code]  初始值。一般 reverse 参数为 [code]true[/code] 时都要设置这个值
static func execute_curve_tween(
	curve: Curve, 
	object: Object, 
	property_path: NodePath, 
	final_val: Variant, 
	duration: float, 
	reverse: bool = false, 
	init_val = null 
): 
	# 初始值
	if init_val == null:
		init_val = object.get_indexed(property_path)
	if reverse:
		var tmp = init_val
		init_val = final_val
		final_val = tmp
	
	# 开始播放
	const TIME = 0
	const SCENE = 1
	var proxy = [0.0, Engine.get_main_loop().current_scene]
	object.set_indexed(property_path, init_val)
	execute_fragment_process(duration, 
		func():
			proxy[TIME] += proxy[SCENE].get_process_delta_time()
			var ratio : float = proxy[TIME] / duration
			object.set_indexed(property_path, lerp(init_val, final_val, curve.sample_baked(ratio)))
		
	, Timer.TIMER_PROCESS_IDLE
	, object if object is Node else Engine.get_main_loop().current_scene
	).set_finish_callback(func(): 
		object.set_indexed(property_path, lerp(init_val, final_val, curve.sample_baked(1)))
	)


##  每帧不断地方法，直到条件为 [code]true[/code] 执行回调结束
##[br]
##[br][code]condition[/code]  执行条件
##[br][code]callback[/code]  回调方法
static func until(condition: Callable, callback: Callable):
	while condition.call():
		callback.call()
		await Engine.get_main_loop().process_frame


##  路径移动（广度优先搜索）。一般用于搜索路径，比如用在 [TileMap] 从一个坐标开始搜索周围没有瓦片的所有坐标
##[br]
##[br][code]start[/code]  开始移动的位置。这个位置不会传入到回调中
##[br][code]directions[/code]  可移动的方向列表
##[br][code]next_condition[/code]  是否可移动到下一个位置的条件。这个方法需要有一个 [Vector2i]
##类型的参数接收判断是否可以移动到这个位置，并返回一个 [bool] 值，如果返回 [code]true[/code] 则下一层时会移动到这个位置
##[br][code]ready_next_callback[/code]  开始下一层遍历时会调用这个方法，需要一个 [Vector2i]
##类型的参数接收开始下一层的坐标列表。
##[br][code]return[/code]  返回已经过的点的列表
static func path_move(
	start: Vector2i, 
	directions: Array[Vector2i], 
	next_condition: Callable,
	ready_next_callback: Callable = Callable()
) -> Array[Vector2i]:
	var last : Array[Vector2i] = [start]
	var pass_points := {}
	var moved = {}
	var next_pos : Vector2i
	while true:
		var next_points := {}
		for coord in last:
			moved[coord] = null
			for direction in directions:
				next_pos = coord + direction
				if (not moved.has(next_pos) 
					and next_condition.call(next_pos)
				):
					next_points[next_pos] = null
					pass_points[next_pos] = null
		
		last = Array(next_points.keys(), TYPE_VECTOR2I, "", null)
		if last.size() == 0:
			break
		if ready_next_callback.is_valid():
			ready_next_callback.call(last)
	
	return Array(pass_points.keys(), TYPE_VECTOR2I, &"", null)


## 节点在树中否则在 ready 之后调用方法。在节点还未添加到景中的时候使用
static func ready_call(node: Node, callback: Callable) -> void:
	if not node.is_inside_tree(): 
		await node.ready
	callback.call()


## 数据重复为列表
##[br]
##[br][code]data[/code]  重复的数据
##[br][code]count[/code]  重复的数量
##[br][code]duplicate[/code]  是否复制这个对象
##[br][code]return[/code]  返回重复的列表
static func repeat_list(data, count: int, duplicate: bool = true) -> Array:
	var list : Array = []
	if duplicate and (data is Object or data is Dictionary or data is Array):
		for i in count:
			var obj = data.duplicate()
			list.append(obj)
		return list
		
	else:
		for i in count:
			list.append(data)
	return list


## 二值排序
##[br]
##[br][code]list[/code]  排序的列表
##[br][code]sort_method[/code]  排序方法回调。这个方法需要有一个参数，接收列表中的每个项，
##并返回 [bool] 类型的值。
##如果返回 [code]true[/code]，则排在前面；
##如果返回 [code]false[/code]，则排在后面。
##[br][code]return[/code]  返回原来的但已经排序后的列表
##[br]
##[br][b]一般用在数据是否为空的排序，有数据的排在前面，空数据的排在后面[/b]
static func sort_binary(list: Array, sort_method: Callable) -> Array:
	var a_list : Array = []
	var b_list : Array = []
	for item in list:
		if sort_method.call(item):
			a_list.append(item)
		else:
			b_list.append(item)
	list.clear()
	list.append_array(a_list)
	list.append_array(b_list)
	return list


##  过滤数据
##[br]
##[br][code]data[/code]  要过滤的数据。仅支持 [Array, Dictionary, String] 类型
##[br][code]method[/code]  过滤方法。需要有一个参数接收每个项。这个回调
##方法需要返回一个 [bool] 值用以判断是否过滤，如果返回 [code]true[/code] 则不过滤，否则过滤
##[br]
##[br][b]注意：[/b]如果类型为 [Dictionary] 时，这个回调方法的参数类型为 [Dictionary]，格式如下
##[codeblock]
##{"key": 键, "value": 值}
##[/codeblock]
##[br][code]return[/code] 返回过滤后的数据
static func filter(data, method: Callable):
	if data is Dictionary:
		var dict : Dictionary = {}
		for key in data:
			if method.call({
				"key": key,
				"value": data[key],
			}):
				dict[key] = data[key]
		return dict
	else:
		var new_data
		if data is Array:
			new_data = []
		elif data is String:
			new_data = ""
		else:
			assert(false, "不支持的数据类型")
		for i in data:
			if method.call(i):
				new_data += i
		return new_data


##  转换数据
##[br]
##[br][code]data[/code]  数据值。只能是 [Array] 或 [Dictionary] 数据类型
##[br][code]method[/code]  转换数据值的方法。这个回调方法需要有一个任意类型的参数，接收每个数据项。
##如果数据类型为 [Dictionary] 类型，则接收的参数类型为 Dictionary 类型，这个数据有 key 和 value，
##对应每个 key 和 value 的数据，返回的数据为转换后的 value 的数据
static func map(data, method: Callable):
	if data is Array:
		return data.map(method)
	elif data is Dictionary:
		var new_data : Dictionary = {}
		for key in data:
			var entry : Dictionary = {
				key = key, 
				value = data[key]
			}
			entry.is_read_only()
			new_data[key] = method.call(entry)
			
		return new_data
		
	else:
		assert(false, "只支持 [Array, Dictionary] 数据类型")


## 桶排序
##[br]
##[br][code]list[/code]  排序列表
##[br][code]sort_method[/code] 排序方法。这个方法需要有一个参数接收每个项，并返回一个 [int]
##类型的值，用于设置这个值所在的序号组。
##[br][code]return[/code]  返回原来的但已经排序后的原来的列表
##[br]
##[br][b]一般用与对某种类型的数据进行排序。[/b]
##[br]
##[br]比如对物品类型的排序，示例：
##[codeblock]
##FuncUtil.sort_barrel(item_data_list, func(item_data):
##    if item_data.type == GoodsType.CONSUMABLE:   # 消耗类物品放在第1位
##        return 1
##    elif item_data.type == GoodsType.WEAPON:     # 武器类放在第2位
##        return 2
##    elif item_data.type == GoodsType.DECORATIVE: # 饰品类放在第3位
##        return 3
##    else:
##         return INF
##)
##[/codeblock]
##[br]一般情况下物品类型都是枚举值的话，只用直接根据枚举值设置顺序：
##[codeblock]
##FuncUtil.sort_barrel(item_data_list, func(item_data): return item_data.type)
##[/codeblock]
static func sort_barrel(list: Array, sort_method: Callable) -> Array:
	# 桶排序
	var dict : Dictionary = {}
	var index : int = 0
	for item in list:
		index = sort_method.call(item)
		if not dict.has(index):
			dict[index] = []
		dict[index].append(item)
	
	# 按序号顺序添加
	list.clear()
	var indexs = dict.keys()
	indexs.sort()
	for idx in indexs:
		for item_list in dict[idx]:
			list.append(item_list)
	
	return list


## 值组合
##[br]
##[br]对列表中的值进行排列组合。返回所有组合的结果
static func combination(items: Array) -> Array[Array]:
	assert(items.size() <= 1000, "组合的值不能太多")
	
	# 执行方法
	var result : Array[Array] = []
	var callback : Array = []
	callback.append(func(tmp: Array, from: int, max_idx: int):
		tmp.append(from)
		result.append(tmp.map(func(item_index): return items[item_index] ))
		
		from += 1
		for i in range(from, max_idx):
			callback[0].call(tmp.duplicate(), i, max_idx)
		
		tmp.pop_front()
		result.append(tmp.map(func(item_index): return items[item_index] ))
		
	)
	
	# 递归执行
	callback[0].call([], 0, items.size())
	return result


##  过滤为单个。去掉重复对象
##[br]
##[br][code]list[/code]  列表
##[br][code]return[/code]  返回列表
static func filter_of_single(list: Array) -> Array:
	var dict : Dictionary = {}
	for item in list:
		dict[item] = null
	if list.is_typed():
		return Array(dict.keys(), list.get_typed_builtin(), list.get_typed_class_name(), list.get_typed_script())
	else:
		return dict.keys()


## 处理 item。对多个单个对象进行批处理调用另一个方法时使用。
##[br]
##[br]比如将每个项添加到节点上，则可以
##[codeblock]
##var nodes : Array[Node]  # 节点列表数据
##var root : Node = Engine.get_main_loop().current_scene
##FuncUtil.forexec(nodes, FuncUtil.to_item.bind(root, "add_child"))
##[/codeblock]
##将每个对象添加到列表中
##[codeblock]
##var items : Array  # 其他地方的 Item 列表
##var list : Array = []
##FuncUtil.forexec(items, FuncUtil.to_item.bind(list, "append"))
##[/codeblock]
static func to_item(item, to, method: String):
	if to is Object:
		to.call(method, item)
	else:
		var meta_key : StringName = StringName("FuncUtil_to_inst_%s" % typeof(to))
		var inst
		if Engine.has_meta(meta_key):
			inst = Engine.get_meta(meta_key)
		else:
			var script = GDScript.new()
			script.source_code = """
extends Object

var to

func exec(item):
	to.{method}(item)

""".format({
	"method": method,
})
			script.reload()
			inst = script.new()
			Engine.set_meta(meta_key, inst)
		
		inst.to = to
		inst.exec(item)


## 一次性计时器结束调用回调方法
static func timeout(time: float, callback: Callable = Callable()) -> Signal:
	var timeout_signal = Engine.get_main_loop().create_timer(time).timeout
	if not callback.is_null():
		timeout_signal.connect(callback)
	return timeout_signal

## 这两个线程都在所有 Node 的线程之前发出
static func physics_frame() -> Signal:
	return Engine.get_main_loop().physics_frame

static func process_frame() -> Signal:
	return Engine.get_main_loop().process_frame

## 找到一个符合条件的值
##[br]
##[br][code]list[/code]  数据列表
##[br][code]callback[/code]  过滤方法。这个方法需要有一个参数，用于接收并判断列表中的每个项，
##并返回一个值进行返回符合条件的数据
##[br][code]default[/code]  没有找到数据时默认返回的值
static func find_first(list: Array, callback: Callable, default = null):
	for item in list:
		if callback.call(item):
			return item
	return default


## 生成网格点
static func generate_grid_point(
	rect: Rect2,  ## 生成在这个矩形范围内的点
	space: Vector2 = Vector2.ONE,  ## 点之间的空间范围，间距大小
	offset: Vector2 = Vector2.ZERO ## 左上角偏移位置
) -> Array[Vector2]:
	var id := StringName(str(hash([rect, space, offset])))
#	print_debug("[ generate_grid_point ] 生成网格点, id = ", [ id ])
	return DataUtil.singleton("FuncUtil_generate_grid_point_%s" % id, func():
		var point : Vector2 = Vector2.ZERO
		# 开始生成
		var list : Array[Vector2] = []
		point.y = rect.position.y + offset.y
		while point.y <= rect.end.y:
			point.x = rect.position.x + offset.x
			while point.x <= rect.end.x:
				list.append(point)
				point.x += space.x
			point.y += space.y
		return list
	)

static func node2d_move(node: Node2D, velocity: Vector2):
	node.global_position += velocity

static func character_move(node: CharacterBody2D, velocity: Vector2) -> bool:
	node.velocity = velocity
	return node.move_and_slide()

static func move_node2d(velocity: Vector2, node: Node2D):
	node2d_move(node, velocity)

static func move_character(velocity: Vector2, node: CharacterBody2D):
	return character_move(node, velocity)

class _FuncUtil_Move:
	extends Node
	
	var method : Callable
	var velocity
	
	func _physics_process(delta):
		if is_instance_valid(method.get_object()):
			method.call(velocity)
		else:
			queue_free()

## 创建一个移动节点控制节点的移动，并返回由此创建的代理控制的节点
static func move(
	velocity, 
	move_method: Callable, 
	host: Node = null
) -> _FuncUtil_Move:
	if not is_instance_valid(host):
		var object = move_method.get_object()
		if object is Node:
			host = object
		else:
			host = Engine.get_main_loop().current_scene
	var move_node = _FuncUtil_Move.new()
	move_node.method = move_method
	move_node.velocity = velocity
	host.add_child(move_node)
	return move_node


## 重复调用方法
static func repeat_call(number: int, callback: Callable):
	for i in number:
		callback.call()


## 停止计时器计时
static func stop_timer(timer: Object):
	if timer is Timer:
		timer.stop()
	elif timer is SceneTreeTimer:
		Engine.get_main_loop().queue_delete(timer)

