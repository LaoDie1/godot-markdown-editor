#============================================================
#    Drag Move Control
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-26 20:13:05
# - version: 4.0
#============================================================
## 拖拽移动节点
##
##添加到 [Control] 类节点下即可拖拽这个节点
class_name DragMoveControl
extends Control


## 拖拽移动。
##
##[br][code]diff[/code] 与开始拖拽时的位置相差的距离
signal moved(diff: Vector2)
## 开始拖拽节点
signal dragged(pos: Vector2)
## 放下拖拽节点
signal dropped(pos: Vector2)


var _dragged : bool = false
var _clicked_mouse_pos: Vector2 = Vector2.INF
var _clicked_pos : Vector2 = Vector2.INF


#============================================================
#  内置
#============================================================
func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready():
	assert(get_parent() is Control, "父节点不是 Control 类型的节点！")
	assert(get_parent().mouse_filter != Control.MOUSE_FILTER_IGNORE, "父节点鼠标过滤不能是 ignore")
	
	get_parent().gui_input.connect(func(event):
		if event is InputEventMouseMotion:
			if _clicked_pos != Vector2.INF and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var diff = get_global_mouse_position() - _clicked_mouse_pos
				if _dragged:
					get_parent().global_position = _clicked_pos + diff
					self.moved.emit(diff)
				else:
					# 拖拽距离超过 5 像素，代表是在拖拽节点，否则只是在点击
					if diff.length() > 5:
						_dragged = true
						self.dragged.emit()
		
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_clicked_mouse_pos = get_global_mouse_position()
					_clicked_pos = get_parent().global_position
					
				else:
					if _dragged:
						_dragged = false
						self.dropped.emit()
						_clicked_pos = Vector2.INF
		
	)
