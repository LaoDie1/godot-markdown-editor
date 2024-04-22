#============================================================
#    Counter
#============================================================
# - datetime: 2023-01-31 00:01:10
#============================================================
## 计数器。也可以当做一个自增ID使用
class_name Counter


class Base:
	var _count = 0
	
	func incr(value):
		_count += value
		return _count
	
	func decr(value):
		_count -= value
		return _count
	
	func get_value():
		return _count


class IntCounter:
	extends Base
	
	func incr(value: int = 1) -> int:
		return super.incr(value) as int
	
	func decr(value: int = 1) -> int:
		return super.decr(value) as int
	
	func get_value() -> int:
		return int(_count)


class FloatCounter:
	
	extends Base
	
	func incr(value: float = 1.0) -> float:
		return super.incr(value) as float

	func decr(value: float = 1.0) -> float:
		return super.decr(value) as float

	func get_value() -> float:
		return float(_count)


class BoolCounter:
	extends Base
	
	func incr(value: int = 1) -> bool:
		return bool(super.incr(value))
	
	func decr(value: int = 1) -> bool:
		return bool(super.decr(value))
	
	func get_value() -> float:
		return bool(_count)
	


func _init() -> void:
	assert(false, "不要使用 new 方法创建这个对象，请使用 get_instance 方法创建！")


##  获取一个计数器实例
##[br]
##[br][code]init_value[/code]  初始化的值
##[br][code]type[/code]  计数器类型。[constant TYPE_INT]、[constant TYPE_FLOAT]、[constant TYPE_BOOL]
##[br][code]return[/code]  返回对应类型的计数器
static func get_instance(init_value = 0, type : int = TYPE_INT) -> Base:
	var base : Base
	if type == TYPE_INT:
		base = IntCounter.new()
		base._count = int(init_value)
	elif type == TYPE_FLOAT:
		base = FloatCounter.new()
		base._count = float(init_value)
	elif type == TYPE_BOOL:
		base = BoolCounter.new()
		base._count = int(init_value)
	else:
		printerr("错误的类型！只能是 TYPE_INT/TYPE_FLOAT/TYPE_BOOL！")
		return null
	return base

