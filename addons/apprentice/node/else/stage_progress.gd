#============================================================
#    Stage Progress
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-13 16:30:03
# - version: 4.0
#============================================================
## 带有阶段的进度
##
## 每次 [member value] 发生改变时，当值达到阶段值的比例，则会发出 [signal stage_changed] 信号
class_name StageProgress
extends Node


## 值发生改变
signal value_changed(previous_value: float, current_value: float)
## 阶段发生改变
signal stage_changed(previous_stage: int, current_stage: int)


## 当前值
@export_range(0, 100.0, 0.001, "or_greater", "hide_slider")
var value : float = 0.0:
	set(v):
		v = clampf(v, 0.0, max_value)
		if value != v:
			var previous = value
			value = v
			_update_level()
			self.value_changed.emit(previous, value)
## 最大值
@export_range(0, 100.0, 0.001, "or_greater", "hide_slider")
var max_value : float = 100.0
## 不同阶段在值中的占比
##[br]例如：[code]0, 0.25, 0.5, 0.75[/code]，则在发生改变时计算 [code]value/max_value[/code]，
##超过 [code]0[/code] 则为 1 级，超过[code]0.25[/code]则为 2 级
@export var stage_ratio : String = "0, 0.25, 0.5, 0.75":
	set(v):
		stage_ratio = v
		_levels.clear()
		var list : Array = str_to_var("[ %s ]" % stage_ratio)
		_levels = Array(list, TYPE_FLOAT, "", null)


var _levels : Array = []
var _previous_stage : int = -1
var _current_stage : int = 0


#============================================================
#  SetGet
#============================================================
func get_stage_ratio(stage: int) -> float:
	return _levels[stage]

func get_current_stage() -> int:
	return _current_stage


#============================================================
#  内置
#============================================================
func _ready():
	self.stage_ratio = stage_ratio
	_update_level()


#============================================================
#  自定义
#============================================================
func _update_level():
	var stage: int = 0
	var ratio : float = value / max_value
	for i in range(_levels.size() - 1, -1, -1):
		if ratio >= _levels[i]:
			stage = i
			break
	
	if _current_stage != stage:
		_previous_stage = _current_stage
		_current_stage = stage
		self.stage_changed.emit(_previous_stage, _current_stage)

