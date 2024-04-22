#============================================================
#    Projectile Module
#============================================================
# - datetime: 2023-02-28 16:29:49
# - version: 4.x
#============================================================
## 投射物模块
##
##创建投射物的基础方式，示例：
##[codeblock]
##var bullets = ProjectileModule.create({
##    "count": count,
##    "direction": direction,
##    "source": self,
##    "move_speed": 100.0,
##    "position": player.global_position,
##    "offset_position": Vector2(0, 0),
##    "array": func(idx: int, bullet: CharacterBody2D):
##        var sprite = Sprite2D.new()
##        sprite.texture = preload("res://icon.svg")
##        sprite.scale = Vector2(1,1) / 5.0
##        sprite.rotate(-PI/2.0)
##        bullet.add_child(sprite)
##        
##        var rot = (PI * 0.1) * (idx - count / 2.0 + 0.5)
##        bullet.global_rotation += rot
##        
##        ,
##    "life_time": 2.0,
##})
##[/codeblock]
##
class_name ProjectileModule


# TODO: 改为可配置的根据 ID 修改对应的 ID 类型的数据的统一模块
#
# TODO: 改为链式调用方法的方式，先设置投射物的数量，然后设置参数，根据链式调用的顺序进行设置参数
# 有些链式调用的对象是独立的类，类似于 Tween 的链式调用的形式
#
# TODO: 下面的都改为一个类进行管理


const POSITION = "position"
const DIRECTION = "direction"
const TARGET = "target"
const COUNT = "count"
const OFFSET = "offset"
const MOVE_SPEED = "move_speed"
const LIFE_TIME = "life_time"
const ROTATION = "rotation"
const ARRAY = "array"
const ROTATION_SPEED = "rotation_speed"
const TRACK = "track"
const OFFSET_ROTATION = "offset_rotation"
const OFFSET_POSITION = "offset_position"



##  创建一个实例
##[br]
##[br][code]data[/code]  数据
##[br][code]return[/code]  返回创建的实例
static func create(data: Dictionary) -> Array[CharacterBody2D]:
	var list : Array[CharacterBody2D] = []
	var scene = Engine.get_main_loop().current_scene
	for i in data.get(COUNT, 1):
		var bullet = CharacterBody2D.new()
		scene.add_child(bullet)
		_base_data(bullet, data)
		_track_to(bullet, data)
		_array_data(bullet, data, i)
		list.append(bullet)
	return list


# 基础数据
static func _base_data(bullet: CharacterBody2D, data: Dictionary):
	var pos = data.get(POSITION, Vector2(0,0))
	bullet.global_position = pos
	
	# direction
	var direction : Vector2 = data.get(DIRECTION, Vector2.INF)
	if direction != Vector2.INF:
		bullet.global_rotation = direction.angle()
	
	# life-time
	var life_time = data.get(LIFE_TIME, 1.0)
	NodeUtil.create_once_timer(life_time, bullet.queue_free, bullet)
	
	# move-speed
	var move_speed = data.get(MOVE_SPEED, 0.0)
	var move_forward = MoveForward.new()
	move_forward.moved_direction.connect(
		func(dir):
			bullet.velocity = dir * move_speed
			bullet.move_and_slide()
	)
	bullet.add_child(move_forward)


# 阵列数据
static func _array_data(bullet: CharacterBody2D, data: Dictionary, idx: int):
	# offset
	var offset_pos = data.get(OFFSET_POSITION, Vector2(0, 0))
	bullet.global_position += offset_pos
	var offset_rot = data.get(OFFSET_ROTATION, 0.0)
	bullet.global_rotation += offset_rot
	
	var array = data.get(ARRAY) as Callable
	if array:
		array.call(idx, bullet)


# 追踪
static func _track_to(bullet: CharacterBody2D, data: Dictionary):
	if data.get(TRACK):
		var target: Node2D = data.get(TARGET)
		var rotation_speed : float = data.get(ROTATION_SPEED)
		var turn_controller = TurnController.new()
		turn_controller.execute_mode = TurnController.ExecuteMode.PHYSICS
		turn_controller.rotate_by_node = bullet
		turn_controller.rotation_speed = rotation_speed
		bullet.add_child(turn_controller)
	

