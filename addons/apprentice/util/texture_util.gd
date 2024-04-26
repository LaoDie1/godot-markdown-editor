#============================================================
#    Texture Util
#============================================================
# - datetime: 2023-02-12 00:16:54
#============================================================
## 与 [Texture] 资源相关处理的方法
class_name TextureUtil


## 图片是否是空的
static func is_empty(image: Image) -> bool:
	return image.is_empty() or image.get_used_rect().size == Vector2i.ZERO


## 区域是否为空图像
static func is_empty_in_region(image: Image, region: Rect2i) -> bool:
	return is_empty(image.get_region(region))


##  根据序列列表
##[br]
##[br][code]data[/code]  图片序列数据列表。数据格式：[code]data[anim_name] = [][/code]
static func generate_sprite_frames(data: Dictionary) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	var idx = 0
	for animation_name in data:
		var sequence = data[animation_name]
		sprite_frames.add_animation(animation_name)
		for atlas_texture in sequence:
			# 如果图片区域为空，则不继续添加后面的列
			if is_empty(atlas_texture.get_image()):
				break
			sprite_frames.add_frame(animation_name, atlas_texture)
			sprite_frames.set_animation_loop(animation_name, false)
			sprite_frames.set_animation_speed(animation_name, 8)
		idx += 1
	
	return sprite_frames


##  根据图片划分成表格生成 [SpriteFrames]
##[br]
##[br][code]texture[/code]  切分的图片
##[br][code]cut_size[/code]  切割的格数大小
##[br][code]cut_direction[/code]  切割方向。详见: [method gene_atlas_textures_by_tile_size]
static func generate_sprite_frames_by_cut_size(
	texture: Texture2D, 
	cut_size: Vector2i, 
	cut_direction: int = VERTICAL
) -> SpriteFrames:
	var tile_size = texture.get_image().get_size() / cut_size
	return gene_frames_by_tile_size(texture, tile_size, cut_direction)


##  固定生成的图片大小生成 [SpriteFrames]
##[br]
##[br][code]texture[/code]  切分的图片
##[br][code]tile_size[/code]  切分后每个图片的大小
##[br][code]cut_direction[/code]  切割方向。详见: [method gene_atlas_textures_by_tile_size]
static func gene_frames_by_tile_size(
	texture: Texture2D, 
	tile_size: Vector2i, 
	cut_direction: int = VERTICAL
) -> SpriteFrames:
	var list = gene_atlas_textures_by_tile_size(texture, tile_size, cut_direction)
	var sprite_frames = generate_sprite_frames(list)
	print("[ TextureUtil ] ", "已生成 SpriteFrames：", sprite_frames)
	return sprite_frames


##  生成 [AtlasTexture] 图片序列列表
##[br]
##[br][code]texture[/code]  生成的贴图
##[br][code]tile_size[/code]  每个图片的大小
##[br][code]cut_direction[/code]  切割方向
##[br]    - [constant @GlobalScope.HORIZONTAL] 水平切割，从左到右的顺序获取一组图片序列
##[br]    - [constant @GlobalScope.VERTICAL] 垂直切割，从上到下的顺序获取一组图片序列
static func gene_atlas_textures_by_tile_size(
	texture: Texture2D, 
	tile_size: Vector2i, 
	cut_direction: int = HORIZONTAL
) -> Array[Array]:
	var image = texture.get_image() as Image
	var grid_size = image.get_size() / tile_size
	
	var x_dir : int
	var y_dir : int
	if cut_direction == HORIZONTAL:
		x_dir = 0
		y_dir = 1
	else:
		x_dir = 1
		y_dir = 0
	
	var list : Array[Array] = []
	for y in grid_size[y_dir]:
		var sequence = []
		for x in grid_size[x_dir]:
			var size = Vector2i()
			size[x_dir] = x
			size[y_dir] = y
			var atlas_texture = gene_atlas_texture(texture, Rect2i(size * tile_size, tile_size))
			sequence.append(atlas_texture)
		list.append(sequence)
	
	return list


## 将那片区域图像转为 [AtlasTexture] 资源
static func gene_atlas_texture(texture: Texture2D, region: Rect2i) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = region
	return atlas_texture


## [Texture2D] 转为多边形的点，返回每个区域生成多边形的点的列表
static func gene_polygon_points(texture: Texture2D) -> Array[PackedVector2Array]:
	var bit_map = BitMap.new()
	bit_map.create_from_image_alpha( texture.get_image() )
	return bit_map.opaque_to_polygons( Rect2i(Vector2i.ZERO, bit_map.get_size()) )
	

## 获取 [AnimatedSprite2D] 当前放的动画的帧的 [Texture]
static func get_animated_sprite_current_frame(animated_sprite: AnimatedSprite2D) -> Texture2D:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return null
	var sprite_frames = animated_sprite.sprite_frames as SpriteFrames
	var animation = animated_sprite.animation
	if animated_sprite.is_playing():
		var frame = animated_sprite.frame
		return sprite_frames.get_frame_texture(animation, frame)
	else:
		return sprite_frames.get_frame_texture(animation, 0)


## 修改图片的 alpha 值
static func set_image_alpha(image: Image, alpha: float) -> Image:
	var image_size = image.get_size()
	var color : Color
	for x in image_size.x:
		for y in image_size.y:
			color = image.get_pixel(x, y)
			if color.a > 0:
				# 修改图片的 alpha 值
				color.a = alpha
				image.set_pixel(x, y, color)
	return image


## 图片混合。根据 b_ratio 修改图片的 alpha 展现 b 图片颜色清晰度
static func blend_image_alpha(a: Image, b: Image, b_ratio: float) -> Image:
	assert(b_ratio >= 0 and b_ratio <= 1.0, "比值必须在 0 - 1 之间！")
	var a_image = set_image_alpha(a, 1 - b_ratio) as Image
	var b_image = set_image_alpha(b, b_ratio) as Image
	a_image.blend_rect(
		b_image, 
		Rect2i(Vector2i(0,0), b_image.get_size()), 
		Vector2i(0,0)
	)
	return a_image


## Atlas 类型的贴图转为 Image
static func atlas_to_image(texture: AtlasTexture) -> Image:
	var p_t = texture.atlas as Texture2D
	return p_t.get_image().get_region( texture.region )


## 获取可用的大小范围的图片
static func get_used_rect_image(texture: Texture2D) -> Texture2D:
	var image = texture.get_image()
	if image:
		var rect = image.get_used_rect()
		var new_image = Image.create(rect.size.x, rect.size.y, image.has_mipmaps(), image.get_format())
		new_image.blit_rect(image, rect, Vector2i(0,0))
		return ImageTexture.create_from_image(new_image)
	return null


## 获取节点的 [Texture2D]
static func get_node_texture(node: CanvasItem) -> Texture2D:
	var texture : Texture2D 
	if node is AnimatedSprite2D:
		texture = TextureUtil.get_animated_sprite_current_frame(node)
	elif node is Sprite2D or node is TextureRect:
		texture = node.texture
	else:
		print("不是 [AnimatedSprite2D, Sprite2D, TextureRect] 中的类型！")
		return null
	return texture


##  重置大小
##[br]
##[br][code]texture[/code]  贴图
##[br][code]new_size[/code]  新的大小
##[br][code]interpolation[/code]  插值。影响图像的质量
##[br][code]return[/code]  返回新的 [Texture2D]
static func resize_texture(
	texture: Texture2D, 
	new_size: Vector2i
) -> Texture2D:
	var image = Image.new()
	image.copy_from(texture.get_image())
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


## 创建新的图像
static func create_from_image(image: Image) -> Image:
	var new_image = Image.new()
	new_image.copy_from(image)
	return new_image

## 创建新的这个 Texture 图片
static func create_from_texture(texture: Texture2D) -> Image:
	return create_from_image(texture.get_image())


## 创建一个纯色图片
static func create_texture_by_color(size: Vector2, fill_color: Color) -> ImageTexture:
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill_color)
	return ImageTexture.create_from_image(image)


class _PreviewReceiver:
	
	static func preview(path: String, preview_texture: Texture2D, thumbnail_preview: Texture2D, userdata: Callable):
		userdata.call(preview_texture)



##  预览场景图片
##[br]
##[br][code]scene[/code]  预览的场景。这个场景在渲染的时候会添加到场景中，请确保这个场景加载不是很慢的速度
##[br][code]callback[/code]  回调方法，需要一个 [ImageTexture] 参数接收渲染后的图片
static func preview_scene(scene: PackedScene, callback: Callable) -> void:
	# 视图节点
	var viewport = SubViewport.new()
	viewport.name = "__preview_vieport_%s" % [viewport.get_instance_id()]
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.transparent_bg = true
	viewport.size = Engine.get_main_loop().root.size
	
	var instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	if instance.get_script() != null and ((instance.get_script() as GDScript).is_tool()):
		EditorInterface \
			.get_resource_previewer() \
			.queue_edited_resource_preview(scene, _PreviewReceiver, "preview", callback)
	
	else:
		viewport.add_child(instance)
		
		if instance is CanvasItem:
			instance.position = Engine.get_main_loop().root.size / 2
		Engine.get_main_loop().root.add_child(viewport)
		
		# 视图显示 Texture2D
		var viewport_texture = ViewportTexture.new()
		viewport_texture.viewport_path = viewport.get_path_to(Engine.get_main_loop().root)
		RenderingServer.frame_post_draw.connect(func():
			# 渲染后进行图像回调
			var image : Image = viewport.get_texture().get_image()
			if image.is_empty() or image.get_used_rect().size == Vector2i.ZERO:
				callback.call(EditorUtil.get_editor_theme_icon("PackedScene"))
			else:
				image = image.get_region(image.get_used_rect())
				callback.call(ImageTexture.create_from_image(image))
				viewport.queue_free()
		, Object.CONNECT_ONE_SHOT)


## 描边
##[br]
##[br][code]texture[/code]  描边的图像
##[br][code]outline_color[/code]  描边颜色
##[br][code]threshold[/code]  透明度阈值范围，如果这个颜色周围的颜色在这个范围内，则进行描边
##[br][code]return[/code]  返回生成后的图片
static func outline(
	texture: Texture2D, 
	outline_color: Color, 
	threshold: float = 0.0, 
) -> Texture2D:
	if texture == null:
		return null
	var image = texture.get_image()
	if image == null:
		return null
	
	var offset : Vector2
	var size : Vector2
	
	# 遍历阈值内的像素
	var color : Color
	var empty_pixel_set : Dictionary = {}
	for x in range(0, image.get_size().x):
		for y in range(0, image.get_size().y):
			color = image.get_pixel(x, y)
			if color.a <= threshold:
				empty_pixel_set[Vector2i(x, y)] = null
	
	# 开始描边
	var new_image := Image.create(image.get_width(), image.get_height(), image.has_mipmaps(), Image.FORMAT_RGBA8)
	new_image.copy_from(image)
	
	var coordinate : Vector2i
	for x in range(0, image.get_size().x):
		for y in range(0, image.get_size().y):
			coordinate = Vector2i(x, y)
			if not empty_pixel_set.has(coordinate):
				# 判断周围上下左右是否有阈值内的透明度像素
				for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					if empty_pixel_set.has(coordinate + dir):
						# 设置新图像的描边
						new_image.set_pixelv(coordinate + dir, outline_color)
	
	return ImageTexture.create_from_image(new_image)
