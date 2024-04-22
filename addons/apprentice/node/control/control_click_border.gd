#============================================================
#    Control Click Border
#============================================================
# - datetime: 2023-02-27 13:09:31
#============================================================
## 鼠标点击目标节点则会显示这个节点，再次点击则会隐藏
@tool
class_name ControlClickBorder
extends ReferenceRect


signal clicked(status)


@export var target : Control


func _init():
	if not Engine.is_editor_hint():
		self.editor_only = false
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		self.visible = false


func _ready():
	if target:
		target.gui_input.connect(
			func(event):
				if InputUtil.is_click_left(event, true):
					self.visible = not self.visible
					self.clicked.emit(self.visible)
		)
	

