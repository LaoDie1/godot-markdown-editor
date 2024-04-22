#============================================================
#    Collision Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-11 22:34:58
# - version: 4.x
#============================================================
## 碰撞相关工具
class_name CollisionUtil


##  根据图片创建不规则碰撞形状
##[br]
##[br][code]image[/code]  图片
##[br][code]canvas_node[/code]  画布节点。[Sprite2D, AnimatedSprite2D] 中的类型，用于根据节点的属性进行偏移点的坐标
##[br][code]group_idx[/code]  创建出的点位组的列表索引。因为可能一张图片有多个图块，会生成超过一组的点列表
static func create_collision_polygon_from_image(image: Image, canvas_node: Node2D = null, group_idx: int = 0) -> CollisionPolygon2D:
	# 获取图片点
	var bit_map = BitMap.new()
	bit_map.create_from_image_alpha(image)
	var points_list = bit_map.opaque_to_polygons(Rect2(Vector2(), image.get_size()))
	
	# 偏移位置
	var points = points_list[group_idx]
	if canvas_node:
		assert(canvas_node is Sprite2D or canvas_node is AnimatedSprite2D, "画布节点需要是 [Sprite2D, AnimatedSprite2D] 类型的节点")
		var offset_pos : Vector2 = Vector2(0, 0)
		if canvas_node is Sprite2D or canvas_node is AnimatedSprite2D:
			if canvas_node.centered:
				offset_pos = -image.get_size() / 2
			offset_pos += canvas_node.offset
		if offset_pos != Vector2(0,0):
			for i in len(points_list):
				points[i] = points[i] + offset_pos
	
	# 创建碰撞
	var coll = CollisionPolygon2D.new()
	points.remove_at(0)
	coll.polygon = points
	return coll


##  创建圆形碰撞
##[br]
##[br][code]radius[/code]  碰撞范围
##[br][code]add_to[/code]  添加到这个节点上
static func create_circle_collison(radius: float, add_to: Node2D = null) -> CollisionShape2D:
	var collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	collision.shape = circle
	circle.radius = radius
	if add_to:
		add_to.add_child(collision)
	return collision


##  创建正方形碰撞形状
##[br]
##[br][code]size[/code]  形状大小
##[br][code]add_to[/code]  添加到这个节点上
##[br][code]return[/code]  返回这个碰撞形状节点
static func create_rectangle_collision(size: Vector2, add_to: Node2D) -> CollisionShape2D:
	var collision = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = size
	collision.shape = rectangle
	if add_to:
		add_to.add_child(collision)
	return collision


