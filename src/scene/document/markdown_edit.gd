#============================================================
#    Markdown Edit
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 04:10:18
# - version: 4.3.0.dev5
#============================================================
## Markdown 编辑界面
##
## Markdown 文本 UI 界面整合管理。操作行为的处理。
class_name MarkdownEdit
extends Control


## 点击文档中的行
signal clicked_line(line: LineItem)


## 绘制的文件路径（设置完自动打开文件）
@export_global_file("*.md;Markdown File") var file_path: String:
	set(v):
		file_path = v
		if not is_inside_tree(): 
			await ready
		await document_canvas.load_file(file_path)
		v_scroll_bar.value = 0
		text_edit.visible = false
		if file_path == "":
			edit_line(document_canvas.document.get_first_line())
@export var show_debug : bool = true:
	set(v):
		show_debug = v
		if is_inside_tree():
			debug.visible = show_debug


@onready var document_canvas: DocumentCanvas = %DocumentCanvas
@onready var text_edit: TextEdit = %TextEdit
@onready var v_scroll_bar: VScrollBar = %VScrollBar
@onready var debug: TextEdit = %Debug
@onready var line_spacing_spin_box: SpinBox = %LineSpacingSpinBox


var _selected_line_item: LineItem
var _last_clicked_item : LineItem


#============================================================
#  内置
#============================================================
func _init():
	ConfigKey.Display.line_spacing.bind_method(func(value):
		var first_line = document_canvas.document.get_first_line()
		var line_linked_list = document_canvas.document.line_linked_list
		var last_line_spacing = ConfigKey.Display.line_spacing.get_last_value(4)
		var diff = value - last_line_spacing
		var idx = [0]
		line_linked_list.for_next(first_line, func(line: LineItem):
			idx[0] += 1
			line.offset_y += diff * idx[0]
		)
		document_canvas.queue_redraw()
	)


func _ready() -> void:
	text_edit.visible = false
	debug.visible = show_debug
	line_spacing_spin_box.value = ConfigKey.Display.line_spacing.get_value()


func _process(delta):
	if Engine.get_process_frames() % 6 == 0:
		if text_edit.visible and _selected_line_item:
			var rect : Rect2 = document_canvas.get_line_rect(_selected_line_item)
			text_edit.position = rect.position - Vector2(0, document_canvas.vertical_offset)
			text_edit.size = rect.size



#============================================================
#  自定义
#============================================================
## 获取文本内容
func get_text() -> String:
	if document_canvas.document:
		return document_canvas.document.get_text()
	return ""

## 滚动到目标位置
func scroll_to(y: int):
	v_scroll_bar.value = y
	alter_line_from_text_edit(false)
	document_canvas.vertical_offset = y
	document_canvas.position.y = -y
	if text_edit.visible:
		var rect : Rect2 = document_canvas.get_line_rect(_selected_line_item)
		text_edit.position = rect.position - Vector2(0, document_canvas.vertical_offset)
		text_edit.size = rect.size

## 滚动到行
func scroll_to_line(line: LineItem):
	var min_y = document_canvas.vertical_offset
	var max_y = document_canvas.vertical_offset + size.y
	if min_y > line.offset_y:
		scroll_to(line.offset_y - 10)
	elif max_y < line.offset_y + 100:
		scroll_to(min_y + 100)


## 编辑行
func edit_line(line: LineItem):
	alter_line_from_text_edit(false)
	_selected_line_item = line
	if v_scroll_bar.value > line.offset_y:
		scroll_to(line.offset_y)
	
	text_edit.text = line.origin_text
	text_edit.add_theme_font_size_override("font_size", line.font_size)
	text_edit.set_meta("line", line)
	var rect : Rect2 = document_canvas.get_line_rect(_selected_line_item)
	text_edit.position = rect.position - Vector2(0, document_canvas.vertical_offset)
	text_edit.size = rect.size
	text_edit.visible = true
	
	text_edit.grab_focus()
	text_edit.clear_undo_history()
	_last_clicked_item = line

## 修改行数据
func alter_line(line_edit: LineItem, text: String):
	# 不是代码块
	if not text.strip_edges(true, false).begins_with("```"):
		var last = line_edit
		var lines = Array(text.split("\n"))
		line_edit.origin_text = lines.pop_front()
		for line in lines:
			last = insert_line(last, line)
	else:
		line_edit.origin_text = text
	document_canvas.queue_redraw()

## 修改到行中
func alter_line_from_text_edit(hide_text_edit: bool = true):
	if text_edit.has_meta("line"):
		var t_line : LineItem = text_edit.get_meta("line") as LineItem
		text_edit.remove_meta("line")
		alter_line(t_line, text_edit.text)
		document_canvas.queue_redraw()
		if hide_text_edit:
			text_edit.visible = false

## 插入行
func insert_line(from:LineItem, text: String) -> LineItem:
	var line =  document_canvas.document.insert_line(from, text)
	edit_line(line)
	return line

## 移除行
func remove_line(line: LineItem):
	var previous = document_canvas.document.line_linked_list.get_previous(line)
	if previous:
		if document_canvas.document.remove_line(line):
			document_canvas.queue_redraw()
			edit_line(previous)
			
			var line_text = text_edit.get_line(text_edit.get_caret_line())
			text_edit.set_caret_column(line_text.length())



#============================================================
#  连接信号
#============================================================
func _on_text_edit_visibility_changed() -> void:
	if text_edit and not text_edit.visible:
		alter_line_from_text_edit()
		_last_clicked_item = null


func _on_doc_canvas_height_changed(height) -> void:
	v_scroll_bar.max_value = max(0, height - get_parent_control().size.y + 100)


var _enabled_scroll_status : bool = true
func _on_v_scroll_bar_value_changed(value: float) -> void:
	if _enabled_scroll_status:
		_enabled_scroll_status = false
		await Engine.get_main_loop().process_frame
		_enabled_scroll_status = true
		# 滚动到当前滚动条位置
		scroll_to(v_scroll_bar.value)


func _on_text_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER:
				if not Input.is_key_pressed(KEY_CTRL) and _selected_line_item:
					# 代码块回车
					if text_edit.text.strip_edges(true, false).begins_with("```"):
						if text_edit.get_caret_line() == 0:
							return
						elif text_edit.get_caret_line() > 0:
							var line = text_edit.get_line(text_edit.get_line_count()-1)
							var column = text_edit.get_caret_column()
							if not (line.begins_with("```") and column == line.length()):
								return
					
					Engine.get_main_loop().root.set_input_as_handled()
					
					var tmp = _selected_line_item
					alter_line(tmp, tmp.origin_text)
					
					# 插入新的行
					if _selected_line_item.type == LineType.UnorderedList:
						insert_line(_selected_line_item, "- ")
					else:
						insert_line(_selected_line_item, "")
				
			KEY_ESCAPE:
				text_edit.hide()
			
			KEY_BACKSPACE:
				if (text_edit.get_selected_text() == "" 
					and text_edit.get_caret_column() == 0 
					and text_edit.get_caret_line() == 0
				):
					Engine.get_main_loop().root.set_input_as_handled()
					if _selected_line_item:
						remove_line(_selected_line_item)
			
			KEY_DOWN:
				if _selected_line_item:
					var next : LineItem = document_canvas.document.line_linked_list.get_next(_selected_line_item)
					if next:
						scroll_to_line(next)
						edit_line(next)
			
			KEY_UP:
				if _selected_line_item:
					var previous : LineItem = document_canvas.document.line_linked_list.get_previous(_selected_line_item)
					if previous:
						scroll_to_line(previous)
						edit_line(previous)
	else:
		document_canvas.gui_input.emit(event)
		


func _on_document_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_DOWN:
					v_scroll_bar.value += v_scroll_bar.step
				MOUSE_BUTTON_WHEEL_UP:
					v_scroll_bar.value -= v_scroll_bar.step
				MOUSE_BUTTON_LEFT:
					if document_canvas.document:
						var line : LineItem = document_canvas.document.get_line_by_point(document_canvas.get_local_mouse_position())
						# 防止重复点击选中 TODO，这部分操作逻辑换到 Markdown Edit 里面去
						if line and line != _last_clicked_item:
							_last_clicked_item = line
							edit_line(line)
							self.clicked_line.emit(line)
							
							await Engine.get_main_loop().create_timer(0.05).timeout
							var v = text_edit.get_line_column_at_pos( text_edit.get_local_mouse_position() )
							text_edit.set_caret_column(v.x)


func _on_line_spacing_spin_box_value_changed(value):
	if document_canvas.document:
		ConfigKey.Display.line_spacing.set_value(value)
