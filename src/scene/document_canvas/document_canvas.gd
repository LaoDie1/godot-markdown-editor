#============================================================
#    Document Canvas
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 10:52:13
# - version: 4.3.0.dev5
#============================================================
extends Control


@export var margin : Rect2 = Rect2(8, 0, 8, 0)

@onready var text_edit = %TextEdit


var file_path : String = ""
var origin_lines : Array = []
var line_offset_point : float = 0
var line_items : Array[LineItem] = []
var p_to_item : Dictionary = {} # 点击的位置对应的行字符串

var _selected_pos : Vector2 = Vector2()
var _selected_line_item : LineItem = null


#============================================================
#  内置
#============================================================
func _draw():
	line_offset_point = 0
	
	# 顶部文字
	var top_item_left = LineItem.new("2024/04/22  11:35:00", {
		font_color = Config.accent_color,
		font_size = Config.top_font_size,
		alignment = HORIZONTAL_ALIGNMENT_LEFT,
	})
	_draw_line_item(top_item_left, false)
	var top_item_right = LineItem.new("共 xxx 个文字", {
		font_color = Config.accent_color,
		font_size = Config.top_font_size,
		alignment = HORIZONTAL_ALIGNMENT_RIGHT,
	})
	_draw_line_item(top_item_right, false)
	line_offset_point += top_item_left.get_total_height() + 2
	
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
		for idx in line_items.size() - 1:
			var item : LineItem = line_items[idx]
			var next_item : LineItem = line_items[idx + 1]
			if _selected_pos.y >= item.line_y_point and _selected_pos.y < next_item.line_y_point:
				_selected_line_item = item
				_select_line(_selected_line_item)
				queue_redraw()
				break


#============================================================
#  自定义
#============================================================
# 绘制位置向下偏移
func _line_point_offset(item: LineItem, width: float):
	line_offset_point += item.get_total_height(width)


## 打开绘制的文件
func open_file(path: String) -> void:
	LineItem.reset_line()
	file_path = path
	origin_lines = FileUtil.read_as_lines(path)
	line_items.clear()
	
	# 处理每行
	match file_path.get_extension().to_lower():
		"md":
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
	for item in line_items:
		draw_line_item(item, size.x)


## 绘制这个行
func draw_line_item(item: LineItem, width : float):
	# 配置数据
	item.font = Config.font
	item.font_color = Config.text_color
	item.line_y_point = line_offset_point
	p_to_item[item.line_y_point] = item
	
	# 开始绘制
	_draw_line_item(item)
	# 向下偏移
	_line_point_offset(item, width)


# 实际绘制
func _draw_line_item(
	item: LineItem,
	width : float = 0
):
	if width == 0:
		width = size.x - margin.size.x * 2
	# 绘制内容
	var line_height : int = item.get_font_height()
	var idx : int = item.text.find(PName.DATA_SPLIT_CHAR)
	var type : String = (item.text.substr(0, idx) if idx > -1 else "")
	draw_multiline_string(
		item.font, 
		Vector2(margin.position.x, item.line_y_point + line_height - 4), 
		item.text, 
		item.alignment, 
		width, 
		item.font_size, 
		-1,
		item.font_color, TextServer.BREAK_GRAPHEME_BOUND
	)


# 选中行
func _select_line(item: LineItem):
	text_edit.visible = true
	text_edit.size.x = size.x
	text_edit.size.y = item.get_total_height(size.x) + 2
	text_edit.position = Vector2(0, item.line_y_point) + Vector2(8, 2)
	text_edit.text = item.origin_text.substr(0, item.origin_text.length())
	
	text_edit.add_theme_font_size_override("font_size", item.font_size)
	text_edit.add_theme_font_override("font", item.font)
	
	text_edit.grab_focus()
	
	await Engine.get_main_loop().process_frame
	
	var v = text_edit.get_line_column_at_pos( text_edit.get_local_mouse_pos() , false)
	text_edit.set_caret_column(v.x)
	print(v.x)


#============================================================
#  连接信号
#============================================================
func _on_text_edit_visibility_changed():
	if text_edit and not text_edit.visible:
		if _selected_line_item:
			if _selected_line_item.origin_text != text_edit.text:
				_selected_line_item.origin_text = text_edit.text
				if file_path.get_extension().to_lower() == "md":
					_selected_line_item.handle_md()
				queue_redraw()


