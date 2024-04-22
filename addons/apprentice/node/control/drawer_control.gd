#============================================================
#    Drawer Control
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-29 12:50:27
# - version: 4.0
#============================================================
## 抽屉控制节点
##
##[member actor] 节点会根据 actor 节点的大小范围控制从开始的位置到结束的位置
class_name DrawerControl
extends Control


signal finished(state: bool)


enum {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
}

## 从这个位置开始运动
@export_enum("Left", "Right", "Top", "Bottom") 
var from_direction : int = LEFT:
	set(v):
		from_direction = v
		if not is_inside_tree():
			await ready
		if from_direction == LEFT:
			self.position.x = -self.size.x
			self.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		elif from_direction == RIGHT:
			self.position.x = self.size.x
			self.grow_horizontal = Control.GROW_DIRECTION_END
		elif from_direction == BOTTOM:
			self.position.y = -self.size.y
			self.grow_vertical = Control.GROW_DIRECTION_END
		elif from_direction == TOP:
			self.position.y = self.size.y
			self.grow_vertical = Control.GROW_DIRECTION_BEGIN
## 控制的节点
@export var actor : Control : set=set_actor


#============================================================
#  内置
#============================================================
func _init(actor: Control = null):
	self.set_actor(actor if actor else self)
	self.custom_minimum_size = Vector2.ZERO
	self.size = Vector2.ZERO
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _enter_tree():
	self.size = (get_parent().size 
		if get_parent() is Control 
		else get_viewport_rect().size
	)
	self.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _ready():
	_update_default_actor_pos()


#============================================================
#  实例化
#============================================================
static func from_list(node_list: Array, add_to_node: Node = null) -> Array[DrawerControl]:
	if add_to_node == null:
		add_to_node = Engine.get_main_loop().current_scene
	var drawer_control_list : Array[DrawerControl] = []
	for node in node_list: 
		drawer_control_list.append(from_node(node, add_to_node))
	return drawer_control_list


static func from_node(node: Control, add_to_node: Node = null) -> DrawerControl:
	var drawer_control = DrawerControl.new(node)
	if add_to_node == null:
		add_to_node = Engine.get_main_loop().current_scene
	add_to_node.add_child.call_deferred(drawer_control)
	return drawer_control


#============================================================
#  自定义
#============================================================
func _update_default_actor_pos():
	if from_direction == LEFT:
		actor.position.x = -actor.size.x
	elif from_direction == RIGHT:
		actor.position.x = self.size.x
	elif from_direction == TOP:
		actor.position.y = -actor.size.y
	elif from_direction == BOTTOM:
		actor.position.y = self.size.y

func set_actor(v: Control) -> void: 
	if actor != v:
		actor = v
		if actor:
			if not is_inside_tree():
				await ready
			if not actor.is_inside_tree():
				add_child(actor)
			_update_default_actor_pos()

func get_actor() -> Control:
	return actor

func get_position_from():
	match from_direction:
		LEFT: return -actor.size.x
		RIGHT: return self.size.x
		TOP: return -actor.size.y
		BOTTOM: return self.size.y

func get_position_to():
	match from_direction:
		LEFT: return 0
		RIGHT: return self.size.x - actor.size.x
		TOP: return 0
		BOTTOM: return self.size.y - actor.size.y

func get_size_axle():
	match from_direction:
		LEFT, RIGHT: return "custom_minimum_size:y"
		TOP, BOTTOM: return "custom_minimum_size:x"

func get_position_axle():
	match from_direction:
		LEFT, RIGHT: return "position:x"
		TOP, BOTTOM: return "position:y"

func execute(state: bool, duration: float = 0.2) -> DrawerControl:
	if not actor:
		print("没有 actor 节点")
		return self
	
	if not self.is_inside_tree():
		await self.ready
	
	var tween := create_tween()
	if state:
		# 伸出
		self.set_indexed.call_deferred("size:y", get_position_from())
		tween.parallel().tween_property(actor, get_position_axle(), get_position_to(), duration)
		tween.parallel().tween_property(self, get_size_axle(), actor.size.y, duration)
	else:
		# 缩入
		tween.parallel().tween_property(actor, get_position_axle(), get_position_from(), duration)
		tween.parallel().tween_property(self, get_size_axle(), 0, duration)
	
	tween.finished.connect( func(): self.finished.emit(state) )
	return self

