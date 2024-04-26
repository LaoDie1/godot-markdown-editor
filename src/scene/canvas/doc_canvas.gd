#============================================================
#    Doc Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 11:54:13
# - version: 4.3.0.dev5
#============================================================
## 文档的画布对象
class_name DocCanvas
extends Control


## 点击文档中的行
signal clicked_line(line: LineItem)


## 绘制的文件路径
@export_global_file("*.md;Markdown File") var file_path: String:
	set(v):
		file_path = v
		if not is_inside_tree():
			await tree_entered
		load_file(file_path)
@export var vertical_offset : float:
	set(v):
		if vertical_offset != v:
			vertical_offset = v
			queue_redraw()

## 文档对象
var document: Document


#============================================================
#  内置
#============================================================
func _draw() -> void:
	if document:
		document.draw(self, vertical_offset, get_height())

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if document:
				var line : LineItem = document.get_line_by_point(get_local_mouse_position())
				if line:
					clicked_line.emit(line)



#============================================================
#  自定义
#============================================================
func get_width():
	return size.x

func get_height():
	return size.y


## 加载显示的文件
func load_file(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		printerr("文件不存在：", file_path)
		return
	
	if get_width() == 0:
		await Engine.get_main_loop().process_frame
	
	document = Document.new(get_width(), file_path)
	document.update_doc_height()
	
	# 绘制
	queue_redraw()
	# 立即刷新
	force_update_transform()



