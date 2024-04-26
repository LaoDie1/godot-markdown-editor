#============================================================
#    Markdown Editor
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 04:10:18
# - version: 4.3.0.dev5
#============================================================
class_name MarkdownEditor
extends Control


@onready var doc_canvas: DocCanvas = %DocCanvas
@onready var text_edit: TextEdit = %TextEdit
@onready var v_scroll_bar: VScrollBar = $VScrollBar


func _ready() -> void:
	var height = doc_canvas.document.get_doc_height()
	v_scroll_bar.max_value = height
	doc_canvas.size.y = height



func _on_v_scroll_bar_scrolling() -> void:
	doc_canvas.vertical_offset = v_scroll_bar.value
	doc_canvas.position.y = -v_scroll_bar.value
