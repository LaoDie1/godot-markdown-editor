#============================================================
#    Document Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 11:54:13
# - version: 4.3.0.dev5
#============================================================
## 文档的画布对象
##
##只处理关于绘制的内容，不涉及行、块、文本的内容
class_name DocumentCanvas
extends Control


signal height_changed(height: int)


@export var vertical_offset : float: ## 滚动到的位置
	set(v):
		if vertical_offset != v:
			vertical_offset = v
			queue_redraw()


var document: Document ## 文档对象
var canvas_height : int = 0:
	set(v):
		if canvas_height != v:
			canvas_height = v
			height_changed.emit(canvas_height)


#============================================================
#  内置
#============================================================
func _ready():
	resized.connect(
		func():
			canvas_height = size.y + 100
	)

func _draw() -> void:
	if document:
		document.width = size.x
		document.draw(self, vertical_offset, get_height())


#============================================================
#  自定义
#============================================================
func get_width():
	return size.x

func get_height():
	return size.y

## 获取行在画布上的矩形数据
func get_line_rect(line: LineItem) -> Rect2:
	return line.get_rect()

## 加载显示的文件
func load_file(file_path: String) -> void:
	document = null
	vertical_offset = 0
	if get_width() == 0:
		await Engine.get_main_loop().process_frame
	
	# 文档对象
	document = Document.new(get_width(), file_path)
	document.height_changed.connect(
		func(): self.size.y = document.get_document_height() + 100
	)
	size.y = document.get_document_height() + 100


