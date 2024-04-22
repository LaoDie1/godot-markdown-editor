#============================================================
#    Property Wrapper
#============================================================
# - datetime: 2023-01-31 21:06:40
#============================================================
## 属性包装器，通过包装一下需要多个代码才能获取到个属性的方式，简化操作
class_name PropertyWrapper


class PropertyWrapperObject:
	var _set_callable: Callable
	var _get_callable: Callable
	
	func set_value(v) -> void:
		_set_callable.call(v)
	
	func add_value(v):
		if v is bool:
			v = 1 if v else -1
		set_value(get_value() + v)
	
	func sub_value(v):
		if v is bool:
			v = 1 if v else -1
		set_value(get_value() - v)
	
	func get_value():
		return _get_callable.call()
	
	func get_as_bool() -> bool:
		return bool(get_value())
	
	func get_as_int() -> int:
		return int(get_value())
	
	func get_as_float() -> float:
		return float(get_value())
	
	func get_as_string() -> String:
		return str(get_value())
	
	func get_as_array() -> Array:
		return Array(get_value())
	
	func get_as_dictionary() -> Dictionary:
		return Dictionary(get_value())
	
	func get_as_vector2()-> Vector2:
		return Vector2( get_value() )
	
	func get_as_vector2i()-> Vector2i:
		return Vector2i( get_value() )
	
	func get_as_resource() -> Resource:
		return get_value() as Resource
	
	func get_as_script() -> Script:
		return get_value() as Script
	
	## 自增1，值类型需要是 int 或 float 类型才行
	func incr():
		set_value(int(get_value()) + 1)
	
	## 自减1，值类型需要是 int 或 float 类型才行
	func decr():
		set_value(int(get_value()) - 1)
	


class SetterWrapperObject:
	var _set_callable: Callable
	
	func set_value(v) -> void:
		_set_callable.call(v)
	


class GetterWrapperObject:
	var _get_callable: Callable
	
	func get_value():
		return _get_callable.call()
	
	func get_as_bool() -> bool:
		return bool(get_value())
	
	func get_as_int() -> int:
		return int(get_value())
	
	func get_as_float() -> float:
		return float(get_value())
	
	func get_as_string() -> String:
		return str(get_value())
	
	func get_as_array() -> Array:
		return Array(get_value())
	
	func get_as_dictionary() -> Dictionary:
		return Dictionary(get_value())
	
	func get_as_vector2()-> Vector2:
		return Vector2( get_value() )
	
	func get_as_vector2i()-> Vector2i:
		return Vector2i( get_value() )
	
	func get_as_resource() -> Resource:
		return get_value() as Resource
	
	func get_as_script() -> Script:
		return get_value() as Script


##  包装属性 Set、Get 方法
##[br]
##[br][code]set_callable[/code]  设置属性方法，这个方法需要有一个参数接收设置的数据
##[br][code]get_callable[/code]  获取数据方法，这个方法需要返回一个要获取的数据
##[br]
##[br][code]return[/code]  返回包装器对象
static func wrap_property(set_callable: Callable, get_callable: Callable) -> PropertyWrapperObject:
	var wrapper = PropertyWrapperObject.new()
	wrapper._set_callable = set_callable
	wrapper._get_callable = get_callable
	return wrapper


##  包装属性 Get 方法
##[br]
##[br][code]get_callable[/code]  获取属性方法，这个方法没有参数
##[br][code]return[/code]  返回包装器
static func wrap_getter(get_callable: Callable) -> GetterWrapperObject:
	var wrapper = GetterWrapperObject.new()
	wrapper._get_callable = get_callable
	return wrapper


##  包装属性 Set 方法
##[br]
##[br][code]set_callable[/code]  设置属性方法
##[br][code]return[/code]  返回包装器
static func wrap_setter(set_callable: Callable) -> SetterWrapperObject:
	var wrapper = SetterWrapperObject.new()
	wrapper._set_callable = set_callable
	return wrapper


