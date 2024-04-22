#============================================================
#    Buff
#============================================================
# - datetime: 2023-02-10 20:34:59
#============================================================
## 附加 BUFF 
class_name BuffManagement
extends DataManagement


# buff持续时间倒计时计时器
var _id_to_duration_timer_map : Dictionary = {}


##  buff 剩余执行时间
##[br]
##[br][code]id[/code]  buff ID
func get_time_left(id) -> float:
	var data = get_data(id)
	if data:
		var duration = data['duration']
		var elapsed_time = float(Time.get_ticks_msec() - data['ticks_msec']) / 1000.0	# 已经过时间
		var time_left = duration - elapsed_time
		if time_left > 0:
			return time_left
		return 0.0
	return 0.0


##  执行功能
##[br]
##[br][code]id[/code]  buff ID
##[br][code]data[/code]  附带数据
##[br][code]runnable[/code]  执行对象。传入 [FuncUtil.BaseExecutor] 类型的对象或 [Callable] 类型数据
func execute(id, data: Dictionary, runnable) -> void:
	assert(runnable != null)
	
	# 如果有相同ID，则清除上个
	if has_data(id):
		clear(id)
	
	if has_data(id):
		remove_data(id)
	
	# 执行对象
	var executor : Object
	if runnable is Callable:
		if executor.get_object() != null:
			executor = executor.get_object()
		runnable.call()
	
	if runnable is FuncUtil.BaseExecutor:
		executor = runnable
		data['duration'] = (runnable.wait_time 
			if runnable.time_left == 0 
			else runnable.time_left
		)
	
	data['executor'] = executor
	
	# 标记时间
	data['ticks_msec'] = Time.get_ticks_msec()
	
	var duration = DataUtil.get_value_or_set(data, "duration", func(): return INF)
	set_data(id, data)
	
	if duration != INF:
		var timer = NodeUtil.create_once_timer(max(duration, 0.01), func():
			remove_data(id)
		, self)
		_id_to_duration_timer_map[id] = timer


##  清除这个 buff
func clear(id):
	if has_data(id):
		var data = get_data(id)
		var executor = data.get("executor")
		if executor is FuncUtil.ExecutorObject:
			executor.queue_free()
	
	if _id_to_duration_timer_map.has(id):
		var timer = _id_to_duration_timer_map[id] as Timer
		timer.queue_free()
