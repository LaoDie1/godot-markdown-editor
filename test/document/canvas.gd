#============================================================
#    Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 11:10:45
# - version: 4.3.0.dev5
#============================================================
@tool
extends Control


var callback : Callable


func call_draw(callback: Callable):
	self.callback = callback
	queue_redraw()


func _draw() -> void:
	if not callback.is_null():
		callback.call()
