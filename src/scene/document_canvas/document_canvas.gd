#============================================================
#    Document Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 10:52:13
# - version: 4.3.0.dev5
#============================================================
extends Control


signal selected(line_item: LineItem)


@export var margin : Rect2 = Rect2(8, 0, 8, 0)

@onready var text_edit : TextEdit = %TextEdit


var file_path : String = ""
var line_offset_point : float = 0
var line_items : Array[LineItem] = []
var p_to_item : Dictionary = {} # 点击的位置对应的行字符串

var _selected_pos : Vector2 = Vector2()
var _selected_line_item : LineItem = null:
	set(v):
		_selected_line_item = v
		if _selected_line_item == null	:
			_selected_line_idx = -1
		else:
			_selected_line_idx = line_items.find(_selected_line_item)
var _selected_line_idx : int = -1


#============================================================
#  内置
#============================================================
func _ready():
	resized.connect(text_edit.hide)


func _draw():
	line_offset_point = 0
	var width = get_width()
	
	# 顶部文字
	var top_item_left = LineItem.new("2024/04/22  11:35:00", {
		font_color = Config.accent_color,
		font_size = Config.top_font_size,
		alignment = HORIZONTAL_ALIGNMENT_LEFT,
	})
	top_item_left.draw_to(self, margin, width)
	var top_item_right = LineItem.new("共 xxx 个文字", {
		font_color = Config.accent_color,
		font_size = Config.top_font_size,
		alignment = HORIZONTAL_ALIGNMENT_RIGHT,
	})
	top_item_right.draw_to(self, margin, width)
	line_offset_point += top_item_left.get_total_height( -1 ) + 2
	
	# 顶部分割线
	draw_line(Vector2(0, line_offset_point), Vector2(size.x, line_offset_point), Config.accent_color, 1)
	line_offset_point += 3
	draw_line(Vector2(0, line_offset_point), Vector2(size.x, line_offset_point), Config.accent_color, 1)
	
	# 更新内容
	_draw_lines()


func _gui_input(event):
	if InputUtil.is_click_left(event, false):
		text_edit.visible = false
		
		# 查找并处理这个位置上的 item
		_selected_pos = get_local_mouse_position()
		await Engine.get_main_loop().process_frame
		for line_idx in line_items.size() - 1:
			var item : LineItem = line_items[line_idx]
			var next_item : LineItem = line_items[line_idx + 1]
			if _selected_pos.y >= item.line_y_point and _selected_pos.y < next_item.line_y_point:
				_selected_line_item = item
				_select_line(_selected_line_item)
				queue_redraw()
				break


#============================================================
#  自定义
#============================================================
func get_as_string() -> String:
	var text = ""
	for line_item in line_items:
		text += line_item.origin_text
		text += "\n"
	return text


func get_width() -> float:
	return size.x - margin.position.x - margin.size.x


# 绘制位置向下偏移
func _line_point_offset(item: LineItem, width: float):
	line_offset_point += item.get_total_height(width)


## 打开绘制的文件
func open_file(path: String) -> void:
	LineItem.reset_incr_id()
	file_path = path
	line_items.clear()
	
	# 处理每行
	var origin_lines = FileUtil.read_as_lines(path)
	match file_path.get_extension().to_lower():
		"md", "txt":
			for line in origin_lines:
				var item = LineItem.new(line)
				item.handle_md()
				line_items.append( item )
		
		_:
			for line in origin_lines:
				line_items.append( LineItem.new(line) )
	
	queue_redraw()


# 绘制每行内容
func _draw_lines():
	p_to_item.clear()
	var width = get_width()
	for item in line_items:
		draw_line_item(item, width)
	
	custom_minimum_size.y = line_offset_point
	size.y = line_offset_point


## 绘制这个行
func draw_line_item(item: LineItem, width : float):
	# 配置数据
	item.line_y_point = line_offset_point
	p_to_item[item.line_y_point] = item
	
	# 开始绘制
	item.draw_to(self, margin, width)
	# 向下偏移
	_line_point_offset(item, get_width())


# 选中行
func _select_line(item: LineItem):
	text_edit.visible = true
	text_edit.custom_minimum_size = Vector2(get_width() + 18, 0)
	text_edit.text = item.origin_text.substr(0, item.origin_text.length())
	text_edit.custom_minimum_size.y = item.get_total_height(get_width())
	text_edit.get_parent_control().position = Vector2(0, item.line_y_point)
	
	text_edit.add_theme_font_size_override("font_size", item.font_size)
	text_edit.add_theme_font_override("font", item.font)
	
	text_edit.grab_focus()
	var v = text_edit.get_line_column_at_pos( text_edit.get_local_mouse_pos() , false)
	text_edit.set_caret_column(v.x)
	
	self.selected.emit(item)


# 插入行
func _insert_line(line_idx: int) -> LineItem:
	var new_line_item = LineItem.new("")
	var last_item = line_items[line_idx]
	new_line_item.line_y_point = last_item.line_y_point
	line_items.insert(line_idx, new_line_item)
	return new_line_item

# 删除行
func _delete_line(line_idx:  int) -> void:
	if line_idx > 0:
		var line_item : LineItem = line_items[line_idx]
		line_items.remove_at(line_idx)
		
		# 将内容追加到上一行
		if line_item.text != "":
			var last_line_item = line_items[line_idx - 1]
			var last_caret_column = last_line_item.text.length()
			last_line_item.origin_text += line_item.text
			last_line_item.handle_md()
			Engine.get_main_loop().create_timer(0.01).timeout.connect(
				text_edit.set_caret_column.bind(last_caret_column),
				Object.CONNECT_ONE_SHOT
			)
		
		_update_line_after_pos(line_idx, -line_item.get_total_height(get_width()))

# 更新这个行的内容
func _update_line_by_text_edit(line_item: LineItem, hide_text_edit: bool):
	if line_item.origin_text != text_edit.text:
		var last_height = line_item.get_total_height(get_width())
		# 设置内容
		line_item.origin_text = text_edit.text
		line_item.handle_by_path(file_path)
		var height = line_item.get_total_height(get_width())
		if last_height != height:
			_update_line_after_pos( _selected_line_idx, height - last_height)
		queue_redraw()
	
	text_edit.visible = not hide_text_edit


# 更新这个索引的行之后的位置偏移 
func _update_line_after_pos(item_idx: int, offset: float):
	if item_idx == -1 or offset <= 2:
		return
	for i in range(item_idx + 1, line_items.size()):
		line_items[i].line_y_point += offset
	queue_redraw()



#============================================================
#  连接信号
#============================================================
func _on_text_edit_visibility_changed():
	if text_edit and not text_edit.visible:
		if _selected_line_item:
			_update_line_by_text_edit(_selected_line_item, true)


func _on_text_edit_gui_input(event):
	if event is InputEventKey:
		if InputUtil.is_key(event, KEY_ENTER):
			_update_line_by_text_edit(_selected_line_item, true)
			get_tree().root.set_input_as_handled()
			text_edit.visible = false
			
			if not Input.is_key_pressed(KEY_CTRL) and _selected_line_item:
				# 插入新的行
				var new_idx : int = _selected_line_idx + 1
				var new_line_item : LineItem = _insert_line(new_idx)
				
				# 更新后面行的偏移
				var offset : float = new_line_item.get_font_height()
				_update_line_after_pos(new_idx, offset)
				
				# 选中这个行
				await Engine.get_main_loop().process_frame
				_selected_line_item = new_line_item
				_select_line(new_line_item)
		
		elif InputUtil.is_key(event, KEY_BACKSPACE):
			if text_edit.get_caret_column()==0 and text_edit.get_caret_line() == 0:
				var selected_line_idx = _selected_line_idx
				if selected_line_idx > 0:
					_delete_line(_selected_line_idx)
					get_tree().root.set_input_as_handled()
					queue_redraw()
					
					await Engine.get_main_loop().process_frame
					await Engine.get_main_loop().process_frame
					_selected_line_item = line_items[selected_line_idx - 1]
					_select_line(_selected_line_item)
					


func _on_text_edit_resized():
	if _selected_line_item and text_edit.visible:
		await Engine.get_main_loop().process_frame
		var height = _selected_line_item.get_total_height_by_text(text_edit.text, get_width())
		var last_height = _selected_line_item.get_total_height(get_width())
		_selected_line_item.line_y_point += height - last_height
		_update_line_by_text_edit(_selected_line_item, false)
		_update_line_after_pos( _selected_line_idx, height - last_height)

