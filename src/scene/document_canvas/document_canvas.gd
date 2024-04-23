#============================================================
#    Document Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 10:52:13
# - version: 4.3.0.dev5
#============================================================
## 绘制文档中的内容
class_name DocumentCanvas
extends Control


signal selected(line_item: LineItem)


@onready var text_edit : TextEdit = %TextEdit

static var instance : DocumentCanvas


var file_path : String = ""

var line_offset_point : float = 0
var line_items : Array[LineItem] = []
var pos_to_line_item : Dictionary = {}  # 点击的位置对应的 y 轴对应的字符串

var _origin_text = ""

var _selected_pos : Vector2 = Vector2()
var _selected_line_item : LineItem = null:
	set(v):
		_selected_line_item = v
		if _selected_line_item == null	:
			_selected_line_idx = -1
		else:
			_selected_line_idx = line_items.find(_selected_line_item)
var _selected_line_idx : int = -1

# 这个组中的行。TODO 计划后续分段处理内容
var _group_to_line_items : Dictionary = {}


#============================================================
#  内置
#============================================================
func _init() -> void:
	instance = self

func _ready():
	_init_string_lines([""])
	queue_redraw()


func _draw():
	line_offset_point = 0
	var width = get_width()
	
	# 顶部文字
	var datetime_dict = Time.get_datetime_dict_from_system()
	datetime_dict["minute"] = "%02d" % datetime_dict["minute"]
	datetime_dict["hour"] = "%02d" % datetime_dict["hour"]
	datetime_dict["second"] = "%02d" % datetime_dict["second"]
	var datetime = "{year}/{month}/{day} {hour}:{minute}:{second}".format(datetime_dict)
	var top_item_left = LineItem.new(datetime, {
		font_color = Config.accent_color,
		font_size = Config.top_font_size,
		alignment = HORIZONTAL_ALIGNMENT_LEFT,
	})
	top_item_left.draw_to(self, width)
	var top_item_right = LineItem.new("共 %d 个字符" % _origin_text.length(), {
		font_color = Config.accent_color,
		font_size = Config.top_font_size,
		alignment = HORIZONTAL_ALIGNMENT_RIGHT,
	})
	top_item_right.draw_to(self, width)
	line_offset_point += top_item_left.get_height( -1 ) + 2
	
	# 顶部分割线
	line_offset_point += 4
	_draw_separation_line(line_offset_point, Config.accent_color)
	line_offset_point += 3
	_draw_separation_line(line_offset_point, Config.accent_color)
	
	# 绘制行
	_redraw_lines()


func _gui_input(event):
	if InputUtil.is_click_left(event, false):
		_update_selected_line(true)
		_selected_line_item = null
		_selected_pos = get_local_mouse_position()
		for line_idx in line_items.size() - 1:
			var item : LineItem = line_items[line_idx]
			var next_item : LineItem = line_items[line_idx + 1]
			if _selected_pos.y >= item.line_y_point and _selected_pos.y < next_item.line_y_point:
				_selected_line_item = item
				_edit_line(_selected_line_item)
				queue_redraw()
				break
		if _selected_line_item == null and not line_items.is_empty():
			_selected_line_item = line_items.back()
			_edit_line(_selected_line_item)


#============================================================
#  自定义
#============================================================
func get_as_string() -> String:
	var text = ""
	for line_item in line_items:
		text += line_item.origin_text
		text += "\n"
	return text

## 获取宽度
func get_width() -> float:
	return size.x


## 打开绘制的文件
func open_file(path: String) -> void:
	file_path = path
	# 处理每行
	var origin_lines = FileUtil.read_as_lines(path)
	init_lines(origin_lines)


## 初始化所有行
func init_lines(lines: Array) -> void:
	_origin_text = ""
	for line in lines:
		_origin_text += line
	
	LineItem.reset_incr_id()
	_selected_line_item = null
	line_items.clear()
	text_edit.hide()
	
	if lines.is_empty():
		lines.append("")
	_init_string_lines(lines)
	
	queue_redraw()

func _init_string_lines(string_lines: Array):
	match file_path.get_extension().to_lower():
		"md":
			var idx = 0
			while idx < string_lines.size():
				var item = LineItem.new(string_lines[idx])
				item.handle_md()
				if item.type == PName.LineType.Code:
					while true:
						idx += 1
						if idx == string_lines.size() or item.push_line(string_lines[idx]):
							break
					item.handle_md()
				line_items.append( item )
				idx += 1
			
		_:
			for line in string_lines:
				line_items.append( LineItem.new(line) )
	
	line_items.append(LineItem.new(""))


# 绘制位置向下偏移
func _move_next_line_point(item: LineItem):
	line_offset_point += item.get_height(get_width())
	line_offset_point += Config.line_spacing

# 绘制分隔线
func _draw_separation_line(y_point: float, color: Color):
	draw_line(Vector2(0, y_point), Vector2(size.x, y_point), color, 1)

# 绘制每行内容
func _redraw_lines():
	pos_to_line_item.clear()
	_group_to_line_items.clear()
	
	# 绘制
	var width : float = get_width()
	for item in line_items:
		draw_line_item(item, width)
	
	custom_minimum_size.y = line_offset_point + 20
	size.y = 0


## 绘制这个行
func draw_line_item(item: LineItem, width : float):
	# 配置数据
	item.line_y_point = line_offset_point
	pos_to_line_item[item.line_y_point] = item
	
	#var group = int(line_offset_point) % 100
	#if not _group_to_line_items.has(group):
		#_group_to_line_items[group] = {}
	#_group_to_line_items[group][item] = null
	
	# 绘制到当前画布
	item.draw_to(self, width)
	# 向下偏移
	_move_next_line_point(item)


# 更新这个索引的行之后的位置偏移 
func _update_line_after_pos(item_idx: int, offset: float):
	if item_idx == -1 or offset <= 2:
		return
	for i in range(item_idx + 1, line_items.size()):
		line_items[i].line_y_point += offset
	queue_redraw()


# 编辑行
func _edit_line(item: LineItem):
	text_edit.visible = true
	text_edit.custom_minimum_size.x = get_width() + 2
	text_edit.custom_minimum_size.y = item.get_height(get_width())
	text_edit.text = item.origin_text.substr(0, item.origin_text.length())
	text_edit.get_parent_control().position = Vector2(0, item.line_y_point + 1) # 设置位置
	
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
		
		_update_line_after_pos(line_idx, -line_item.get_height(get_width()))


# 更新选中行的内容
func _update_selected_line(hide_text_edit: bool):
	var line_item = _selected_line_item
	if (line_item == null
		or not text_edit.visible
		or line_item.origin_text == text_edit.text
	):     
		return
	if hide_text_edit:
		text_edit.visible = false
		_selected_line_item = null
	
	var last_height : float = line_item.get_height(get_width())
	# 设置内容
	line_item.origin_text = text_edit.text
	line_item.handle_by_path(file_path)
	var height = line_item.get_height(get_width())
	if last_height != height:
		_update_line_after_pos( _selected_line_idx, height - last_height)
	queue_redraw()


#============================================================
#  连接信号
#============================================================
func _on_text_edit_gui_input(event):
	if event is InputEventKey:
		if InputUtil.is_key(event, KEY_ENTER):
			if not Input.is_key_pressed(KEY_CTRL) and _selected_line_item:
				Engine.get_main_loop().root.set_input_as_handled()
				# 插入新的行
				var new_idx : int = _selected_line_idx + 1
				var new_line_item : LineItem = _insert_line(new_idx)
				
				# 更新后面行的偏移
				var offset : float = new_line_item.get_height_of_one_line()
				_update_line_after_pos(new_idx, offset)
				
				FuncUtil.execute_deferred(func():
					# 选中这个行
					_selected_line_item = new_line_item
					_edit_line(new_line_item)
					print("Edit: ", _selected_line_idx )
				)
			
			_update_selected_line(true)
		
		elif InputUtil.is_key(event, KEY_BACKSPACE):
			if (text_edit.get_selected_text() == "" 
				and text_edit.get_caret_column() == 0 
				and text_edit.get_caret_line() == 0
			):
				var selected_line_idx : int = _selected_line_idx
				if selected_line_idx > 0:
					Engine.get_main_loop().root.set_input_as_handled()
					var previous_line : LineItem = line_items[selected_line_idx - 1]
					var text_count : int = previous_line.origin_text.length()
					_delete_line(_selected_line_idx)
					queue_redraw()
					
					await Engine.get_main_loop().process_frame
					_selected_line_item = previous_line
					_edit_line(_selected_line_item)
					text_edit.set_caret_column(text_count)
				
			else:
				# 延迟调用
				FuncUtil.execute_deferred(
					func():
						_selected_line_item.origin_text = text_edit.text
						_selected_line_item.handle_by_path(file_path)
						text_edit.custom_minimum_size.y = 0
						queue_redraw()
				)


func _on_text_edit_resized():
	if _selected_line_item and text_edit.visible:
		var height = _selected_line_item.get_height_by_text(text_edit.text, get_width())
		var last_height = _selected_line_item.get_height(get_width())
		_selected_line_item.line_y_point += height - last_height
		_update_selected_line(false)
		_update_line_after_pos( _selected_line_idx, height - last_height)


func _on_text_edit_focus_exited():
	_update_selected_line(true)
