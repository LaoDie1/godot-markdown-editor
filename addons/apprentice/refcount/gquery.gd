#============================================================
#    Godot Query
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-01 17:00:51
# - version: 4.0
#============================================================
class_name GQuery


# 数据
var _data : Array = []
# 原始数据是否是 Array 类型
var _is_array : bool = false


#============================================================
#  内置
#============================================================
func _init(data):
	_is_array = (data is Array)
	if _is_array:
		_data.append_array(data)
	else:
		_data.append(data)


#============================================================
#  实例化方法
#============================================================
static func from(data) -> GQuery:
	return GQuery.new(data)

static func await_signal(_signal: Signal, data) -> GQuery:
	await _signal
	return GQuery.new(data)

static func enter_tree(node: Node, method: Callable):
	if node.is_inside_tree():
		method.call(GQuery.new(node))
	else:
		node.tree_entered.connect( method.bind(GQuery.new(node)), Object.CONNECT_ONE_SHOT )

static func ready(node: Node, method: Callable):
	if node.is_inside_tree():
		method.call(GQuery.new(node))
	else:
		node.ready.connect( method.bind(GQuery.new(node)), Object.CONNECT_ONE_SHOT )


#============================================================
#  私有代码
#============================================================

#  获取信号的数据
#[br]
#[br][code]object[/code]  对象
#[br][code]signal_name[/code]  信号名称
#[br][code]return[/code]  返回这个信号的数据
static func _get_signal_data(object: Object, signal_name: String) -> Dictionary:
	const KEY = &"GQuery_get_signal_data"
	if not Engine.has_meta(KEY):
		Engine.set_meta(KEY, {})
	
	var signal_cache_data := Engine.get_meta(KEY) as Dictionary
	var key = object.get_script()
	if key == null:
		key = object.get_class()
	if not signal_cache_data.has(key):
		var object_signal_data : Dictionary = {}
		for data in object.get_signal_list():
			object_signal_data[data['name']] = data
		if object.get_script():
			for data in object.get_script().get_script_signal_list():
				object_signal_data[data['name']] = data
	
	var object_signal_data : Dictionary = Dictionary(signal_cache_data[key])
	for name in object_signal_data:
		if name == signal_name:
			return object_signal_data[name]
	return {}


#  以数组作为参数发送信号
#[br]
#[br][code]object[/code]  发送信号的对象
#[br][code]signal_name[/code]  信号名
#[br][code]parameters[/code]  信号参数列表
static func _emit_signalv(object, signal_name: String, parameters: Array = []):
	const KEY = "SignalUtil_emit_signalv_data"
	if not Engine.has_meta(KEY):
		Engine.set_meta(KEY, {})
	var data : Dictionary = Engine.get_meta(KEY)
	var cache_key = object.get_script()  \
		if object.get_script() \
		else object.get_class() if not object is Callable \
		else object
	
	var proxy : Object
	if data.has(cache_key):
		proxy = data[cache_key]
	else:
		var signal_data : Dictionary = _get_signal_data(object, signal_name)
		var arg_count : int = signal_data['args'].size()
		
		var str_parameters : String = ", ".join(range(arg_count).map(func(i): return "list[%d]" % i))
		var script = GDScript.new()
		script.source_code = """
extends Object

func apply(object: Object, list: Array):
	object.{signal_name}.emit({params})

""".format({
	"signal_name": signal_name,
	"params": str_parameters,
})
		script.reload(true)
		proxy = script.new()
		data[cache_key] = proxy
	
	proxy.apply(object, parameters)


# 获取帧信号
static func _get_main_loop_frame_signal(process_type: Timer.TimerProcessCallback) -> Signal:
	if process_type == Timer.TIMER_PROCESS_IDLE:
		return Engine.get_main_loop().process_frame
	else:
		return Engine.get_main_loop().physics_frame



#============================================================
#  获取原始数据
#============================================================
## 获取这个原始存入时的数据
func get_origin_data():
	if _is_array:
		return _data
	else:
		return _data[0]

## 获取这个索引的数据项
func get_item(index: int):
	return _data[index]

## 获取数据每个数据项
func get_items() -> Array:
	return _data

## 随机一个数据
func random_item():
	return _data.pick_random()

func first_item():
	if _data.is_empty():
		return null
	return _data.front()

func last_item():
	if _data.is_empty():
		return null
	return _data.back()


#============================================================
#  自定义
#============================================================
## 每个数据索引
func indexs() -> GQuery:
	return GQuery.new(range(_data.size()))

## 获取数据列表
func get_values() -> GQuery:
	if get_origin_data() is Dictionary:
		return GQuery.new(get_origin_data().values())
	else:
		return self

## 列表数据类型化
##  get_type_items
##[br]
##[br][code]type_value[/code]  数据类型值。可传入 [enum Variant.Type] 中的数据类型，或内置类名，或类对象。
##比如： get_type_items(Area2D)
func get_type_items(type_value) -> Array:
	if type_value is int:
		return Array(_data, type_value, "", null)
	elif type_value is String or type_value is StringName:
		return Array(_data, TYPE_OBJECT, type_value, null)
	elif type_value is Script:
		return Array(_data, TYPE_OBJECT, type_value.get_instance_base_type(), type_value)
	elif type_value is Object and type_value.get_class() == "GDScriptNativeClass":
		var _class = type_value.get_class()
		return Array(_data, TYPE_OBJECT, _class, null)
	else:
		assert(false, "错误的参数数据类型")
		return []


## 获取数据
func gets(property_name) -> GQuery:
	if _is_array:
		return GQuery.new(_data.map(func(i): return i[property_name]))
	else:
		return GQuery.new(_data[0][property_name])


## 设置属性
func sets(property_name, value) -> GQuery:
	for object in _data:
		object[property_name] = value
	return self


## 修改数据
func alter(idx: int, value) -> GQuery:
	_data[idx] = value
	return self


## 数据类型化。type_value 参数描述详见 [method get_type_items] 方法
func type(type_value) -> GQuery:
	return GQuery.new(get_type_items(type_value))


## 字典设置属性
##[br]
##[br][code]data[/code]  属性数据。key为属性名，value为属性值
func prop_map(data: Dictionary) -> GQuery:
	for object in _data:
		for prop in data:
			object[prop] = data[prop]
	return self


##  位置偏移
##[br]
##[br][code]position[/code]  偏移值
func offset(position: Vector2) -> GQuery:
	for node in _data:
		node.global_position += position
	return self


##  旋转
##[br]
##[br][code]angle[/code]  旋转角度
func rotate(angle: float) -> GQuery:
	for node in _data:
		node.rotation += angle
	return self


##  添加节点到
##[br]
##[br][code]parent[/code]  添加到的父节点
##[br]剩余两个参数信息，详见：[method Node.add_child]
func add_to(parent: Node, force_readable_name: bool = false, internal: Node.InternalMode = 0) -> GQuery:
	for node in _data:
		if not node.is_inside_tree():
			parent.add_child(node, true)
	return self


## 添加节点
##[br]
##[br][code]method[/code] 添加的节点。这个回调方法没有参数，需要返回一个 [Node] 类型的数据，用以添加节点
##[br][code]return[/code]  返回添加的节点列表 [GQuery]
func add_child(method: Callable) -> GQuery:
	var list : Array = []
	var child : Node
	for node in _data:
		child = method.call()
		node.add_child(child)
	return GQuery.new(self)


## 添加这个类型的节点
##[br]
##[br][code]type_value[/code]  添加的节点类型。这个值可以是内置的类名字符串、内置类对象或自定义的脚本类对象。
##[br] 示例：
##[codeblock]
##add_child_by_type("Node2D")
##add_child_by_type(Node2D)
##add_child_by_type(Player)
##[/codeblock]
func add_child_by_type(type_value) -> GQuery:
	if type_value is StringName or type_value is String:
		return add_child(func(): return ClassDB.instantiate(type_value) )
	elif type_value is Object:
		assert(type_value is Script or type_value.get_class() == "GDScriptNativeClass", "错误的数据类型")
		return add_child(func(): return type_value.new() )
	else:
		assert(false, "错误的数据类型")
		return null


## 执行方法
##[br]
##[br][code]method_name[/code]  方法名
##[br][code]parameters[/code]  方法参数
##[br][code]getter_method[/code]  是否是一个获取据的方法。如果为 [code]true[/code]，
##则返回这个获取的结果的 [GQuery] 对象
##[br][code]call_deferred[/code]  空闲时调用
func call_method(
	method_name: StringName, 
	parameters: Array = [], 
	getter_method : bool = false, 
	call_deferred: bool = false
) -> GQuery:
	if getter_method:
		var list : Array = []
		for object in _data:
			list.append(object.callv(method_name, parameters))
		return GQuery.new(list)
	else:
		return self


## 发送信号
func emit(signal_name: StringName, parameters: Array = []) -> GQuery:
	if not _data.is_empty():
		var first = _data[0]
		for object in _data:
			_emit_signalv(object, signal_name, parameters)
	return self


## 遍历处理数据
##[br]
##[br]这个回调方法要有两个参数：
##[br] - [code]item[/code] 每个数据项
##[br] - [code]idx[/code] 这个数据项的索引
func foreach(method: Callable, call_deferred: bool = false) -> GQuery:
	var idx : int = 0
	if call_deferred:
		for object in _data:
			method.call_deferred(object, idx)
			idx += 1
	else:
		for object in _data:
			method.call(object, idx)
			idx += 1
	return self


## 调用多个回调
func foreachs(callables: Array[Callable], call_deferred: bool = false) -> GQuery:
	for method in callables:
		foreach(method, call_deferred)
	return self


##  转换数据
##[br]
##[br][code]method[/code]  转换数据值的方法。这个回调方法需要有一个任意类型的参数，接收每个数据项。
##如果数据类型为 [Dictionary] 类型，则接收的参数类型为 Dictionary 类型，这个数据有 key 和 value，
##对应每个 key 和 value 的数据，返回的数据为转换后的 value 的数据
func map(method: Callable) -> GQuery:
	var origin = get_origin_data()
	if origin is Array:
		return GQuery.new(origin.map(method))
		
	elif origin is Dictionary:
		var new_data : Dictionary = {}
		for key in origin:
			var entry : Dictionary = {
				key = key, 
				value = origin[key]
			}
			entry.is_read_only()
			new_data[key] = method.call(entry)
		return GQuery.new(new_data)
	
	else:
		assert(false, "只支持 [Array, Dictionary] 数据类型")
		return self


## 转为 List。如果是 [Dictionary] 则只获取 values 的值
func to_list() -> GQuery:
	var origin = get_origin_data()
	if origin is Array:
		return self
	elif origin is Dictionary:
		return GQuery.new(origin.values())
	else:
		return GQuery.new([origin])


## 过滤数据
func filter(method: Callable) -> GQuery:
	var origin = get_origin_data()
	if origin is Dictionary:
		var new_data : Dictionary = {}
		for key in origin:
			if method.call({
				key = key,
				value = origin[key]
			}):
				new_data[key] = origin[key]
		return GQuery.new(new_data)
	else:
		return GQuery.new(_data.filter(method))


## 添加数据
func push(data) -> GQuery:
	_is_array = true
	if data is Array:
		_data.append_array(data)
	else:
		_data.append(data)
	return self


## 删除这些节点
func queue_free() -> void:
	for node in _data:
		node.queue_free()


## 获取子节点
func get_child(index: int) -> GQuery:
	var list : Array = []
	for node in _data:
		list.append(node.get_child(index))
	return GQuery.new(list)


## 获取子节点
##[br]
##[br][code]filter_method[/code] 过滤方法。这个方法需要有一个 [Node] 类型的参数用于
##匹配数据，并返回 [bool] 类型的值
func get_children(filter_method: Callable = Callable()) -> GQuery:
	var list : Array = []
	if filter_method.is_valid():
		for node in _data:
			list.append_array(node.get_children().filter(filter_method))
	else:
		for node in _data:
			list.append_array(node.get_children())
	return GQuery.new(list)


## 获取所有子孙节点
##[br]
##[br][code]filter_method[/code] 过滤方法。这个方法需要有一个 [Node] 类型的参数用于
##匹配数据，并返回 [bool] 类型的值
func all_children(filter_method: Callable = Callable()) -> GQuery:
	var list : Array[Node] = []
	for parent in _data:
		var _scan_all_node : Callable = func(_parent: Node, self_callable: Callable):
			if filter.is_valid():
				for child in _parent.get_children():
					if filter.call(child):
						list.append(child)
			else:
				for child in _parent.get_children():
					list.append(child)
			for child in _parent.get_children():
				self_callable.call(child, self_callable)
		_scan_all_node.call(parent, _scan_all_node)
	return GQuery.new(list)


## 查找匹配子节点。参数详见 [method Node.find_children] 方法。
func find_children(
	pattern: String, 
	type: String = "", 
	recursive: bool = true, 
	owned: bool = true
) -> GQuery:
	var list : Array = []
	for node in _data:
		list.append_array(node.find_child())
	return GQuery.new(list)


## 执行片段
##[br]
##[br][code]duration[/code] 持续时间
##[br][code]method[/code] 执行方法，这个方法需要有一个 [Variant] 任意类型的参数接收数据的回调
##[br][code]process_type[/code] 线程类型。详见：[enum Timer.TimerProcessCallback]
func fragment(
	duration: float, 
	method: Callable, 
	process_type: Timer.TimerProcessCallback = Timer.TIMER_PROCESS_IDLE
) -> GQuery:
	var frame : Signal = _get_main_loop_frame_signal(process_type)
	for item in _data:
		frame.connect(method.call(item))
		# 到达时间断开
		var dis = func(): frame.disconnect(method) 
		Engine.get_main_loop().create_timer(duration).connect(dis)
	return self


## 线程执行
##[br]
##[br][code]method[/code] 执行方法，这个方法需要有一个 [Variant] 任意类型的参数接收每个数据值
##[br][code]process_type[/code] 线程类型。详见：[enum Timer.TimerProcessCallback]
func process( 
	method: Callable, 
	process_type: Timer.TimerProcessCallback = Timer.TIMER_PROCESS_IDLE 
) -> GQuery: 
	var frame : Signal = _get_main_loop_frame_signal(process_type)
	for item in _data:
		frame.connect(method.call(item))
	return self


## 连接当前所有对象信号到目标方法
func connect_method(signal_name: StringName, targets, method_name: StringName) -> GQuery:
	if not targets is Array:
		targets = [targets]
	for object in _data:
		for target in targets:
			(object as Object).connect(signal_name, Callable(target, method_name))
	return self


## 连接当前所有对象的方法到目标对象信号上
func connect_signal(method_name: StringName, targets, signal_name: StringName):
	if not targets is Array:
		targets = [targets]
	for target in targets:
		for object in _data:
			(target as Object).connect(signal_name, Callable(object, method_name))


## 连接每个数据
func join(join_str: String) -> GQuery:
	return GQuery.new( join_str.join(_data) )

## 一次性输出
func printi(separator: String = "", prefix: String = "", suffix: String = "") -> GQuery:
	print(prefix, separator.join(_data), suffix )
	return self

## 按行逐个输出
func println(prefix: String = "", suffix: String = "") -> GQuery:
	for item in _data:
		print(prefix, item, suffix)
	return self

## 遍历 Rect2
func for_rect(method: Callable) -> GQuery:
	for rect in _data:
		for y in range(rect.position.y, rect.end.y + 1):
			for x in range(rect.position.x, rect.end.x + 1):
				method.call(Vector2i(x, y))
	return self

##  遍历周围对象
##[br]
##[br][code]method[/code]  回调方法，这个方法需要有一个参数接收遍历的每个数据。暂时只支持少数数据类型
##[br][code]arg[/code]  额外参数数据
func for_around(method: Callable, arg = null) -> GQuery:
	var origin = get_origin_data()
	if origin is Vector2 or origin is Vector2i:
		if arg == null:
			arg = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]
		for item in arg:
			method.call(item)
	
	elif origin is Rect2 or origin is Rect2i:
		var r : Rect2i = Rect2i(origin.grow(1))
		var rect_range_dir : Array = [
			[r.position.x, r.end.x, Vector2i.RIGHT],	# 从左到右
			[r.position.y, r.end.y, Vector2i.DOWN],	# 从上到下
			[r.end.x, r.position.x, Vector2i.LEFT],	# 从右到左
			[r.end.y, r.position.y, Vector2i.UP],	# 从下到上
		]
		var coords = r.position
		for l in rect_range_dir:
			for i in range(l[0], l[1]):
				method.call(coords)
				coords += l[2]
	
	elif origin is String or origin is Array:
		if arg == null:
			arg = 0
		method.call(null if arg == 0 else origin[arg - 1])
		method.call(origin[arg + 1] if arg < origin.length else null)
	
	else:
		assert(false, "暂时不支持的数据类型")
	
	return self


## 如果为空则执行
func if_null(callback: Callable, has_return: bool = false) -> GQuery:
	if has_return:
		var list = []
		for i in _data:
			if i: list.append(callback.call(i))
		return GQuery.new(list)
	else:
		for i in _data:
			if i: callback.call(i)
		return self


func sort() -> GQuery:
	_data.sort()
	return self
