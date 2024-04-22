#============================================================
#    Control Hover Color
#============================================================
# - datetime: 2023-01-09 00:03:42
#============================================================
## Control 节点鼠标悬停颜色
##
##鼠标经过时设置目标节点的颜色
class_name ControlHoverColor
extends Node


@export
var target : Control
@export
var enter_color : Color = Color.WHITE
@export
var click_color : Color = Color.WHITE


func _ready() -> void:
	var origin_color = target.modulate
	target.mouse_entered.connect(func(): target.modulate = enter_color )
	target.mouse_exited.connect(func(): target.modulate = origin_color )
	
	target.gui_input.connect(
		func(event):
			if InputUtil.is_click_left(event, true):
				target.modulate = click_color
			elif InputUtil.is_click_left(event, false):
				var rect = target.get_rect() as Rect2
				rect.position = Vector2(0, 0)
				if rect.has_point(target.get_local_mouse_position()):
					# 鼠标在节点内部
					target.modulate = enter_color
				else:
					target.modulate = origin_color
	)
