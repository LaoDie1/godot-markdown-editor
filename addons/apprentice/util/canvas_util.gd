#============================================================
#    Canvas Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-12 18:05:05
# - version: 4.x
#============================================================
class_name CanvasUtil


## 让节点旋转到目标点
##[br]
##[br][code]node[/code]  设置旋转的目标
##[br][code]from[/code]  开始位置
##[br][code]to[/code]  旋转到位置
##[br][code]offset[/code]  旋转偏移位置
static func rotate_to(node: Node2D, from: Vector2, to: Vector2, offset: float = 0.0) -> void:
	node.global_rotation = to.angle_to_point(from) + offset


## 获取节点显示的图像的缩放大小
static func get_canvas_scale(node: CanvasItem) -> Vector2:
	return Vector2(get_canvas_size(node)) * node.scale


## 获取节点显示的图像的大小
static func get_canvas_size(node: CanvasItem) -> Vector2i:
	var texture := TextureUtil.get_node_texture(node) as Texture2D
	if texture:
		var image = texture.get_image() as Image
		return image.get_size()
	return Vector2i(0, 0)


## 获取两个节点的大小差异
static func get_canvas_scale_diff(node_a: Node2D, node_b: Node2D) -> Vector2:
	var scale_a = CanvasUtil.get_canvas_scale(node_a)
	var scale_b = CanvasUtil.get_canvas_scale(node_b)
	return scale_a / scale_b


##  根据 [AnimatedSprite2D] 当前的 frame 创建一个 [Sprite2D]
##[br]
##[br][code]animation_sprite[/code]  [AnimatedSprite2D] 类型的节点
##[br][code]return[/code]  返回一个 [Sprite2D] 节点
static func create_sprite_by_animated_sprite_current_frame(animation_sprite: AnimatedSprite2D) -> Sprite2D:
	var anim = animation_sprite.animation
	var idx = animation_sprite.frame
	var texture = animation_sprite.sprite_frames.get_frame_texture(anim, idx)  
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.global_position = animation_sprite.global_position
	sprite.offset = animation_sprite.offset
	return sprite


## 获取 [SpriteFrames] 的动画的播放时长
##[br]
##[br][code]animations[/code]  动画名
static func get_sprite_frames_anim_time(sprite_frames: SpriteFrames, animation: StringName) -> float:
	if sprite_frames:
		var count = sprite_frames.get_frame_count(animation)
		var speed = 1.0 / sprite_frames.get_animation_speed(animation)
		return speed * count
	return 0.0


##  更新动画时间。每个动画帧的 fps 时长
##[br]
##[br][code]frames[/code]  动画资源
##[br][code]animation[/code]  动画名
##[br][code]total_time[/code]  总播放时间
static func update_frames_time(
	frames: SpriteFrames, 
	animation: StringName, 
	total_time: float
) -> Error:
	if frames.has_animation(animation):
		var frame_count = frames.get_frame_count(animation)
		var fps = frame_count / total_time
		frames.set_animation_speed(animation, fps)
		return OK
	else:
		push_error("没有这个动画")
		return ERR_DOES_NOT_EXIST


## 设置 AnimatedSprite2D 节点的动画播放速度。根据这个节点的动画帧和设置的持续时间，设置播放速度
static func update_animated_speed_scale(animated_sprite: AnimatedSprite2D, anim_name: StringName, time: float) -> Error:
	var sprite_frames = animated_sprite.sprite_frames as SpriteFrames
	if sprite_frames.has_animation(anim_name):
		var frame_count = sprite_frames.get_frame_count(anim_name)
		var frame_speed = sprite_frames.get_animation_speed(anim_name)
		var real_time = frame_count / frame_speed # 实际时间
		animated_sprite.speed_scale = real_time / time
		return OK
	else:
		push_error("没有这个动画。animation = ", anim_name)
		return FAILED


## 设置 AnimatedSprite2D 节点的动画播放速度。根据这个节点的动画帧和设置的持续时间，设置播放速度
static func update_sprite_frames_fps_time(sprite_frames: SpriteFrames, anim_name: StringName, time: float) -> Error:
	assert(time > 0, "时间错误，必须超过 0")
	if sprite_frames.has_animation(anim_name):
		var frame_count = sprite_frames.get_frame_count(anim_name)
		var frame_speed = sprite_frames.get_animation_speed(anim_name)
		var real_time = frame_count / frame_speed # 实际时间
		
		var fps_scale = real_time / time
		sprite_frames.set_animation_speed(anim_name, frame_speed * fps_scale)
		
		return OK
	else:
		push_error("没有这个动画。animation = ", anim_name)
		return FAILED


## 绘制网格
static func draw_grid(
	target: CanvasItem, 
	rect: Rect2, 
	cell_size: Vector2, 
	color: Color = Color.WHITE,
	line_width: float = 1.0, 
):
	for y in range(rect.position.y, rect.end.y + 1):
		target.draw_line(Vector2(rect.position.x, y) * cell_size, Vector2(rect.end.x, y) * cell_size, color, line_width)
	for x in range(rect.position.x, rect.end.x + 1):
		target.draw_line(Vector2(x, rect.position.y) * cell_size, Vector2(x, rect.end.y) * cell_size, color, line_width)

