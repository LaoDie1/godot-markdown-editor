#============================================================
#    Animation Canvas
#============================================================
# - datetime: 2023-01-08 14:06:21
#============================================================
## 动画画布
##
##用于播放动画，向这个节点添加 [AnimatedSprite2D] / [AnimatedSprite3D] / [AnimationPlayer]
class_name AnimationCanvas
extends Node2D


signal played(animation: StringName)


#============================================================
#  代理节点
#============================================================
class AbstractAgent:
	
	var host
	
	func _init(host) -> void:
		self.host = host
	
	func get_host():
		return host
	
	func has_animation(animation: StringName) -> bool:
		return false
	
	func play(animation: StringName):
		pass
	
	func stop():
		pass
	
	func get_animation_time(animation: StringName) -> float:
		return 0.0
	
	func get_texture() -> Texture2D:
		return null
	
	func get_offset() -> Vector2:
		return Vector2(0,0)
	
	func get_size() -> Vector2:
		return Vector2(0, 0)
	


class AgentAnimatedSprite2D extends AbstractAgent:
	
	func get_animation_time(animation: StringName) -> float:
		var animated_sprite = get_host()
		var count = animated_sprite.sprite_frames.get_frame_count(animation)
		var speed = 1.0 / animated_sprite.sprite_frames.get_animation_speed(animation)
		return speed * count / animated_sprite.speed_scale
	
	func has_animation(animation: StringName) -> bool:
		return get_host() \
			and get_host().sprite_frames != null \
			and get_host().sprite_frames.has_animation(animation)
	
	func play(animation):
		get_host().play(animation)
	
	func stop():
		get_host().stop()
	
	func get_texture() -> Texture2D:
		var animated_sprite = get_host() as AnimatedSprite2D
		var animation = animated_sprite.animation
		var frame = animated_sprite.frame
		var sprite_frames = animated_sprite.sprite_frames as SpriteFrames
		if sprite_frames:
			return sprite_frames.get_frame_texture(animation, frame)
		return null
	
	func get_offset() -> Vector2:
		var animated_sprite = get_host() as AnimatedSprite2D
		return animated_sprite.offset
	
	func get_size() -> Vector2:
		var texture = get_texture()
		if texture:
			return texture.get_size()
		return Vector2(0, 0)
	


class AgentAnimationPlayer extends AbstractAgent:
	
	func get_host() -> AnimationPlayer:
		return super.get_host() as AnimationPlayer
	
	func has_animation(animation) -> bool:
		return get_host().has_animation(animation)
	
	func play(animation):
		get_host().stop()
		get_host().frame = 0
		get_host().play(animation)
	
	func stop():
		get_host().stop()
	
	func get_animation_time(animation: StringName) -> float:
		var anim := get_host().get_animation(animation) as Animation
		return anim.length / get_host().playback_speed
	


class AgentSprite2D extends AbstractAgent:
	
	func _get_animated_texture() -> Texture2D:
		return get_host().texture
	
	func get_host() -> Sprite2D:
		return super.get_host() as Sprite2D
	
	func has_animation(animation: StringName) -> bool:
		return animation == &""
	
	func play(animation: StringName):
		pass
	
	func stop():
		pass
	
	func get_animation_time(animation: StringName) -> float:
		return 0.0
	
	func get_texture():
		return get_host().texture
	
	func get_offset() -> Vector2:
		return get_host().offset
	
	func get_size():
		var texture = get_texture()
		if texture:
			return texture.get_size()
		return Vector2()
	


## 自动搜索子节点是否有动画节点，如果指定了 [member target] 属性，则不会自动搜索
@export var auto_search : bool = true
## 播放动画的目标节点
@export_node_path("AnimatedSprite2D", "AnimatedSprite3D", "AnimationPlayer", "Sprite2D")
var target : NodePath :
	set(v):
		target = v
		if target:
			if not self.is_inside_tree():
				await self.ready
			var node = get_node_or_null(target)
			if node:
				set_target(node)
			else:
				push_error( "没有获取到 %s 路径的节点" % target )
		else:
			_agent = null

var _agent : AbstractAgent


#============================================================
#  SetGet
#============================================================
func set_target(node: Node):
	if node is AnimatedSprite2D:
		_agent = AgentAnimatedSprite2D.new(node)
	elif node is AnimationPlayer:
		_agent = AgentAnimationPlayer.new(node)
	elif node is Sprite2D:
		_agent = AgentSprite2D.new(node)

## 获取目标节点
func get_target() -> Node:
	return _agent.get_host()

## 获取动画播放时长
func get_animation_time(animation: StringName) -> float:
	return _agent.get_animation_time(animation)

## 是否有这个动画
func has_animation(animation: StringName) -> bool:
	if _agent:
		return _agent.has_animation(animation)
	return false

## 获取当前贴图
func get_current_texture() -> Texture2D:
	return _agent.get_texture()

## 设置当前节点翻转
func set_flip(v: Vector2):
	if v.x == 0:
		v.x = 1
	if v.y == 0:
		v.y = 1
	var origin = Vector2(self.scale).abs()
	self.scale = origin * v

## 获取当前节点翻转值
func get_flip() -> Vector2:
	return self.scale

## 获取贴图偏移位置
func get_offset() -> Vector2:
	return _agent.get_offset()

## 获取贴图大小
func get_size() -> Vector2:
	return _agent.get_size()


#============================================================
#  内置
#============================================================
func _enter_tree() -> void:
	var node : Node
	if not target.is_empty():
		node = get_node(target)
	else:
		if auto_search:
			for child in get_children():
				if (child is AnimatedSprite2D
					or child is AnimatedSprite3D
					or child is AnimationPlayer
					or child is Sprite2D
				):
					node = child
					break
	
	if node:
		set_target(node)


func _ready() -> void:
	await get_tree().process_frame
	if _agent == null:
		push_warning(owner, "没有选中可播放动画的节点")
#		print(owner, "没有选中可播放动画的节点")


#============================================================
#  自定义
#============================================================
func play(animation: StringName):
	if _agent and has_animation(animation):
		_agent.play(animation)
		self.played.emit(animation)


func stop():
	_agent.stop()

