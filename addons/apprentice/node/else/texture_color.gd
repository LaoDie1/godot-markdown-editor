#============================================================
#    Texture Color
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-06 21:32:17
# - version: 4.x
#============================================================
## 修改 Texture 颜色
class_name TextureColor
extends Node2D



@export var target : NodePath:
	set(v):
		target = v
		_update_origin_texture()
## 属性类型为 [Texture2D] 的属性名
@export var property : String = "texture":
	set(v):
		property = v
		_update_origin_texture()
@export var from_color : Color = Color.WHITE:
	set(v):
		from_color = v
		if target == ^"": await ready
		_update_from_pixels()
		_update_texture()
		
@export var to_color : Color = Color.BLACK


# 原来的图像
var _origin_texture : Texture2D
# 这个颜色的像素坐标
var _pixels_coord : Array[Vector2i] = []



#============================================================
#  自定义
#============================================================
func _update_origin_texture():
	_origin_texture = null
	if not is_inside_tree(): await ready
	var node = get_node(target)
	if node and property in node:
		_origin_texture = node.get(property)


func _update_from_pixels():
	if _origin_texture != null:
		_pixels_coord.clear()
		var image = _origin_texture.get_image()
		var size = image.get_size()
		var color : Color
		for x in size.x:
			for y in size.y:
				color = image.get_pixel(x, y)
				if color == from_color:
					_pixels_coord.append(Vector2i(x, y))
	else:
		printerr("目标节点的", property, "属性不是 Texture2D 类型！")


func _update_texture() -> void:
	var node = get_node(target)
	if node == null:
		return
	
	var image = _origin_texture.get_image().duplicate() as Image
	for coord in _pixels_coord:
		image.set_pixelv(coord, to_color)
	node.set(property, ImageTexture.create_from_image(image))



