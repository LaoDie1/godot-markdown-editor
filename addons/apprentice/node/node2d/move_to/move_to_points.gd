#============================================================
#	Move To Path
#============================================================
# @datetime: 2022-8-1 22:04:46
#============================================================
## 根据点进行移动。主要配合 [MoveToPoint] 节点使用，详见 [MoveToPoint] 节点描述
class_name MoveToPoints
extends Node2D


signal moved_next(target_position: Vector2) ## 开始移动到下一个位置
signal move_finished ## 全部点移动完成
signal stopped ## 停止移动


var _running : bool = false
var _points : Array = []
var _last_points : Array = []


#============================================================
#   SetGet
#===========================================================
## 获取剩余的点列表
func get_points() -> Array:
	return _points

func is_running() -> bool:
	return _running


#============================================================
#   自定义
#============================================================
# 移动到下一个位置
func next():
	if _running:
		if _points.size() >= 1:
			# 移动到点路径位置
			moved_next.emit(_points.pop_back())
		else:
			_running = false
			move_finished.emit()


## 移动到位置
func to(point_list: Array):
	if point_list.hash() == _last_points.hash():
		return
	
	_last_points = point_list
	_running = true
	# 翻转一下 next() 移除位置时从末尾移除，这样消耗最小
	point_list.reverse()
	_points.clear()
	_points.append_array(point_list)
	next()


##  停止
func stop():
	if _running:
		_points.clear()
		_running = false
		stopped.emit()

