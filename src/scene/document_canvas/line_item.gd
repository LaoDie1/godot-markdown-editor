#============================================================
#    Line Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 13:30:22
# - version: 4.3.0.dev5
#============================================================
class_name LineItem


signal height_changed


const MD_TYPE_STRING_DICT = {
	"": PName.LineType.Normal,
	"#": PName.LineType.Tile_Larger,
	"##": PName.LineType.Tile_Medium,
	"###": PName.LineType.Tile_Small,
	"-": PName.LineType.UnorderedList,
	"*": PName.LineType.UnorderedList,
	">": PName.LineType.Quote,
	"---": PName.LineType.SeparationLine,
	"```": PName.LineType.Code,
	"![": PName.LineType.Image,
}

static var _incr_id : int = 0: # 自增行。每次创建一个当前类的对象，则会自增1
	get:
		_incr_id += 1
		return _incr_id


## 原始字符串
var origin_text : String
## 显示出来的字符串
var text : String 
## 输出类型
var type : int = PName.LineType.Normal

## 画布所在的 y 轴点
var line_y_point : int:
	set(v):
		line_y_point = v
		if control_node:
			control_node.position.y = v
var id : int
var control_node : Control

# TODO 下面存在子节点行，并进行处理（待添加）
var children: Array[LineItem]

var line_break : int = TextServer.BREAK_MANDATORY | TextServer.BREAK_ADAPTIVE | TextServer.BREAK_GRAPHEME_BOUND # 换行方式
var font : Font
var alignment : int
var font_size : int
var font_color : Color
var margin : Margin = Margin.new()
var blocks : Array = [] # 块

var _last_height : int = 0
var _image_regex: RegEx = RegEx.new()
var _image : Image


#============================================================
#  Standard
#============================================================
func _init(text: String, params: Dictionary = {}):
	id = _incr_id
	
	self.origin_text = text
	self.text = text
	font = Config.font
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	font_size = Config.font_size
	font_color = Config.text_color
	_image_regex.compile("!\\[(?<name>.*?)\\]\\((?<url>.*?)\\)")
	
	# 自动设置参数
	if not params.is_empty():
		for p in params:
			if p in self:
				self[p] = params[p]


#============================================================
#  Custom
#============================================================
static func reset_incr_id() -> void:
	LineItem._incr_id = 0

## 根据文件类型操作处理
func handle_by_path(file_path: String) -> void:
	if text == "":
		text = origin_text
	handle_md()

## 处理 md 文件内容
func handle_md() -> void:
	# 初始化属性
	text = origin_text
	type = PName.LineType.Normal
	margin = Margin.new()
	font_size = Config.font_size
	margin.left = 8
	
	# 判断类型
	var tmp = origin_text.strip_edges(true, false)
	var type_string : String = tmp.substr(0, 3)
	if not MD_TYPE_STRING_DICT.has(type_string):
		var idx = tmp.find(" ")
		if idx > -1:
			type_string = tmp.substr(0, idx)
			text = origin_text.substr(idx + 1)
		elif tmp.begins_with("!["):
			
			type_string = "!["
			var result = _image_regex.search(origin_text)
			if result:
				var url = result.get_string("url")
				if url.begins_with("http"):
					text = url
					# 请求这个图片
					_handle_image_url(url, func(image: Image):
						if not image.is_empty():
							blocks.append(ImageTexture.create_from_image(image))
						
						# 总高度
						_last_height = 0
						for block in blocks:
							if block is ImageTexture:
								_last_height += image.get_size().y + Config.line_spacing
					)
				
			else:
				printerr("图片数据格式错误", origin_text)
	
	if MD_TYPE_STRING_DICT.has(type_string):
		type = MD_TYPE_STRING_DICT[type_string]
		if type != PName.LineType.Image:
			text = tmp.substr(type_string.length() + 1)
	else:
		text = origin_text
	
	match type:
		PName.LineType.Normal:
			font_size = Config.font_size
		PName.LineType.Tile_Larger:
			font_size = 32
		PName.LineType.Tile_Medium:
			font_size = 28
		PName.LineType.Tile_Small:
			font_size = 24
		PName.LineType.Quote:
			margin.left = 16
			margin.top = 8
			margin.bottom = 16
		PName.LineType.UnorderedList, PName.LineType.SerialNumber:
			margin.left = 24
		PName.LineType.Code:
			margin.top = 8
			margin.bottom = 8
			
			text = ""
			var lines = origin_text.split("\n")
			for i in range(1, lines.size()-1):
				text += lines[i] + "\n"
			margin.left = 16
	
	var height = get_height( DocumentCanvas.instance.get_width() )
	if height != _last_height:
		_last_height = height
		height_changed.emit()
	
	if _last_height == 0:
		_last_height = get_height_of_one_line()


# 处理图片 URL。这个 [kbd]callback[/kbd] 回调方法需要有一个 [Image] 类型的参数接收返回的图片 
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


## 推入新的行，返回是否已经闭合
func push_line(line: String) -> bool:
	self.origin_text += "\n" + line
	if type == PName.LineType.Code:
		if line.strip_edges().begins_with("```"):
			return true
	return false

## 获取当前字符串总高度（包括换行高度）
func get_height(width : float) -> float:
	if type == PName.LineType.Image:
		return _last_height + margin.top + margin.bottom
	return get_height_by_text(text, width)

## 获取这个字符串的总高度
func get_height_by_text(t: String, width: float) -> float:
	if t.strip_edges() == "":
		return get_height_of_one_line()
	var text_width : float = width - margin.left - margin.right
	return (font.get_multiline_string_size(t, alignment, text_width, font_size, -1, line_break).y 
		+ margin.top 
		+ margin.bottom
	)

## 一行的字体计算后的总体高度
func get_height_of_one_line() -> float:
	return (font.get_height(font_size) 
		+ margin.top 
		+ margin.bottom
	)

## 获取字体高度
func get_font_height() -> float:
	return font.get_height(font_size)

## 获取字符串换行后的子行
func get_sub_line(point: Vector2) -> int:
	return ceili( (point.y - line_y_point) / get_height_of_one_line() )

## 绘制到这个节点上
##[br]
##[br][kbd]canvas[/kbd]  绘制到的目标画布
##[br][kbd]width[/kbd]  整体宽度
func draw_to(canvas: CanvasItem, width: float):
	match type:
		PName.LineType.Quote:
			# 面板
			var panel_rect = Rect2()
			panel_rect.position.x = 0
			panel_rect.position.y = line_y_point 
			panel_rect.size.x = width
			panel_rect.size.y = get_height(width)
			canvas.draw_rect(panel_rect, Color(0.498039, 1, 0, 0.3), true)
			# 左线条
			var left_strip : Rect2 = panel_rect
			left_strip.size.x = 8
			canvas.draw_rect(left_strip, Color.CHARTREUSE, true)
		
		PName.LineType.SeparationLine:
			var y = line_y_point + get_height_of_one_line() / 2
			canvas.draw_line( Vector2(0, y), Vector2(width, y), Color(0,0,0,0.15), 1)
			return
		
		PName.LineType.Code:
			var rect = Rect2(0, line_y_point+1, width, get_height(width) + 8)
			canvas.draw_rect( rect, Color(0,0,0,0.2), false, 1)
			canvas.draw_rect( rect, Color(0,0,0,0.1) )
		
		PName.LineType.UnorderedList:
			var y = line_y_point + get_font_height() / 2 + margin.top + 6
			canvas.draw_circle( Vector2(10, y), 3, Color(0,0,0,0.33))
		
		PName.LineType.Image:
			if not blocks.is_empty():
				var pos = Vector2(margin.left, line_y_point)
				canvas.draw_texture(blocks[0], pos)
			
			return
	
	var text_width : float = width - margin.left
	var text_pos : Vector2 = Vector2(margin.left, line_y_point + get_font_height() + margin.top)
	canvas.draw_multiline_string(font, text_pos, text, alignment, text_width, font_size, -1, font_color, line_break)

