#============================================================
#    Doc Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 11:54:13
# - version: 4.3.0.dev5
#============================================================
class_name DocCanvas
extends Control


var document: Document
var cliecked_rect: Rect2 = Rect2()


#============================================================
#  内置
#============================================================
func _draw() -> void:
	if document:
		document.draw(self)
		draw_rect(cliecked_rect, Color.RED, false, 2)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if document:
				var line : LineItem = document.get_line_by_point(get_local_mouse_position())
				if line:
					cliecked_rect = line.get_rect(get_width())
					queue_redraw()


#============================================================
#  自定义
#============================================================
func get_width():
	return size.x

func load_file(file_path: String):
	if get_width() == 0:
		await Engine.get_main_loop().process_frame
	document = Document.new(file_path)
	document.max_width = get_width()
	document.update_doc_height()
	size.y = 0
	custom_minimum_size.y = document.get_doc_height()
	queue_redraw()


