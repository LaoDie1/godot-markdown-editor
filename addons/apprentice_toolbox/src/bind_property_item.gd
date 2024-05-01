#============================================================
#    Bind Property Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-29 13:14:59
# - version: 4.3.0.dev5
#============================================================
## 绑定属性项
##
##绑定属性后，设置修改这个项，会自动更新绑定的所有对象的属性。
class_name BindPropertyItem
extends RefCounted


signal value_changed(previous, value)

const META_KEY = &"_PropertyBindItem_value"

var _name: String
var _method_list : Array = []
var _value
var _last


#============================================================
#  内置
#============================================================
func _init(name: String, value = null) -> void:
	_name = name
	_value = value


#============================================================
#  自定义
#============================================================
## 获取当前属性名
func get_name() -> String:
	return _name

## 值相同
func equals_value(value) -> bool:
	return typeof(_value) == typeof(value) and _value == value

## 绑定对象属性到当前属性
func bind_property(object: Object, property: String, update: bool = false) -> BindPropertyItem:
	bind_method( object.set.bind(property) )
	if update and equals_value(object[property]):
		object.set(property, _value)
	return self

## 绑定方法
func bind_method(method: Callable, update: bool = false):
	_method_list.append(method)
	if update:
		method.call(_value)

## 绑定信号到当前属性。这个信号需要有一个参数，接收改变的值
func bind_signal(_signal: Signal) -> BindPropertyItem:
	_signal.connect(update)
	return self

## 断开绑定属性
func unbind_property(object: Object, property: String):
	for method:Callable in _method_list:
		if object.set == method and method.get_bound_arguments()[0] == property:
			_method_list.erase(method)
			break

## 更新属性
func update(value) -> void:
	if not equals_value(value):
		# 设置属性
		for method:Callable in _method_list:
			method.call(value)
		_last = _value
		_value = value
		value_changed.emit(_last, value)

## 获取属性值
func get_value(default = null):
	if typeof(_value) == TYPE_NIL:
		return default
	return _value

## 获取最后一次修改的值
func get_last_value(default = null):
	if typeof(_last) == TYPE_NIL:
		return default
	return _last

