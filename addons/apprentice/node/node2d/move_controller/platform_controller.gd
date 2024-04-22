#============================================================
#	Platform Controller
#============================================================
# @datetime: 2022-2-28 12:03:06
#============================================================
##  平台角色控制器
##
##专为 [CharacterBody2D] 角色设计的控制器，设置 [member host] 属性，调用 move 开头的方法即可
class_name PlatformController
extends MoveController


##  跳跃
signal jumped(height: float)
## 落下
signal fallen


## 控制宿主
@export var host : CharacterBody2D
## 输入缓冲时间。在这个时间内按下跳跃，在落在地面上后自动进行跳跃
@export_range(0.0, 1.0, 0.001, "or_greater")
var buffer_time : float = 0.1
## 土狼时间。离开地面后，在这个时间内仍可以进行跳跃
@export_range(0.0, 1.0, 0.001, "or_greater")
var grace_time : float = 0.1

@export_group("Jump")
## 启用跳跃功能
@export var jump_enabled := true
## 跳跃高度
@export var jump_height : float = 0.0
## 判定为落下的要求超出的速度，即：下落速度超出这个值，则会判定为落下状态。
@export var determine_fall : float = 10.0
## 最小间隔跳跃时间，如果上次跳跃的时间，间隔不够长，则不能再次跳跃
@export_range(0, 10, 0.001, "or_greater")
var min_jump_time : float = 0.0
## 地面停留时间，如果在地面上停留的时间低于这个时间，则不能跳跃
@export_range(0, 10, 0.001, "or_greater")
var floor_dwell_time : float = 0.0

@export_group("Gravity", "gravity")
## 是否启用重力
@export var gravity_enabled := true
## 重力下降速率（每帧下降速度）
@export_range(0.0, 60.0, 0.001, "or_greater")
var gravity_rate : float = 1.0
## 最大重力下降速度
@export var gravity_max : float = 0.0


# 缓冲跳跃计时器
var _buffer_jump_timer := Timer.new()
# 土狼时间计时器
var _grace_timer := Timer.new()
# 最小间隔跳跃时间计时器
var _min_jump_interval_timer := Timer.new()
# 地面停留时间计时器
var _floor_dwell_timer := Timer.new()

# 移动前的位置
var _previous_pos: Vector2
# 跳跃高度
var _jump_height : float = 0.0
# 是否已经发出落下的信号
var _emited_fall_signal : bool = true
# 上次是否在地板
var _last_is_on_floor : bool = false

var _on_floor_count : int = 0


#============================================================
#   Set/Get
#============================================================
##  在土狼时间内可以跳跃
func is_can_jump():
	return _grace_timer.time_left > 0

## 是否落下
func is_falling():
	return motion_velocity.y > determine_fall * get_physics_process_delta_time()

## 是否在跳跃
func is_jumping():
	return motion_velocity.y < 0

## 是否在地板上
func is_on_floor() -> bool:
	return _on_floor_count <= 1


#============================================================
#   内置
#============================================================
func _ready():
	_buffer_jump_timer.one_shot = true
	add_child(_buffer_jump_timer)
	
	_grace_timer.one_shot = true
	add_child(_grace_timer)
	
	_min_jump_interval_timer.wait_time = 0.2
	_min_jump_interval_timer.one_shot = true
	add_child(_min_jump_interval_timer)
	
	_floor_dwell_timer.one_shot = true
	_floor_dwell_timer.autostart = false
	add_child(_floor_dwell_timer)
	
	await Engine.get_main_loop().process_frame
	if gravity_max == 0:
		push_warning("gravity_max 值为 0")
	


#============================================================
#   自定义
#============================================================
#(override)
func _move():
	# 重力
	if gravity_enabled:
		if is_on_floor() and motion_velocity.y != 0:
			motion_velocity.y = 0
		else:
			motion_velocity.y = lerpf(motion_velocity.y, gravity_max, gravity_rate * get_physics_process_delta_time() )
	
	# 还在上升阶段碰到天花板时
	if host.is_on_ceiling_only():
		motion_velocity.y = 0
		motion_velocity.y = lerpf(motion_velocity.y, gravity_max, gravity_rate * get_physics_process_delta_time() )
	
	# 是否落下
	if not is_on_floor():
		if not _emited_fall_signal:
			if is_falling():
				_emited_fall_signal = true
				fallen.emit()
		_floor_dwell_timer.stop()
		_last_is_on_floor = false
	else:
		_emited_fall_signal = false
		if not _last_is_on_floor:
			# 最小停留时间
			_floor_dwell_timer.start(floor_dwell_time)
		_last_is_on_floor = true
	
	# 开始跳跃
	if (_min_jump_interval_timer.time_left == 0 # 最小跳跃间隔时间已结束
		and _floor_dwell_timer.time_left == 0 # 地板最小停留时间已结束
	):
		if _buffer_jump_timer.time_left > 0: # 输入缓冲时按下了跳跃
			if (is_on_floor() # 这时如果在地上，则开始跳跃
				or _grace_timer.time_left > 0 # 或者不在地面上，但是在土狼时间内（这个时间内有过在地面上的时间）
			):
				_jump()
		else:
			# 土狼时间计时
			if is_on_floor() and grace_time > 0:
				_grace_timer.stop()
				_grace_timer.start(grace_time)
	
	# 移动
	motion_velocity.x = _move_speed * _current_direction.x
	
	if motion_velocity != Vector2.ZERO:
		_previous_pos = host.global_position
		
		host.velocity = motion_velocity
		host.move_and_slide()
		
		motion_velocity.x = host.global_position.x - _previous_pos.x 
		_last_move_vector = motion_velocity
	
	self._moving = (_move_speed != 0.0)
	self.moved.emit(motion_velocity)
	if host.is_on_floor_only():
		_on_floor_count = 0
	else:
		_on_floor_count += 1
	
	# 移动后
	if _last_direction.x == 0:
		_move_speed = lerpf(_move_speed, 0.0, friction * get_physics_process_delta_time() )
	
	_last_direction = Vector2(0,0)


#(override)
func move_direction(direction: Vector2):
	move_left_right(direction.x)
	if direction.y < 0:
		jump(sign(direction.y) * -jump_height)


#(override)  
func move_vector(velocity: Vector2):
	motion_velocity.x = velocity.x
	update_direction(Vector2(sign(velocity.x), 0))
	if velocity.y < 0:
		jump(sign(velocity.y))


##  实际进行控制跳跃操作
func _jump():
	if jump_enabled:
		if min_jump_time > 0:
			_min_jump_interval_timer.start(min_jump_time)
		motion_velocity.y = -_jump_height
		_buffer_jump_timer.stop()
		_grace_timer.stop()
		self.jumped.emit(_jump_height)
	else:
		printerr("未启用跳跃功能！")


##  更改方向
##[br]
##[br][code]dir[/code]  移动方向。
func change_direction(dir):
	if dir is float or dir is int:
		update_direction(Vector2(dir, 0))
	elif dir is Vector2:
		update_direction(dir)
	else:
		assert(false, "参数必须是 [float, int, Vector2] 其中一种类型！")


##  左右移动
##[br]
##[br][code]left_right[/code]  左右移动方向。-1 为左，1 为右
func move_left_right(left_right: float):
	update_direction(Vector2(sign(left_right), 0))


##  跳跃
##[br]
##[br][code]height[/code]  跳跃高度
##[br][code]force[/code]  强制跳跃
func jump(height: float = INF, force: bool = false):
	if jump_enabled:
		_emited_fall_signal = false
		_jump_height = (height if height != INF else jump_height)
		if force:
			# 不管在什么位置都立即进行跳跃
			_jump()
		else:
			# 缓冲跳跃被开启，在地面上时会立马进行跳跃
			if buffer_time > 0:
				_buffer_jump_timer.start(buffer_time)

