#============================================================
#    Document
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 10:46:10
# - version: 4.3.0.dev5
#============================================================
## 处理整个文档的行。提前计算文档高度，处理每个行
class_name Document


## 分组间距
const GROUP_SPACING = 300

## 文档最大宽度
var max_width : int = -1


var _file_path: String
var _line_items: Array[LineItem]
var _first_line : LineItem
var _doc_height : int = 0
var _line_group : Dictionary = {}


#============================================================
#  内置
#============================================================
func _init(file_path: String) -> void:
	self._file_path = file_path
	init_lines(FileUtil.read_as_lines(file_path))


#============================================================
#  SetGet
#============================================================
## 获取所有行
func get_lines() -> Array[LineItem]:
	var list : Array[LineItem] = []
	var last : LineItem = _first_line
	while last != null:
		list.append(last)
		last = last.next_line
	return list

## 获取第一行
func get_first_line() -> LineItem:
	return _first_line

## 获取文档字符
func get_text() -> String:
	var lines = get_lines().map(
		func(line: LineItem): 
			return line.origin_text
	)
	return "\n".join(lines)

## 获取文档高度
func get_doc_height():
	return _doc_height

func set_group_line(y: float, line: LineItem):
	var i : int = ceili(y / GROUP_SPACING)
	if not _line_group.has(i):
		_line_group[i] = line

func get_group_line(y) -> LineItem:
	var i : int = int(y / GROUP_SPACING)
	return _line_group.get(i)

## 获取位置上的行
func get_line_by_point(point: Vector2) -> LineItem:
	var start_line : LineItem = get_group_line(point.y)
	if start_line:
		var last_line = [null]
		var mouse_line = start_line.find_next(
			func(line: LineItem):
				last_line[0] = line
				# 在鼠标位置范围内
				if (line.previous_line.line_y_point <= point.y
					and line.line_y_point >= point.y
				):
					return true
		)
		if mouse_line != null:
			return mouse_line.previous_line
		else:
			if last_line[0]:
				return last_line[0]
			return start_line
	return null

## 获取这一行
func get_line(idx: int) -> LineItem:
	assert(idx >= 0, "行索引值必须超过 0")
	var i = 0
	var last_line = _first_line
	while i != idx and last_line != null:
		last_line = last_line.next_line
		i += 1
	return last_line



#============================================================
#  自定义
#============================================================
## 初始化所有行
func init_lines(string_lines: Array) -> void:
	LineItem.reset_incr_id()
	# 处理每行数据的方式
	var file_type = _file_path.get_extension().to_lower()
	if file_type == "md":
		_convert_strings(string_lines)
	else:
		for line in string_lines:
			_line_items.append( LineItem.new(line) )


# 处理 string 列表为 markdown
func _convert_strings(string_lines: Array):
	_first_line = null
	if string_lines.is_empty():
		return
	# 初始化所有行
	_first_line = LineItem.create(null, string_lines[0])
	var last_line : LineItem = _first_line
	for idx in range(1, string_lines.size()):
		last_line = LineItem.create(last_line, string_lines[idx])
	# 处理为 markdown
	_handle_markdown_line(_first_line)
	_first_line.for_next(_handle_markdown_line)

func _handle_markdown_line(current_line: LineItem):
	current_line.handle_markdown(max_width)
	if current_line.type == LineType.Code:
		# 合并代码块行
		var line = current_line.find_next(func(next: LineItem):
			next.handle_markdown(max_width)
			return next.type == LineType.Code
		)
		merge_line(current_line, line)


## 合并
func merge_line(from_line: LineItem, to_line: LineItem):
	if from_line == null or to_line == null:
		return
	var new_text = from_line.origin_text
	var last : LineItem = from_line.next_line
	while last and last != to_line:
		new_text += "\n" + last.origin_text
		last = last.next_line
	if last == null:
		print("不是 from 行的后面的行")
		return
	new_text += "\n" + last.origin_text
	
	# 合并字符为新的行
	from_line.origin_text += new_text
	from_line.next_line = to_line.next_line
	if to_line.next_line:
		to_line.next_line.previous_line = from_line
	
	# 重新计算
	from_line.handle_markdown(max_width)


## 插入新的行到这一行之前
func insert_before(from_line: LineItem, text: String = "") -> LineItem:
	var new_line = LineItem.new(text)
	var previous = from_line.previous_line
	from_line.previous_line = new_line
	new_line.next_line = from_line
	new_line.previous_line = previous
	previous.next_line = new_line
	
	# 后面的位置进行偏移
	var y_offset = new_line.get_text_height(max_width)
	new_line.for_next(
		func(line: LineItem):
			line.line_y_point += y_offset
	)
	
	return new_line

const TEMPLATE = "%-5d %-10d %-10d %s"
## 增加文档高度
func add_doc_height(line_item: LineItem):
	_doc_height += line_item.get_line_height() + Config.line_spacing
	print(TEMPLATE % [
		line_item.id, 
		line_item.get_line_height(),
		line_item.line_y_point,
		line_item.origin_text,
	])

## 计算文档高度
func update_doc_height():
	_line_group.clear()
	_doc_height = 0
	if _first_line != null:
		print("=".repeat(50))
		print(TEMPLATE.replace("d", "s") % ["id", "height", "y axis", "text"])
		
		add_doc_height(_first_line)
		set_group_line(0, _first_line)
		_first_line.for_next(
			func(line: LineItem):
				line.line_y_point = _doc_height
				set_group_line(_doc_height, line)
				# 向下偏移文档位置
				add_doc_height(line)
		)
		


## 绘制到画布。需要在 canvas 节点的 [method CanvasItem._draw] 中调用这个方法
func draw(canvas: CanvasItem):
	if _first_line == null:
		return 0
	_first_line.draw_to(canvas, max_width)
	var last_line : LineItem = _first_line
	_first_line.find_next(
		func(line: LineItem):
			last_line = line
			# TODO 如果位置超出了节点的高度，则不再绘制
			line.draw_to(canvas, max_width)
	)

