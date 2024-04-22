#============================================================
#    Property Data Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-20 17:21:03
# - version: 4.0
#============================================================
class_name PropertyDataUtil


## 提示字符串，用于 [method get_range_property] 中的 extra_hints 参数中
enum {
	OrLess = 1 << 0, ## 检查器修改的属性值的步长，可以比最小值更小
	OrGreater = 1 << 1, ## 检查器修改的属性值的步长，可以比最大值更大
	HideSlider = 1 << 2,  ## 检查器修改的值有最大最小范围时，隐藏显示的滚动条
	Exp = 1 << 3, ## 用于指数范围编辑
	Radians = 1 << 4, ## 用于以度数编辑弧度角
	Degrees = 1 << 5, ## 提示一个角度
}



static func _has_value(value: int, enum_value: int) -> bool:
	return value & enum_value == enum_value


##  获取一个属性数据
static func get_property(
	name: String, 
	type: int, 
	hint: int = PROPERTY_HINT_NONE, 
	hint_string: String = ""
) -> Dictionary:
	return {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
	}


## 具有范围的数值属性
##[br]
##[br][code]min_value[/code]  最小值
##[br][code]max_value[/code]  最大值
##[br][code]step[/code]  修改值时值的步长
##[br][code]extra_hints[/code]  额外提示信息值。详见 [enum PROPERTY_HINT_RANGE] 内容，
##提示信息值对应当前的枚举，比如 "or_less" 对应当前的 [enum OrLess] 枚举
##[br][code]suffix_string[/code]  显示的后缀字符串
##[br]示例
##[codeblock]
##PropertyDataUtil.get_range_property(
##    "time", 0, 1, 0.001,  # 设置数值范围
##    PropertyDataUtil.OrGreater | PropertyDataUtil.HideSlider, # 属性检查器显示信息
##    "s" # 显示后缀名
##)
##[/codeblock]
static func get_range_property(
	name: String, 
	min_value: float = -INF, max_value: float = INF, step:float=0.001,
	extra_hints: int = 0,
	suffix_string : String = "",
) -> Dictionary:
	var hint_string = "%s,%s,%s" % [min_value, max_value, step]
	if _has_value(extra_hints, OrGreater):
		hint_string += ",or_greater"
	if _has_value(extra_hints, OrLess):
		hint_string += ",or_less"
	if _has_value(extra_hints, HideSlider):
		hint_string += ",hide_slider"
	if _has_value(extra_hints, Exp):
		hint_string += ",exp"
	if _has_value(extra_hints, Radians):
		hint_string += ",radians"
	if _has_value(extra_hints, Degrees):
		hint_string += ",degrees"
	if suffix_string:
		hint_string += ",suffix:%s" % suffix_string
	
	return {
		"name": name,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": hint_string,
	}


## 枚举值类型的参数数据
##[br]
##[br][code]list[/code]  枚举列表。列表项的格式示例：
##[codeblock]
##[
##    item01,  # 默认枚举值
##    item02:3,  # 指定这个项的枚举值
##]
##[/codeblock]
static func get_enum(name: String, list: Array) -> Dictionary:
	return {
		"name": name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(list),
	}


## FLAGS值类型的参数数据
##[br]
##[br][code]list[/code]  枚举列表
static func get_flags(name: String, list: Array) -> Dictionary:
	return {
		"name": name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": ",".join(list),
	}


##  获取字符串类型数据
##[br]
##[br][code]multiline_text[/code]  
##[br][code]return[/code]  
static func get_string(name: String, multiline_text: bool = false) -> Dictionary:
	var data = {
		"name": name,
		"type": TYPE_STRING
	}
	if multiline_text:
		data["hint"] = PROPERTY_HINT_MULTILINE_TEXT
	return data


##  获取有占位符的字符串
##[br]
##[br][code]placeholder_text[/code]  没有文字时显示的提示信息
static func get_placeholder_string(name: String, placeholder_text: String) -> Dictionary:
	return {
		"name": name,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": placeholder_text,
	}


##  选中一个节点对象的属性
##[br]
##[br][code]node_type[/code]  限制选中的节点的类型
static func get_node_type(name: String, node_type: String = "Node") -> Dictionary:
	return {
		"name": name,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": node_type,
	}


##  选中一个节点路径的属性
##[br]
##[br][code]node_types[/code]  可选中的节点类型列表
static func get_node_path(name: String, node_types: Array = []) -> Dictionary:
	if node_types.is_empty():
		node_types = ["Node"]
	return {
		"name": name,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
		"hint_string": ",".join(node_types),
	}


##  get_type_array
##[br]
##[br][code]types[/code]  节点类型列表。这个列表的最后一个项必须是资源的类型，示例：
##[codeblock]
##get_type_array("String") # “字符串类型”的列表
##get_type_array("String", "String") # “字符串类型的列表”的列表
##[/codeblock]
static func get_type_array(name: String, types: Array) -> Dictionary:
	assert(types.size() >= 1)
	var hint_string : String = "%s:".repeat(types.size()).trim_suffix(":")
	types.push_front(TYPE_ARRAY)
	hint_string += "/%s"
	return {
		"name": name,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string":  hint_string % types,
	}


##  资源类型的属性
##[br]
##[br][code]resource_type[/code]  资源类型名称
static func get_resource(name: String, resource_type: String = "Resource"):
	return {
		"name": name,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": resource_type,
	}


##  选择一个类名的属性
##[br]
##[br][code]type[/code]  
static func get_select_object(name: String) -> Dictionary:
	return {
		"name": name,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
	}


## 获取这个数据类型的默认值
static func get_default_value(type: int):
	match type:
		TYPE_FLOAT: return 0.0
		TYPE_INT: return 0
		TYPE_STRING: return ""
		TYPE_STRING_NAME: return &""
		TYPE_BOOL: return false
		TYPE_NIL, TYPE_OBJECT: return null
		TYPE_VECTOR2: return Vector2()
		TYPE_VECTOR2I: return Vector2i()
		TYPE_RECT2: return Rect2()
		TYPE_RECT2I: return Rect2i()
		TYPE_VECTOR3: return Vector3()
		TYPE_VECTOR3I: return Vector3i()
		TYPE_TRANSFORM2D: return Transform2D()
		TYPE_VECTOR4: return Vector4()
		TYPE_VECTOR4I: return Vector4i()
		TYPE_PLANE: return Plane()
		TYPE_QUATERNION: return Quaternion()
		TYPE_AABB: return AABB()
		TYPE_BASIS: return Basis()
		TYPE_TRANSFORM3D: return Transform3D()
		TYPE_PROJECTION: return Projection()
		TYPE_COLOR: return Color()
		TYPE_STRING_NAME: return StringName()
		TYPE_NODE_PATH: return NodePath()
		TYPE_RID: return RID()
		TYPE_CALLABLE: return Callable()
		TYPE_SIGNAL: return Signal()
		TYPE_DICTIONARY: return Dictionary()
		TYPE_ARRAY: return Array()
		TYPE_PACKED_BYTE_ARRAY: return PackedByteArray()
		TYPE_PACKED_INT32_ARRAY: return PackedInt32Array()
		TYPE_PACKED_INT64_ARRAY: return PackedInt64Array()
		TYPE_PACKED_FLOAT32_ARRAY: return PackedFloat32Array()
		TYPE_PACKED_FLOAT64_ARRAY: return PackedFloat64Array()
		TYPE_PACKED_STRING_ARRAY: return PackedStringArray()
		TYPE_PACKED_VECTOR2_ARRAY: return PackedVector2Array()
		TYPE_PACKED_VECTOR3_ARRAY: return PackedVector3Array()
		TYPE_PACKED_COLOR_ARRAY: return PackedColorArray()

