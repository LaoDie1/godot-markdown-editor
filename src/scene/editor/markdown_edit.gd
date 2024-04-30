#============================================================
#    Markdown Edit
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 04:10:18
# - version: 4.3.0.dev5
#============================================================
## 设置 file_path，设置显示加载的文件
class_name MarkdownEdit
extends Control


## 绘制的文件路径
@export_global_file("*.md;Markdown File") var file_path: String:
	set(v):
		if file_path != v:
			file_path = v
			if not is_inside_tree(): await ready
			document_canvas.load_file(file_path)
			v_scroll_bar.value = 0
			text_edit.visible = false
@export var show_debug : bool = true:
	set(v):
		show_debug = v
		if is_inside_tree():
			debug.visible = show_debug


@onready var document_canvas: DocumentCanvas = %DocumentCanvas
@onready var text_edit: TextEdit = %TextEdit
@onready var v_scroll_bar: VScrollBar = %VScrollBar
@onready var debug: TextEdit = %Debug


var _selected_line_item: LineItem


#============================================================
#  内置
#============================================================
func _ready() -> void:
	text_edit.visible = false
	debug.visible = show_debug


#============================================================
#  自定义
#============================================================
func push_line_from_text_edit():
	if text_edit.has_meta("line"):
		var t_line : LineItem = text_edit.get_meta("line") as LineItem
		t_line.origin_text = text_edit.text
		text_edit.remove_meta("line")
		document_canvas.redraw()
		text_edit.visible = false

## 获取文本内容
func get_text() -> String:
	if document_canvas.document:
		return document_canvas.document.get_text()
	return ""

## 滚动到目标位置
func scroll_to(y: int):
	v_scroll_bar.value = y
	if text_edit.visible:
		text_edit.visible = false
		push_line_from_text_edit()
	document_canvas.vertical_offset = y
	document_canvas.position.y = -y

## 编辑行
func edit_line(line: LineItem):
	push_line_from_text_edit()
	_selected_line_item = line
	
	if v_scroll_bar.value > line.offset_y:
		scroll_to(line.offset_y)
	
	var rect : Rect2 = document_canvas.get_line_rect(line)
	text_edit.text = line.origin_text
	text_edit.add_theme_font_size_override("font_size", line.font_size)
	text_edit.position = rect.position
	text_edit.position.y -= document_canvas.vertical_offset
	text_edit.size = rect.size
	if text_edit.size.y > rect.size.y:
		FuncUtil.execute_deferred(func():
			text_edit.size.y = rect.size.y
		)
	text_edit.set_meta("line", line)
	
	var v : Vector2 = text_edit.get_line_column_at_pos( text_edit.get_local_mouse_pos() , false)
	text_edit.set_caret_column(v.x)
	text_edit.grab_focus()
	text_edit.clear_undo_history()
	
	text_edit.visible = true
	text_edit.force_update_transform()


## 插入行
func insert_line(from:LineItem, text: String) -> LineItem:
	var line =  document_canvas.insert_line(from, text)
	edit_line(line)
	return line



#============================================================
#  连接信号
#============================================================
func _on_doc_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				v_scroll_bar.value += v_scroll_bar.step
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				v_scroll_bar.value -= v_scroll_bar.step

func _on_text_edit_visibility_changed() -> void:
	if text_edit and not text_edit.visible:
		push_line_from_text_edit()

func _on_doc_canvas_height_changed(height) -> void:
	v_scroll_bar.max_value = max(0, height - get_parent_control().size.y + 100)


var _enabled_scroll_status : bool = true
func _on_v_scroll_bar_value_changed(value: float) -> void:
	if _enabled_scroll_status:
		_enabled_scroll_status = false
		await Engine.get_main_loop().process_frame
		await Engine.get_main_loop().process_frame
		_enabled_scroll_status = true
		# 滚动到当前滚动条位置
		scroll_to(v_scroll_bar.value)


func _on_text_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if InputUtil.is_key(event, KEY_ENTER):
			if not Input.is_key_pressed(KEY_CTRL) and _selected_line_item:
				Engine.get_main_loop().root.set_input_as_handled()
				# 插入新的行
				if _selected_line_item.type == LineType.UnorderedList:
					insert_line(_selected_line_item, "- ")
				else:
					insert_line(_selected_line_item, "")
				
		elif InputUtil.is_key(event, KEY_ESCAPE):
			text_edit.hide()
			
			
				#var new_idx : int = _selected_line_idx + 1
				#var text : String = ""
				#if _selected_line_item.type == LineType.UnorderedList:
					#text = "- "
				#var new_line_item : LineItem = _insert_line(new_idx, text)
				#
				## 更新后面行的偏移
				#var offset : float = new_line_item.get_height_of_one_line()
				#_update_line_after_pos(new_idx, offset)
				#
				#_update_selected_line(true)
				#
				#FuncUtil.execute_deferred(func():
					## 选中这个行
					#_selected_line_item = new_line_item
					#_edit_line(new_line_item)
					#print("Edit: ", _selected_line_idx )
				#)
			#
		#
		#elif InputUtil.is_key(event, KEY_BACKSPACE):
			#if (text_edit.get_selected_text() == "" 
				#and text_edit.get_caret_column() == 0 
				#and text_edit.get_caret_line() == 0
			#):
				#var selected_line_idx : int = _selected_line_idx
				#if selected_line_idx > 0:
					#Engine.get_main_loop().root.set_input_as_handled()
					#var previous_line : LineItem = line_items[selected_line_idx - 1]
					#var text_count : int = previous_line.origin_text.length()
					#_delete_line(_selected_line_idx)
					#queue_redraw()
					#
					#FuncUtil.execute_deferred(
						#func():
							#_selected_line_item = previous_line
							#_edit_line(_selected_line_item)
							#text_edit.set_caret_column(text_count)
					#)
				#
			#else:
				## 延迟调用
				#if _selected_line_item:
					#var s_line = _selected_line_item
					#FuncUtil.execute_deferred(
						#func():
							#s_line.origin_text = text_edit.text
							#s_line.handle_by_path(file_path, get_width())
							#text_edit.custom_minimum_size.y = 0
							#queue_redraw()
					#)
