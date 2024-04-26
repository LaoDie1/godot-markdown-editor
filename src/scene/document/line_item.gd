#============================================================
#    Line Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 13:30:22
# - version: 4.3.0.dev5
#============================================================
class_name LineItem


signal height_changed


## 绘制的文字断行方式
const TEXT_BREAK_MODE : int = (
	TextServer.BREAK_MANDATORY 
	| TextServer.BREAK_ADAPTIVE 
	| TextServer.BREAK_GRAPHEME_BOUND
)

static var _incr_id : int = -1 # 自增行。每次创建一个当前类的对象，则会自增1


# TODO 下面存在子节点行，并进行处理（待添加）
var children: Array[LineItem]
var previous_line: LineItem 
var next_line: LineItem 


## 唯一ID
var id : int = -1
## 原始字符串
var origin_text : String = ""
## 显示出来的字符串
var text : String = ""
## 行类型
var type : int = LineType.Normal
## 画布所在的 y 轴点
var line_y_point : int = 0
## 文本对齐方式
var alignment : int = HORIZONTAL_ALIGNMENT_LEFT
## 字体大小
var font_size : int = 16
## 字体颜色
var font_color : Color = Color(1,1,1,1)
## 边距
var margin : Margin = Margin.new()
## 字体
var font : Font


# 空白缩进
var _indent : int = 0
# 文字数据块
var _blocks : Array = []
# 预先计算好的高度
var _line_height : int = 0 # 需要在 handle 中预先计算好
var _image : Texture2D



#============================================================
#  Standard
#============================================================
func _init(text: String, params: Dictionary = {}):
	_incr_id += 1
	
	self.id = _incr_id
	self.origin_text = text
	self.text = text
	if not Engine.is_editor_hint():
		font = Config.font
		font_size = Config.font_size
		font_color = Config.text_color
	
	# 自动设置参数
	if not params.is_empty():
		for p in params:
			if p in self:
				self[p] = params[p]


#============================================================
#  SetGet
#============================================================
static func reset_incr_id() -> void:
	LineItem._incr_id = -1

static func create(previous: LineItem, text: String = "") -> LineItem:
	var line : LineItem = LineItem.new(text)
	line.previous_line = previous
	if previous:
		previous.next_line = line
	return line

## 向前寻找。如果 method 返回结果值为 [code]true[/code] 则停止寻找
func find_previous(method: Callable) -> LineItem:
	var curr : LineItem = next_line
	var result
	while curr:
		result = method.call(curr)
		if result is bool and result:
			return curr
		curr = curr.next_line
	return curr

## 向后寻找。如果 method 返回结果值为 [code]true[/code] 则停止寻找
func find_next(method: Callable) -> LineItem:
	var curr : LineItem = next_line
	var result
	while curr:
		result = method.call(curr)
		if result is bool and result:
			return curr
		curr = curr.next_line
	return curr

## 向前遍历。如果有终止条件，请使用 [method find_previous] 方法
func for_previous(method: Callable) -> void:
	var curr = previous_line
	while curr:
		method.call(curr)
		curr = curr.previous_line

## 向后遍历。如果有终止条件，请使用 [method find_next] 方法
func for_next(method: Callable) -> void:
	var curr = next_line
	while curr:
		method.call(curr)
		curr = curr.next_line

## 获取计算后的行高
func get_line_height() -> int:
	return _line_height

## 获取当前字符串总高度（包括换行高度）
func get_text_height(width : int) -> int:
	if type == LineType.ImageUrl:
		return _line_height + margin.top + margin.bottom
	return get_height_by_text(text, width)

## 获取这个字符串的总高度
func get_height_by_text(t: String, width: int) -> int:
	if t.strip_edges() == "":
		return get_height_of_one_line()
	var text_width : int = width - margin.left - margin.right
	return (font.get_multiline_string_size(t, alignment, text_width, font_size, -1, TEXT_BREAK_MODE).y 
		+ margin.top 
		+ margin.bottom
	)

## 一行的字体计算后的总体高度
func get_height_of_one_line() -> int:
	return (font.get_height(font_size) 
		+ margin.top 
		+ margin.bottom
	)

## 获取字体高度
func get_font_height() -> int:
	return font.get_height(font_size)

## 获取字符串换行后的子行
func get_sub_line(point: Vector2) -> int:
	return ceili( (point.y - line_y_point) / get_height_of_one_line() )

## 获取在画布上的 Rect
func get_rect(width: int) -> Rect2:
	var pos = Vector2(0, line_y_point)
	var size = Vector2( width, get_line_height())
	return Rect2(pos, size)

## 获取内容的 Rect
func get_content_rect(width: int) -> Rect2:
	var rect = get_rect(width)
	rect.position.x += margin.left
	rect.position.y += margin.top
	rect.size.x -= margin.left - margin.right
	rect.size.y -= margin.top - margin.bottom
	return rect


#============================================================
#  操作
#============================================================
## 根据文件类型操作处理 TODO 后续删除这个方法
func handle_by_path(file_path: String, width: int) -> void:
	if text == "":
		text = origin_text
	handle_markdown(width)

## 处理 markdown 字符串行
func handle_markdown(width: int) -> void:
	# 初始化属性
	text = origin_text
	type = LineType.Normal
	margin = Margin.new()
	margin.left = 8
	_line_height = 0
	if not Engine.is_editor_hint():
		font_size = Config.font_size
	
	var info = LineType.get_markdown_line_info(origin_text)
	self.type = info["type"]
	self.text = info["text"]
	match type:
		LineType.Tile_Larger:
			font_size = 32
		LineType.Tile_Medium:
			font_size = 28
		LineType.Tile_Small:
			font_size = 24
		LineType.Quote:
			margin.left = 16
			margin.top = 8
			margin.bottom = 16
		LineType.UnorderedList, LineType.SerialNumber:
			margin.left = 24
		LineType.Code:
			margin.top = 8
			margin.bottom = 8
			
			text = ""
			var lines = origin_text.split("\n")
			for i in range(1, lines.size()-1):
				text += lines[i] + "\n"
			margin.left = 16
		LineType.SeparationLine:
			text = ""
		LineType.ImageUrl:
			_image = null
			# 请求这个图片
			var url : String = info["url"]
			_handle_image_url(url, func(image: Image):
				if not image.is_empty():
					_image = ImageTexture.create_from_image(image)
					_line_height = image.get_size().y
			)
			return
		
		LineType.Normal:
			pass
		
		_:
			printerr("其他类型：", type, "  ", info.get("tag"))
	
	# 行高
	var height = get_text_height( width )
	if _line_height != height:
		_line_height = height
		height_changed.emit()
	elif _line_height == 0:
		_line_height = get_height_of_one_line()
		if _line_height != 0:
			height_changed.emit()


# 处理图片 URL。这个 [code]callback[/code] 回调方法需要有一个 [Image] 类型的参数接收返回的图片 
func _handle_image_url(url: String, callback: Callable):
	var image_name : String = url.md5_text()
	var cache_image_path : String = OS.get_cache_dir().path_join("godot_markdown_editor/%s.webp" % image_name)
	if not FileUtil.file_exists(cache_image_path):
		if not DirAccess.dir_exists_absolute(cache_image_path.get_base_dir()):
			DirAccess.make_dir_recursive_absolute(cache_image_path.get_base_dir())
		# 网络请求图片
		ImageRequest.queue_request(url, func(data):
			var image : Image = data.image
			if not image.is_empty():
				var error = FileUtil.save_image(image, cache_image_path)
				if error != OK:
					printerr("保存失败：", error, "  ", error_string(error), "  ", cache_image_path)
			callback.call(image)
		)
	else:
		var image : Image = FileUtil.load_image(cache_image_path)
		callback.call(image)


## 绘制到这个节点上。需要更新计算高度
##[br]
##[br]- [code]canvas[/code]  绘制到的目标画布
##[br]- [code]width[/code]  整体宽度
func draw_to(canvas: CanvasItem, width: int):
	var line_rect : Rect2 = get_rect(width)
	match type:
		LineType.Quote:
			# 面板
			canvas.draw_rect(line_rect, Color(0.498039, 1, 0, 0.3), true)
			# 左线条
			var left_strip : Rect2 = line_rect
			left_strip.size.x = 8 # 线条宽度 8
			canvas.draw_rect(left_strip, Color.CHARTREUSE, true)
		
		LineType.SeparationLine:
			# 线条居中
			var y : int = line_rect.position.y + line_rect.size.y / 2
			canvas.draw_line( Vector2(0, y), Vector2(width, y), Color(0,0,0,0.15), 1)
			return
			
		LineType.Code:
			# 代码边框
			canvas.draw_rect( line_rect, Color(0,0,0,0.2), false, 1)
			canvas.draw_rect( line_rect, Color(0,0,0,0.1) )
		
		LineType.UnorderedList:
			var pos : Vector2 = line_rect.position
			pos.x += margin.left / 2 # 边距中间
			pos.y += get_font_height() * 0.75 # 第一行中间
			canvas.draw_circle( pos, 3, Color(0,0,0,0.33))
		
		LineType.ImageUrl:
			if _image:
				var content_rect = get_content_rect(width)
				canvas.draw_texture(_image, content_rect.position)
				return
	
	if text:
		var content_rect = get_content_rect(width)
		var text_width : int = content_rect.size.x
		var text_pos : Vector2 = content_rect.position
		text_pos.y += get_font_height()
		canvas.draw_multiline_string(font, text_pos, text, alignment, text_width, font_size, -1, font_color, TEXT_BREAK_MODE)

