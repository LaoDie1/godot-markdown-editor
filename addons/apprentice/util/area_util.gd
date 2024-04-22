#============================================================
#    Area Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-02-13 10:09:42
# - version: 4.0
#============================================================
class_name AreaUtil


enum {
	DetectArea = 1 << 0,
	DetectBody = 1 << 1,
}


##  连接area和body进入
##[br]
##[br][code]area[/code]  区域节点
##[br][code]callable[/code]  调用的方法，这个方法需要一个 [CollisionObject2D] 类型的参数接收数据
static func connect_entered(
	area: Area2D, 
	callable: Callable, 
	condition : Callable = Callable(),
	detect: int = DetectArea | DetectBody
) -> void:
	if detect & DetectArea == DetectArea:
		area.area_entered.connect(func(node):
			if not condition.is_valid() or condition.call(node):
				callable.call(node)
		)
	if detect & DetectBody == DetectBody:
		area.body_entered.connect(func(node):
			if not condition.is_valid() or condition.call(node):
				callable.call(node)
		)


##  连接area和body退出
##[br]
##[br][code]area[/code]  区域节点
##[br][code]callable[/code]  调用的方法。这个方法需要一个 [CollisionObject2D] 类型的参数接收数据
static func connect_exited(
	area: Area2D, 
	callable: Callable, 
	condition : Callable = Callable(),
	detect: int = DetectArea | DetectBody
) -> void:
	if detect & DetectArea == DetectArea:
		area.area_exited.connect(func(node):
			if not condition.is_valid() or condition.call(node):
				callable.call(node)
		)
	if detect & DetectBody == DetectBody:
		area.body_exited.connect(func(node):
			if not condition.is_valid() or condition.call(node):
				callable.call(node)
		)


##  连接区域的碰撞形状的进入
##[br]
##[br][code]area[/code]  区域节点
##[br][code]callable[/code]  调用的方法。这个方法需要一个 [Node2D] 类型参数接收碰撞到的对象数据
##和一个 [Node2D] 类型的参数接收撞形状对象的数据
static func connect_shape_entered(
	area: Area2D, callable: Callable, 
	detect_area: bool = true, 
	detect_body: bool = true
) -> void:
	var shape_entered = func(
		rid: RID, node: Node2D, 
		shape_index: int, 
		local_shape_index: int
	):
		# 获取碰撞形状
		var owner_id = node.shape_find_owner(local_shape_index)
		var collection = node.shape_owner_get_owner(owner_id)
		callable.call(node, collection)
	if detect_area:
		area.area_shape_entered.connect(shape_entered)
	if detect_body:
		area.body_shape_entered.connect(shape_entered)


##  连接区域的碰撞形状的退出
##[br]
##[br][code]area[/code]  区域节点
##[br][code]callable[/code]  调用的方法。这个方法需要两个参数：
## - node  [Node2D] 类型参数接收碰撞到的对象数据
## - shape_ownershape_owner [Object] 类型的参数接收撞形状对象的数据
static func connect_shape_exited(
	area: Area2D, callable: Callable, 
	detect_area: bool = true, 
	detect_body: bool = true
) -> void:
	var shape_exited = func(
		rid: RID, node: Node2D, 
		shape_index: int, local_shape_index: int
	):
		# 获取碰撞形状
		var owner_id = node.shape_find_owner( local_shape_index)
		var collection = node.shape_owner_get_owner(owner_id)
		callable.call(node, collection)
	if detect_area:
		area.area_shape_exited.connect(shape_exited)
	if detect_body:
		area.body_shape_exited.connect(shape_exited)


##  重叠的节点回调,对在这个区域里的节点进行处理
##[br]
##[br][code]area[/code]  区域对象列表
##[br][code]callable[/code]  对这些节点的回调方法，这个方法要有一个 [Node] 类型的参数
static func overlapping_callable(area: Area2D, callable: Callable) -> void:
	for a in area.get_overlapping_areas():
		callable.call(a)
	for b in area.get_overlapping_bodies():
		callable.call(b)
