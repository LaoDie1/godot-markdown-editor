#============================================================
#    Math Util
#============================================================
# - datetime: 2022-12-21 22:53:39
#============================================================
## 数学工具
class_name MathUtil


const INT_MIN : int = -2 ** 63 
const INT_MAX : int = 2 ** 63 - 1  #0x7FFFFFFFFFFFFFFF
const FLOAT_MIN : float = -1.79769e308
const FLOAT_MAX : float = 1.79769e308
const VECTOR2_MIN : Vector2 = -Vector2.INF
const VECTOR2_MAX : Vector2 = Vector2.INF
const VECTOR2I_MIN : Vector2i = -Vector2i(2 ** 31 - 1, 2 ** 31 - 1)
const VECTOR2I_MAX : Vector2i = Vector2i(2 ** 31 - 1, 2 ** 31 - 1)
#const INF = INF # 默认已有INF 无穷大 ∞


const DIRECTION_TO_NAME : Dictionary = {
	Vector2.UP + Vector2.LEFT: &"TOP_LEFT",
	Vector2.UP: &"TOP",
	Vector2.UP + Vector2.RIGHT: &"TOP_RIGHT",
	
	Vector2.ZERO: &"CENTER",
	Vector2.LEFT: &"LEFT",
	Vector2.RIGHT: &"RIGHT",
	
	Vector2.DOWN + Vector2.RIGHT: &"BOTTOM_RIGHT",
	Vector2.DOWN: &"BOTTOM",
	Vector2.DOWN + Vector2.LEFT: &"BOTTOM_LEFT",
}

const NAME_TO_DIRECTION : Dictionary = {
	# 顶部
	&"TOP_LEFT": Vector2.LEFT + Vector2.UP,
	&"TOP": Vector2.UP,
	&"TOP_RIGHT": Vector2.RIGHT + Vector2.UP,
	
	# 中间
	&"CENTER": Vector2.ZERO,
	&"ZERO": Vector2.ZERO,
	&"LEFT": Vector2.LEFT,
	&"RIGHT": Vector2.RIGHT,
	
	# 底部
	&"BOTTOM_RIGHT": Vector2.RIGHT + Vector2.DOWN,
	&"BOTTOM": Vector2.DOWN,
	&"BOTTOM_LEFT": Vector2.LEFT + Vector2.DOWN,
}

## 获取方向名称
static func get_direction_as_name(direction: Vector2) -> StringName:
	return DIRECTION_TO_NAME.get(direction, &"NULL")

## 获取这个名称的方向
static func get_direction_by_name(name: StringName) -> Vector2:
	return NAME_TO_DIRECTION.get(name, Vector2.INF)

static func distance_to(from: Vector2, to: Vector2) -> float:
	return from.distance_to(to)

static func distance_squared_to(from: Vector2, to: Vector2) -> float:
	return from.distance_squared_to(to)

static func direction_to(from: Vector2, to: Vector2) -> Vector2:
	return from.direction_to(to)

static func angle_to_point(from: Vector2, to: Vector2) -> float:
	return from.angle_to_point(to)

##  反弹
##[br]
##[br][code]velocity[/code]  移动向量或移动方向
##[br][code]from[/code]  当前对象的位置
##[br][code]to[/code]  撞到的目标位置
static func bounce_to( velocity: Vector2, from: Vector2, to: Vector2 ):
	var dir = direction_to(from, to)
	
	
	
	return velocity.bounce(dir)

static func get_four_directions_i() -> Array[Vector2i]:
	return [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]

static func get_eight_directions_i() -> Array[Vector2i]:
	return [Vector2i.LEFT, Vector2i(-1, -1), Vector2i.UP, Vector2i(1, -1), Vector2i.RIGHT, Vector2i(1, 1), Vector2i.DOWN, Vector2(-1, 1)]

static func get_four_directions() -> Array[Vector2]:
	return [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

static func get_eight_directions() -> Array[Vector2]:
	return [Vector2.LEFT, Vector2(-1, -1), Vector2.UP, Vector2(1, -1), Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1)]

static func get_nine_grid_coords() -> Array[PackedVector2Array]:
	return [
		[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)],
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
		[Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)],
	]

static func get_nine_directions() -> Array[Vector2]:
	return Array(DIRECTION_TO_NAME.keys(), TYPE_VECTOR2, "", null)

static func is_rect_edge(coord: Vector2, rect: Rect2, margin: float = 0) -> bool:
	return (
		coord.x == rect.position.x + margin 
		or coord.y == rect.position.y - 1 - margin
		or coord.x == rect.end.x - margin
		or coord.y == rect.end.y-1 + margin
	)

static func is_in_rect( coord: Vector2, rect: Rect2 ) -> bool:
	return rect.has_point(coord)


static func diff_length(velocity: Vector2, diff_length_value: float) -> Vector2:
	return velocity.limit_length(velocity.length() - diff_length_value)


static func is_in_range(value: float, min_value: float, max_value: float) -> bool:
	return value >= min_value and value <= max_value


## 参数来自节点类
class FromNode:
	
	static func diff_position(from: Node2D, to: Node2D) -> Vector2:
		return to.global_position - from.global_position
	
	static func distance_to(from: Node2D, to: Node2D) -> float:
		return from.global_position.distance_to(to.global_position)

	static func direction_to(from: Node2D, to: Node2D) -> Vector2:
		return from.global_position.direction_to(to.global_position)

	static func angle_to(from: Node2D, to: Node2D) -> float:
		return from.global_position.angle_to(to.global_position)

	static func angle_to_point(from: Node2D, to: Node2D) -> float:
		return from.global_position.angle_to_point(to.global_position)
	
	static func direction_x(from: Node2D, to: Node2D) -> Vector2:
		return Vector2(to.global_position.x - from.global_position.x, 0)
	
	static func direction_y(from: Node2D, to: Node2D) -> Vector2:
		return Vector2(0, to.global_position.y - from.global_position.y)
	
	static func distance_x(from: Node2D, to: Node2D) -> float:
		return abs(from.global_position.x - to.global_position.x)
	
	static func distance_y(from: Node2D, to: Node2D) -> float:
		return abs(from.global_position.y - to.global_position.y)
	
	static func distance_v(from: Node2D, to: Node2D) -> Vector2:
		return (from.global_position - to.global_position).abs()
	
	static func is_in_distance(from: Node2D, to: Node2D, max_distance: float) -> bool:
		return from.global_position.distance_squared_to(to.global_position) <= pow(max_distance, 2)
	
	static func bounce_to( velocity: Vector2, from: Node2D, to: Node2D ):
		var dir = direction_to(from, to)
		return velocity.bounce(dir)
	
	##  移动后的向量
	##[br]
	##[br][code]target[/code]  目标节点
	##[br][code]vector[/code]  移动向量值
	##[br][code]return[/code]  返回移动后的位置
	static func move(target: Node2D, velocity: Vector2) -> Vector2:
		return target.global_position + velocity
	
	## 获取距离最近的节点
	static func get_closest_node(target_position: Vector2, nodes: Array) -> Node:
		if nodes.is_empty():
			return null
		nodes = nodes.filter(func(obj): return is_instance_valid(obj))
		if nodes.is_empty():
			return null
		if nodes.size() == 1:
			return nodes[0]
		var last_dist : float = INF
		var tmp_dist : float = 0.0
		var node : Node = null
		for child in nodes:
			tmp_dist = target_position.distance_squared_to(child.get_global_position())
			if last_dist > tmp_dist:
				last_dist = tmp_dist
				node = child
		return node


## 获取最近的点位置
static func get_closet_points(from: Vector2, points: Array) -> Vector2:
	if points.is_empty():
		return from
	if points.size() == 1:
		return points[0]
		
	var last_dist : float = INF
	var tmp_dist : float = 0.0
	var p : Vector2
	for point in points:
		tmp_dist = from.distance_squared_to(point)
		if last_dist > tmp_dist:
			last_dist = tmp_dist
			p = point
	return p


## 在距离之内
static func is_in_distance(from: Vector2, to: Vector2, max_distance: float) -> bool:
	return from.distance_squared_to(to) <= pow(max_distance, 2)


##  返回对应概率的值
##[br]
##[br][code]param[/code]  概率数据。value为随机值，key为对应的数据。示例：
##[codeblock]
##rand_probability({
##    "a": 0.3,  # 生成 a 的概率为 0.3/总数值
##    "b": 0.9,
##    "c": 0.15,
##    "d": 0.45,
##    "e": 1.2,
##    "f": 0.1,
##})
##[/codeblock]
static func rand_probability(param: Dictionary):
	return RandomProbabilityGenerator.create(param).get_rand_value()


class _RandomVector2:
	# 原始位置
	var _origin: Vector2
	
	func _init(origin_pos: Vector2 = Vector2(0,0)):
		self._origin = origin_pos
	
	## 随机方向。from 开始角度，to 结束角度
	func rand_direction(from: float = -PI, to: float = PI) -> Vector2:
		return Vector2.LEFT.rotated( randf_range(from, to) )
	
	## 随机点位置
	## max_distance 随机的最大距离，min_distance 最小随机距离，
	## from_angle 开始角度，to_angle 到达角度
	func rand_point(max_distance: float, min_distance: float = 0.0, from_angle: float = -PI, to_angle: float = PI) -> Vector2:
		return _origin + rand_direction(from_angle, to_angle) * randf_range(min_distance, max_distance)
	
	## 矩形内随机位置
	func rand_in_rect(rect: Rect2) -> Vector2:
		var x = randf_range( rect.position.x, rect.end.x )
		var y = randf_range( rect.position.y, rect.end.y )
		return _origin + Vector2(x, y)


## 随机 Vector2 值
static func rand_vector2(origin_point: Vector2 = Vector2(0,0)) -> _RandomVector2:
	return _RandomVector2.new(origin_point)

## 位运算 - 存在于
static func bit_contain(number: int, is_in: int) -> bool:
	return (number & is_in) == number

## 位运算 - 相加
static func bit_add(list: Array) -> int:
	var v = 0
	for i in list:
		v |= i
	return v


## rect2 中随机一个位置
static func rand_position_in_rect2(rect: Rect2) -> Vector2:
	var x = randf_range( rect.position.x, rect.end.x )
	var y = randf_range( rect.position.y, rect.end.y )
	return Vector2(x, y)

static func rect2(size: Vector2, position: Vector2 = Vector2()) -> Rect2:
	return Rect2(position, size)

static func rect2i(size: Vector2i, position: Vector2i = Vector2i()) -> Rect2i:
	return Rect2i(position, size)


## 四周角落
static func quadrangle(rect: Rect2) -> Array[Vector2]:
	var top_left = rect.position
	var top_right = Vector2(rect.end.x, rect.position.y)
	var bottom_left = Vector2(rect.position.x, rect.end.y)
	var bottom_right = rect.end
	return Array([top_left, top_right, bottom_left, bottom_right], TYPE_VECTOR2, "", null)

static func quadranglei(rect: Rect2i) -> Array[Vector2i]:
	var top_left = rect.position
	var top_right = Vector2i(rect.end.x, rect.position.y)
	var bottom_left = Vector2i(rect.position.x, rect.end.y)
	var bottom_right = rect.end
	return Array([top_left, top_right, bottom_left, bottom_right], TYPE_VECTOR2I, "", null)


## 获取两个值的中间值
static func get_median_value(from, to):
	assert(typeof(from) == typeof(to), "两个参数的数据类型必须保持一致！")
	if (
		from is float
		or from is int
		or from is Vector2 
		or from is Vector2i
		or from is Vector3
		or from is Vector3i
		or from is Vector4
		or from is Vector4i
		or from is Color
	):
		return (from + to) / 2
	elif from is Rect2 or from is Rect2i:
		from.position += to.position
		from.size += to.size
		
		from.position /= 2
		from.size /= 2
		return from
		
	else:
		assert(false, "不支持的数据类型")


static func is_number(value) -> bool:
	return value is float or value is int


## 找到其中最大的 x 和 y 后的 Vector2
static func get_max_xy(list: Array) -> Vector2:
	var max_v = -Vector2.INF
	for item in list:
		if max_v.x < item.x:
			max_v.x = item.x
		if max_v.y < item.y:
			max_v.y = item.y
	return max_v

## 找到其中最小的 x 和 y 后的 Vector2
static func get_min_xy(list: Array) -> Vector2:
	var min_v = Vector2.INF
	for item in list:
		if min_v.x > item.x:
			min_v.x = item.x
		if min_v.y > item.y:
			min_v.y = item.y
	return min_v

## 根据 Vector2 列表中最大和最小的位置，返回 Rect2
static func get_rect_by_max_min_vector2(list: Array) -> Rect2:
	var min_v = get_min_xy(list)
	var max_v = get_max_xy(list)
	return Rect2(min_v, max_v - min_v)

static func rotated(vector: Vector2, angle: float) -> Vector2:
	return vector.rotated(angle)

static func offset(value, offset_value):
	return value + offset_value

static func offset_array(list: Array, value) -> Array:
	var arr = list.duplicate()
	offset_origin_array(arr, value)
	return arr

## 偏移整个数组，他会修改原数组，而非产生新的数组
static func offset_origin_array(list: Array, value) -> void:
	for idx in list.size():
		list[idx] = list[idx] + value
