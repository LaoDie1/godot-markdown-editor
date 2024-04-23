#============================================================
#    Line Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 13:30:22
# - version: 4.3.0.dev5
#============================================================
class_name LineItem


const MD_TYPE_STRING_DICT = {
	"": PName.LineType.Normal,
	"#": PName.LineType.Tile_Larger,
	"##": PName.LineType.Tile_Medium,
	"###": PName.LineType.Tile_Small,
	"-": PName.LineType.Colon,
	"*": PName.LineType.Colon,
	">": PName.LineType.Quote,
	"---": PName.LineType.SeparationLine,
	"```": PName.LineType.Code,
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
# TODO 下面存在子节点行，待添加
var children: Array[LineItem]

var line_break : int = TextServer.BREAK_MANDATORY | TextServer.BREAK_ADAPTIVE | TextServer.BREAK_GRAPHEME_BOUND # 换行方式
var font : Font
var alignment : int
var font_size : int
var font_color : Color
var line_margin : Margin = Margin.new()


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
	#if file_path.get_extension().to_lower() in ["md", "txt"]:
		#handle_md()

## 处理 md 文件内容
func handle_md() -> void:
	text = origin_text
	type = PName.LineType.Normal
	line_margin = Margin.new()
	
	var tmp = origin_text.strip_edges(true, false)
	var type_string : String = tmp.substr(0, 3)
	if not MD_TYPE_STRING_DICT.has(type_string):
		var idx = tmp.find(" ")
		if idx > -1:
			type_string = tmp.substr(0, idx)
			text = origin_text.substr(idx + 1)
	
	if MD_TYPE_STRING_DICT.has(type_string):
		type = MD_TYPE_STRING_DICT[type_string]
		text = tmp.substr(type_string.length() + 1)
	else:
		text = origin_text
	
	line_margin.left = 8
	
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
			line_margin.left = 16
			line_margin.top = 8
			line_margin.bottom = 16
		PName.LineType.Colon, PName.LineType.SerialNumber:
			line_margin.left = 24
		
		PName.LineType.Code:
			line_margin.top = 8
			line_margin.bottom = 8
			
			text = ""
			var lines = origin_text.split("\n")
			for i in range(1, lines.size()-1):
				text += lines[i] + "\n"
			line_margin.left = 16
		_:
			font_size = Config.font_size


## 推入新的行，返回是否已经闭合
func push_line(line: String) -> bool:
	self.origin_text += "\n" + line
	if type == PName.LineType.Code:
		if line.strip_edges().begins_with("```"):
			return true
	return false

## 获取当前字符串总高度（包括换行高度）
func get_height(width : float) -> float:
	return get_height_by_text(text, width)

## 获取这个字符串的总高度
func get_height_by_text(t: String, width: float) -> float:
	if t.strip_edges() == "":
		return get_height_of_one_line()
	var text_width : float = width - line_margin.left
	return (font.get_multiline_string_size(t, alignment, text_width, font_size, -1, line_break).y 
		+ line_margin.top 
		+ line_margin.bottom
	)

## 一行的字体的总体高度
func get_height_of_one_line() -> float:
	return (font.get_height(font_size) 
		+ line_margin.top 
		+ line_margin.bottom
	)

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
			var rect = Rect2(0, line_y_point, width, get_height(width) + 8)
			canvas.draw_rect( rect, Color(0,0,0,0.1) )
		
		PName.LineType.Colon:
			var y = line_y_point + get_font_height() / 2 + line_margin.top + 4
			canvas.draw_circle( Vector2(10, y), 4, Color(0,0,0,0.33))
	
	var text_width : float = width - line_margin.left
	var text_pos : Vector2 = Vector2(line_margin.left, line_y_point + get_font_height() + line_margin.top)
	canvas.draw_multiline_string(font, text_pos, text, alignment, text_width, font_size, -1, font_color, line_break)

