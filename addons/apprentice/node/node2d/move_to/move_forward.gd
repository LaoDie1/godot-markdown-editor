#============================================================
#	Move Forward
#============================================================
# @datetime: 2022-7-31 23:53:03
#============================================================
##  向前移动。根据这个节点的旋转方向发出移动向量信号
class_name MoveForward
extends Node2D


##  移动方向
signal moved_direction(direction: Vector2)


## 使用全局位置属性
@export var use_global_position := true : set=set_use_global_position
## 节点默认朝向
@export var default_direction : Vector2 = Vector2.LEFT:
	set(v):
		default_direction = v
		_update_direction()


var _rot : float = INF
var _dir : Vector2 = Vector2(0,0)
var _offset_rot : float = 0.0
var _p : String = "global_rotation"


#============================================================
#   SetGet
#============================================================
## 设置使用全局位置
func set_use_global_position(value: bool) -> void:
	use_global_position = value
	_p = "global_rotation" if use_global_position else "rotation"


#============================================================
#   内置
#============================================================
func _enter_tree():
	_update_direction()

func _ready():
	_update_direction()


func _physics_process(delta):
	if _rot != self[_p]:
		_update_direction()
	moved_direction.emit(_dir)


#============================================================
#   自定义 
#============================================================
##  更新方向 
func _update_direction():
	_rot = self[_p] # 记录当前旋转弧度，如果发生改变时则会自动进行更新
	_dir = default_direction.rotated(self[_p])


##  instance
##[br]
##[br][code]default_direction[/code]  节点默认面部朝向
##[br][code]callback[/code]  执行调用回调。这个方法需要有一个 Vector2 类型参数用于接收移动朝向位置
##[br][code]add_to_node[/code]  
##[br][code]return[/code]  
static func instance(
	default_direction: Vector2, 
	callback: Callable, 
	add_to_node: Node2D
) -> MoveForward:
	var inst = MoveForward.new()
	inst.default_direction
	inst.moved_direction.connect(callback)
	add_to_node.add_child(inst)
	return inst


