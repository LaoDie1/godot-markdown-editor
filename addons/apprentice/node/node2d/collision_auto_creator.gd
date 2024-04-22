#============================================================
#    Collision Auto Create
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-11 14:38:24
# - version: 4.x
#============================================================
## 自动创建碰撞形状
##
@tool
class_name CollisionAutoCreator
extends Node2D


@export
var update : bool = false:
	set(v):
		update = false
		update_collision()
## 图像目标
@export_node_path("Sprite2D", "TextureRect", "AnimatedSprite2D")
var target : NodePath:
	set(v):
		target = v
		target_node = get_node_or_null(target)
## 创建到这个对象身上
@export_node_path("CollisionObject2D")
var create_to : NodePath:
	set(v):
		create_to = v
		create_to_node = get_node_or_null(create_to)


var _updated : bool = false

var target_node : Node
var create_to_node : Node 


##  更新生成碰撞
func update_collision():
	if _updated:
		return
	
	if not Engine.is_editor_hint():
		_updated = true
		await Engine.get_main_loop().process_frame
		_updated = false
	
	if not self.is_inside_tree():
		await tree_entered
	if create_to_node == null:
		create_to_node = get_node_or_null(create_to)
	if target_node == null:
		target_node = get_node_or_null(target)
	
	if create_to_node != null and target_node != null:
		var texture : Texture2D
		if target_node is Sprite2D or target_node is TextureRect:
			texture = target_node.texture
		elif target_node is AnimatedSprite2D:
			texture = TextureUtil.get_animated_sprite_current_frame(target_node)
		else:
			printerr("错误的节点目标")
			return
		
		if texture:
			if texture is AtlasTexture:
				texture = texture.atlas
			
			var coll = CollisionUtil.create_collision_polygon_from_image(texture.get_image(), target_node, 0)
			create_to_node.add_child(coll, true)
			if Engine.is_editor_hint():
				if create_to_node.owner != null:
					coll.owner = create_to_node.owner
				else:
					coll.owner = create_to_node
				print("已创建：", coll)
			
			if target_node is Sprite2D or target_node is AnimatedSprite2D:
				if target_node.centered:
					for i in coll.polygon.size():
						coll.polygon[i] = coll.polygon[i] - texture.get_size() / 2.0 + target_node.offset
					
			
		else:
			printerr("目标没有图像")
		
	else:
		printerr('没有设置目标或创建到的节点')


