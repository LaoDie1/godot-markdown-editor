#============================================================
#    Sway
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-16 21:20:55
# - version: 4.0
#============================================================
## 摇摆
class_name Sway
extends Node2D


## 摇摆
##[br]
##[br][code]ratio[/code]  当前时间比值
##[br][code]value[/code]  摇摆到左右的最大值的百分比。这个值会逐次递减
signal swayed(ratio: float, value: float)


## 是否可用
@export var enabled : bool = true
## 摇摆幅度。值越大，摇摆越剧烈
@export var amplitude : float = 5.0
## 摇摆次数。左右摇摆一个来回算一次
@export_range(1, 100, 1, "or_greater") 
var range_count : int = 3
## 摇摆持续时间
@export_range(0.01, 100, 0.001, "or_greater", "hide_slider") 
var duration : float = 2.0


var _ratio_cache := AngleRatioCache.new()
var _tween : Tween


#============================================================
#  自定义
#============================================================
##  执行方法
##[br]
##[br][code]left_or_right[/code]  初始摇摆方向。先向左还是向右摇摆
func execute(left_or_right: float = 0.0):
	if not enabled:
		return
	
	#  默认先偏向左边，增加旋转 180 度旋转到右边
	var offset : float = 0.0
	if left_or_right > 0:
		offset = 180.0
	else:
		offset = 0
	
	if is_instance_valid(_tween):
		_tween.stop()
	_tween = create_tween()
	
	# 摇摆最大值
	var max_v : float = 360.0 * range_count
	_tween.chain().tween_method(func(v: float):
		var ratio = v / max_v
		var value = _ratio_cache.get_value(v  + offset) * ratio
		self.swayed.emit(ratio, value)
		
	, max_v, 0, duration)


## 停止
func stop() -> void:
	if is_instance_valid(_tween):
		_tween.stop()

