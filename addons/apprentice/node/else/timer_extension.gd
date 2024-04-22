#============================================================
#    Timer Extension
#============================================================
# - datetime: 2023-02-10 10:14:16
#============================================================
## 扩展的计时器
class_name TimerExtension
extends Node


## 已开始倒计时
signal started
## 计时停止
signal stopped
## 倒计时结束
signal timeout
## 倒计时时间发生改变
##[br][code]previous[/code] 上次的时间
##[br][code]time[/code] 当前时间
signal time_changed(previous: float, time: float)


## 时间作用类型
enum  TimeType {
	COVER, ## 覆盖掉上次的时间
	STACK, ## 追加到上次的时间
	MAX, ## 按最大时间倒计时
	MIN, ## 按最小时间执行
}


@export_enum("Physics", "Idle")
var process_callback : int = Timer.TIMER_PROCESS_IDLE:
	set(v):
		process_callback = v
		_timer.process_callback = v
@export_range(0, 10, 0.001, "or_greater", "exp", "hide_slider", "suffix:s")
var wait_time : float = 1.0
@export 
var autostart : bool = false : 
	set(v): 
		autostart = v
		_timer.autostart = v
@export
var one_shot : bool = false :
	set(v):
		one_shot = v
		_timer.one_shot = v


var _timer : Timer = Timer.new()

# 上次开始的时间
var _last_time : float = 0.0


#============================================================
#  SetGet
#============================================================
func get_time_left() -> float:
	return _timer.time_left

func get_last_time() -> float:
	return _last_time


#============================================================
#  内置
#============================================================
func _ready() -> void:
	_timer.one_shot = true
	_timer.autostart = false
	_timer.timeout.connect( func(): self.timeout.emit() )
	self.add_child(_timer)


#============================================================
#  自定义
#============================================================
##  开始执行倒计时
##[br]
##[br][code]time[/code]  时间
##[br][code]type[/code]  时间类型
##[br] - [enum TimeType.COVER] 覆盖上次时间
##[br] - [enum TimeType.STACK] 叠加上次的剩余时间
##[br] - [enum TimeType.MAX] 按最大时间执行
##[br] - [enum TimeType.MIN] 按最小的时间值执行
func start(time: float, type) -> void:
	var previous = _timer.time_left
	if type == TimeType.MAX:
		_last_time = max(previous, time)
	elif type == TimeType.COVER:
		_last_time = time
	elif type == TimeType.STACK:
		_last_time = previous + time
	elif type == TimeType.MIN:
		_last_time = min(previous, time)
	else:
		push_error("错误的时间类型：", type)
		return
	
	# 开始倒计时
	_timer.start(_last_time)
	
	if previous == 0:
		self.started.emit()
	if previous != time:
		self.time_changed.emit(previous, time)


## 停止计时
func stop() -> void:
	if _timer.time_left > 0:
		_timer.stop()
		self.stopped.emit()
