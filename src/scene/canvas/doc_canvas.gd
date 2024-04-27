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
signal height_changed(height: int)


@export var vertical_offset : float:
	set(v):
		if vertical_offset != v:
			vertical_offset = v
			queue_redraw()

## 文档对象
var document: Document
var last_width : float = 0.0


#============================================================
#  内置
#============================================================
func _ready() -> void:
	resized.connect(
		func():
			if document:
				if last_width != get_width():
					last_width = get_width()
					document.max_width = last_width
					document.update_doc_height()
	)

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

## 获取行在画布上的矩形数据
func get_line_rect(line: LineItem) -> Rect2:
	return line.get_rect(get_width())

## 加载显示的文件
func load_file(file_path: String) -> void:
	document = null
	vertical_offset = 0
	if not FileAccess.file_exists(file_path):
		printerr("文件不存在：", file_path)
		return
	if get_width() == 0:
		await Engine.get_main_loop().process_frame
	
	# 文档对象
	document = Document.new(get_width(), file_path)
	document.height_changed.connect(
		func():
			self.size.y = document.get_doc_height()
			self.height_changed.emit(document.get_doc_height())
	)
	update_document()


## 重绘
func redraw():
	# 绘制
	queue_redraw()
	# 立即刷新
	force_update_transform()


## 更新文档内容
func update_document():
	document.update_doc_height()
	size.y = document.get_doc_height()
	redraw()


## 插入新的行。全部插入后调用 [method update_document] 进行更新
func insert_line(from: LineItem, text: String) -> LineItem:
	return document.insert_after(from, text)
