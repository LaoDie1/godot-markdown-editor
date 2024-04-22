#============================================================
#    Layer Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-09 22:44:33
# - version: 4.x
#============================================================
## 层级判断工具
class_name LayerUtil


##  是否在这个碰撞层中
static func is_in_layer(node: CollisionObject2D, layer: int) -> bool:
	return node.collision_layer & layer == layer

##  是否在这个碰撞掩码中
static func is_in_mask(node: CollisionObject2D, mask: int) -> bool:
	return node.collision_mask & mask == mask

##  减去这一层碰撞
static func sub_layer(node: CollisionObject2D, layer: int):
	node.collision_layer -= (node.collision_layer & layer)

##  减去这一层掩码
static func sub_mask(node: CollisionObject2D, mask: int):
	node.collision_mask -= (node.collision_mask & mask)

##  加上这一层碰撞
static func add_layer(node: CollisionObject2D, layer: int):
	node.collision_layer |= layer

##  加上这一层掩码
static func add_mask(node: CollisionObject2D, mask: int):
	node.collision_mask |= mask


