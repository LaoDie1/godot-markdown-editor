#============================================================
#    Border
#============================================================
# - datetime: 2023-01-31 19:52:52
#============================================================
## 鼠标经过后显示边框
@tool
class_name ControlHoverBorder
extends ReferenceRect


@export var target : Control


func _init():
	self.editor_only = false
	if not Engine.is_editor_hint():
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		self.visible = false


func _enter_tree():
	if not Engine.is_editor_hint() and target == null:
		get_parent().mouse_entered.connect(set.bind("visible", true))
		get_parent().mouse_exited.connect(set.bind("visible", false))
	if target:
		target.mouse_entered.connect(set.bind("visible", true))
		target.mouse_exited.connect(set.bind("visible", false))

