#==================================================
#	Turn Controller
#==================================================
# @datetime: 2021-9-12 10:58:45
#==================================================
##  转动
class_name TurnController
extends Node2D


##  [code]radian[/code] 为旋转的弧度。连接这个信号调用 [Node2D] 节点的 [method rotate] 方法进行旋转
signal rotated(radian: float)
##  转向完成
signal turn_finished


##  执行方式
enum ExecuteMode {
	MANUAL, ## 需要不断地调用旋转方法进行旋转
	PHYSICS, ## 以 _physics_process 线程进行调用旋转到的节点，只用调用一次旋转方法则会自动旋转到目标位置
	PROCESS, ## 以 _process 线程进行调用旋转到的节点，只用调用一次旋转方法则会自动旋转到目标位置
}

@export var execute_mode : ExecuteMode = ExecuteMode.MANUAL:
	set(v):
		execute_mode = v
		_update_process()
## 根据这个节点作为中心点的方向进行旋转
@export var rotate_by_node : Node2D
## 旋转速度
@export var rotation_speed : float = 3.0
## 偏移的角度（这会决定贴图方向）
@export_range(0, 360.0) var offset_degress : float = 0.0 : 
	set(value):
		offset_degress = value
		_offset_rot = deg_to_rad(offset_degress)

# 偏移的弧度
var _offset_rot : float = 0.0
# 旋转到的节点
var _to : Vector2 = Vector2(0,0)


#==================================================
#   Set/Get
#==================================================
func set_offset_degress(value: float) -> void:
	offset_degress = value
	_offset_rot = deg_to_rad(offset_degress)


#============================================================
#  内置
#============================================================
func _ready() -> void:
	_update_process()
	if is_instance_valid(rotate_by_node):
		_to = rotate_by_node.global_position


func _physics_process(delta: float) -> void:
	central_to(_to, delta)


func _process(delta: float) -> void:
	central_to(_to, delta)


#==================================================
#   自定义方法
#==================================================
# 更新线程
func _update_process() -> void:
	set_process(false)
	set_physics_process(false)
	if execute_mode == ExecuteMode.PROCESS:
		set_process(true)
	elif execute_mode == ExecuteMode.PHYSICS:
		set_physics_process(true)


##  转向到目标位置。（注意这个是手动控制的，需要每帧不断地调用这个方法，然后会旋转到目标方向。）
##[br]
##[br][code]from[/code]  角色位置
##[br][code]to[/code]  目标位置
func to(from: Vector2, to: Vector2, delta: float) -> void:
	to_dir(from.direction_to(to), delta)
	_update_process()


##  中心旋转。以当前 rotate_by_node 位置旋转到目标位置
func central_to(to: Vector2, delta: float) -> void:
	if rotate_by_node:
		_to = to
		to(rotate_by_node.global_position, to, delta)
		_update_process()


##  停止旋转
func stop() -> void:
	set_physics_process(false)
	set_process(false)


##  转向到目标方向
##[br]
##[br][code]dir[/code]  目标方向
func to_dir(dir: Vector2, delta: float):
	var v : Vector2 = rotate_by_node.global_position - get_global_mouse_position()
	var angle : float = v.angle()
	var r : float = rotate_by_node.global_rotation + _offset_rot
	var angle_delta : float = rotation_speed * delta  # 每帧旋转速度
	
	# 旋转到目标位置
	angle = lerp_angle(r, angle, 1.0)
	# 限制上面旋转速度，固定旋转的值在 angle_delta （每帧旋转）速度之内
	angle = clamp(angle, r - angle_delta, r + angle_delta)
	
	if (r != angle):
		rotated.emit(angle)
		
	else:
		set_process(false)
		set_physics_process(false)
		
		turn_finished.emit()

