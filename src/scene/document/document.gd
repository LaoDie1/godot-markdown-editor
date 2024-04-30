#============================================================
#    Document
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 10:46:10
# - version: 4.3.0.dev5
#============================================================
## 处理整个文档的行。提前计算文档高度，处理每个行
class_name Document


signal height_changed


const PAGE_HEIGHT = 300 ## 页面高度


var width : int: ## 文档宽度
	set(v):
		width = v
		for line in get_lines():
			line.update_status = false
			line.view_status = false
var file_path: String
var line_linked_list : TwowayLinkedList = TwowayLinkedList.new() # 所有行

var _document_height : int = 0 # 文档高度
var _last_offset_y : int = 0
var _page_first_line : Dictionary = {} # 分页，每页第一个行



#============================================================
#  内置
#============================================================
func _init(width: int, file_path: String) -> void:
	self.file_path = file_path
	self.width = width
	assert(width > 0, "文档宽度大小必须超过 0！")
	
	init_lines(FileUtil.read_as_lines(file_path))


#============================================================
#  SetGet
#============================================================
## 获取所有行
func get_lines() -> Array[LineItem]:
	return Array(line_linked_list.get_list(), TYPE_OBJECT, "RefCounted", LineItem)

## 获取第一行
func get_first_line() -> LineItem:
	return line_linked_list.get_first()

## 获取最后一行
func get_last_line() -> LineItem:
	return line_linked_list.get_last()

## 获取文档字符
func get_text() -> String:
	var lines = get_lines().map(
		func(line: LineItem): 
			return line.origin_text
	)
	return "\n".join(lines)

## 获取文档高度
func get_document_height():
	return _document_height

## 设置这个位置的组的行
func set_group_line(y: float, line: LineItem):
	var i : int = ceili(y / PAGE_HEIGHT)
	if not _page_first_line.has(i):
		_page_first_line[i] = line

func remove_group_line(y: float, line: LineItem):
	var i : int = ceili(y / PAGE_HEIGHT)
	if _page_first_line.has(i) and _page_first_line[i] == line:
		_page_first_line.erase(i)

## 获取这个 Y 轴位置的行
func get_group_line(y: int) -> LineItem:
	var i : int = y / PAGE_HEIGHT
	while not _page_first_line.has(i) and i > -1:
		i -= 1
	return _page_first_line.get(i)

## 获取位置上的行
func get_line_by_point(point: Vector2) -> LineItem:
	var start_line : LineItem = get_group_line(point.y)
	if start_line:
		if start_line.offset_y > point.y:
			var previous = line_linked_list.get_previous(start_line)
			if previous:
				return previous
			return start_line
		
		var last_line = [null] # 必须用引用类型的数据，否则匿名函数中会赋值不上
		var mouse_line : LineItem = line_linked_list.find_next(start_line, func(line: LineItem):
			last_line[0] = line
			# 在鼠标位置范围内
			var previous : LineItem = line_linked_list.get_previous(line)
			if (previous.offset_y <= point.y
				and line.offset_y >= point.y
			):
				return true
		)
		if mouse_line:
			return line_linked_list.get_previous(mouse_line)
		else:
			if last_line[0]:
				return last_line[0]
			return start_line
	return null


## 获取行
func get_line(idx: int) -> LineItem:
	assert(idx >= 0, "行索引值必须超过 0")
	# TODO 根据索引大小，从开始或者末尾获取
	var i = 0
	var last_line = get_last_line()
	while i != idx and last_line != null:
		last_line = line_linked_list.get_next(last_line)
		i += 1
		if i > 1000:
			breakpoint
	return last_line


#============================================================
#  自定义
#============================================================
## 初始化所有行
func init_lines(string_lines: Array) -> void:
	assert(width > 0, "文档页面宽度不能小于 0")
	LineItem.reset_incr_id()
	
	var offset_y : int = 0
	var line_item : LineItem
	for line in string_lines:
		line_item = create_line(line)
		line_item.offset_y = offset_y
		set_group_line(offset_y, line_item)
		offset_y += line_item.get_line_height() + ConfigKey.Display.line_spacing.value(8)
	_document_height = offset_y
	height_changed.emit()

## 创建新的行（必须以这种方式 new，否则后续参数可能设置不对）
func create_line(text: String, add_to_line: bool = true) -> LineItem:
	var line_item = LineItem.new({
		"origin_text": text,
		"document": self,
	})
	line_item.height_changed.connect(_on_line_height_changed.bind(line_item))
	if add_to_line:
		line_linked_list.append(line_item)
	return line_item

## 插入行
func insert_line(line_item:LineItem, text: String):
	var new_line_item = create_line(text, false)
	line_linked_list.insert_after(new_line_item, line_item)
	new_line_item.offset_y = line_item.offset_y + line_item.get_line_height()
	update_line_offset(new_line_item, new_line_item.get_line_height())
	return new_line_item

## 移除行
func remove_line(line_item: LineItem) -> bool:
	if line_linked_list.has_object(line_item):
		var height = line_item.get_line_height()
		update_line_offset(line_item, -height)
		line_linked_list.erase(line_item)
		return true
	return false

## 合并行
func merge_line(from_line: LineItem, to_line: LineItem):
	if from_line == null or to_line == null:
		return
	# 合并返回中间的行
	var list = line_linked_list.merge(from_line, to_line)
	if not list.is_empty():
		from_line.origin_text += "\n"
		from_line.origin_text += "\n".join(list.map(func(item): return item.text ))
	else:
		Prompt.show_error("不是 from 行的后面的行")

## 更新行的偏移
func update_line_offset(from_line: LineItem, offset: int):
	_document_height += offset
	line_linked_list.for_next(from_line, func(item: LineItem):
		remove_group_line(item.offset_y, item)
		item.offset_y += offset
		set_group_line(item.offset_y, item)
	)

## 获取行数
func get_line_count() -> int:
	return line_linked_list.get_count()

## 绘制到画布。需要在 canvas 节点的 [method CanvasItem._draw] 中调用这个方法
##[br]根据传入的 [param canvas_offset_y] 和 [param max_height] 参数绘制一块的区域内显示的内容
##大大减少运行的消耗
##[br]
##[br]- [code]canvas[/code]  绘制到的目标对象
##[br]- [code]canvas_offset_y[/code]  绘制到画布的偏移的位置
##[br]- [code]max_height[/code]  绘制的最大高度
func draw(canvas: CanvasItem, canvas_offset_y: int, max_height: int):
	if get_first_line() == null:
		return 
	# 绘制的节点位置
	var current_line = get_line_by_point(Vector2(0, canvas_offset_y))
	if not current_line:
		return
	var previous : LineItem = line_linked_list.get_previous(current_line)
	if previous != null:
		current_line = previous
	# 开始绘制
	var max_offset : int = canvas_offset_y + max_height
	line_linked_list.for_next(current_line, func(line: LineItem):
		line.draw_to(canvas)
		if line.offset_y >= max_offset:
			return true
	, true)



#============================================================
#  连接信号
#============================================================
var _update_doc_height_queue : bool = false
func _on_line_height_changed(previous, height, line_item: LineItem):
	var diff = height - previous
	update_line_offset(line_item, diff)
	if not _update_doc_height_queue:
		_update_doc_height_queue = true
		await Engine.get_main_loop().process_frame
		_update_doc_height_queue = false
		height_changed.emit()

