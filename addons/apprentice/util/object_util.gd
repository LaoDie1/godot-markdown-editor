#============================================================
#    Object Util
#============================================================
# - datetime: 2023-02-05 22:00:57
#============================================================
class_name ObjectUtil


## 引用对象，防止 RefCount 没有引用后被删除
class RefObject:
	extends Object
	
	var value
	
	func _init(value: Object) -> void:
		self.value = value


#============================================================
#  自定义
#============================================================
## 引用目标对象，防止引用丢失而消失。用在 [RefCounted] 类型的对象
##[br]
##[br][code]object[/code] 要引用的对象
##[br][code]depend[/code] 指定的依赖象。如果这个对象消失，则指定的引用对象也随之消失
static func ref_target(object: RefCounted, depend: Object = null):
	if depend == null:
		depend = RefObject.new(object)
	const key = "__ObjectUtil_ref_target_data"
	if depend.has_meta(key):
		var list = depend.get_meta(key) as Array
		list.append(object)
	else:
		var list = [object]
		depend.set_meta(key, list)


## 删除对象
static func queue_free(object: Object) -> void:
	if is_instance_valid(object):
		if object is Node:
			object.queue_free()
		else:
			Engine.get_main_loop().queue_delete(object)


##  对象是否是这个类
##[br]
##[br][code]object[/code]  判断的对象
##[br][code]class_type[/code]  类
static func object_equals_class(object: Object, class_type) -> bool:
	return object != null and is_instance_of(ScriptUtil.get_class_object(object), class_type)


##  设置对象的属性
##[br]
##[br][code]object[/code]  对象的属性
##[br][code]prop_data[/code]  属性数据
##[br][code]setter_callable[/code]  设置属性的方法回调（以何种方式设置对象属性）。
##默认直接对象进行赋值，这个方法需要有 2 个参数，分别于接收设置的属性和设置的值，默认方法回调为：
##[codeblock]
##func(property, value):
##    if property in object:
##        object[property] = value
##[/codeblock]
static func set_property_by_dict(
	object: Object, 
	prop_data: Dictionary, 
	setter_callable : Callable = Callable()
) -> void:
	if not setter_callable.is_valid():
		setter_callable = func(property, value):
			if property in object and typeof(value) != TYPE_NIL:
				object[property] = value
	
	for prop in prop_data:
		setter_callable.call(prop, prop_data[prop])


## 设置属性
static func set_property(object: Object, prop: NodePath, value, deferred: bool = false):
	if deferred:
		object.set_indexed.call_deferred(prop, value)
	else:
		object.set_indexed(prop, value)


##  实例化类场景
##[br]
##[br][code]_class[/code]  这个脚本下的相同脚本名称的场景
##[br][code]callback[/code]  创建节点完成后时回调的方法，这个方法需要有一个 [Node] 类型的参数接收创建的节点
##[br][code]return[/code]  返回实例化后的场景
##[codeblock]
##NodeUtil.instance_class_scene(Item, func(item: Item):
##    Engine.get_main_loop().current_scene.add_child(item)
##)
##[/codeblock]
##[br]
##[br][b]注意：这个脚本名和场景名必须相同！[/b]
static func instance_class_scene(_class: Script, callback: Callable = Callable()) -> Node:
	var data = DataUtil.singleton_dict("ObjectUtil_instance_scene_script_scene_map")
	var scene = DataUtil.get_value_or_set(data, _class, func():
		var path = ScriptUtil.get_object_script_path(_class).get_basename() + ".tscn"
		if ResourceLoader.exists(path):
			return load(path)
		push_error("没有 <class: %s, path: %s> 的场景" % [_class, path])
		return null
	) as PackedScene
	if scene:
		var node = scene.instantiate()
		if callback.is_valid():
			callback.call(node)
		return node
	return null


## 对象是 null
static func is_null(object: Object) -> bool:
	return object == null

## 对象不是 null
static func non_null(object: Object) -> bool:
	return object != null

## 这个数据是否为空
static func is_empty(data) -> bool:
	if data == null:
		return true
	elif data is Array or data is String or data is Dictionary or data is Image:
		return data.is_empty()
	elif data is int or data is float:
		return data == 0
	elif data is Texture2D:
		return data.get_image() == null or data.get_image().is_empty()
	elif data is Callable:
		return data.is_null()
	elif data is Vector2 or data is Vector2i:
		return Vector2(data) == Vector2.ZERO
	elif data is Rect2 or data is Rect2i:
		return Rect2(data).size == Vector2.ZERO
	else:
		if data:
			return false
		else:
			return true

## 获取空间状态
static func get_direct_space_state_2d() -> PhysicsDirectSpaceState2D:
	var node = Engine.get_main_loop().current_scene
	if node is Node2D:
		var world := node.get_world_2d() as World2D
		return world.direct_space_state
	return null

static func get_property(object: Object, property: String):
	return object[property]


## 属性值是否相同
static func property_equals(object, property, value) -> bool:
	return object[property] == value

## 连接方法
static func connect_if(_signal:Signal, callback: Callable, flags: int = 0):
	if not _signal.is_connected(callback):
		_signal.connect(callback, flags)

## 断开连接方法
static func disconnect_if(_signal:Signal, callback: Callable):
	if _signal.is_connected(callback):
		_signal.disconnect(callback)


static func is_valids(objects: Array) -> bool:
	for object in objects:
		if not is_instance_valid(object):
			return false
	return true

## 对象都是有效的
static func is_valid(object: Object) -> bool:
	return is_instance_valid(object)

## 是这个类
static func is_this_class(object: Object, _class_or_class_name) -> bool:
	var _class_object 
	if _class_or_class_name is Object:
		_class_object = _class_or_class_name
	elif _class_or_class_name is String or _class_or_class_name is StringName:
		_class_object = ScriptUtil.get_class_object(_class_or_class_name)
	elif _class_or_class_name is int:
		_class_object = _class_or_class_name
	else:
		assert(false, "错误的参数类型")
	return is_instance_of(object, _class_object)

## 调用方法
static func call_method(object: Object, method: String, arg_array: Array = []):
	return object.callv(method, arg_array)
