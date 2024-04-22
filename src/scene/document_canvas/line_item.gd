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
}

static var _incr_line : int = 0: # 自增行。每次创建一个当前类的对象，则会自增1
	get:
		_incr_line += 1
		return _incr_line


## 原始字符串
var origin_text : String
## 显示出来的字符串
var text : String 
## 输出类型
var type : int = PName.LineType.Normal

## 画布所在的 y 轴点
var line_y_point : int 
## 所在行
var line : int

var font : Font
var alignment : int
var font_size : int
var font_color : Color


#============================================================
#  Standard
#============================================================
func _init(text: String, params: Dictionary = {}):
	line = _incr_line
	
	self.origin_text = text
	self.text = text + "\n"
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
static func reset_line():
	_incr_line = 0


## 处理 md 文件内容
func handle_md():
	var tmp = origin_text.strip_edges(true, false)
	var idx = tmp.find(" ")
	text = origin_text
	type = PName.LineType.Normal
	
	var type_string : String
	if idx > -1:
		type_string = origin_text.substr(0, idx)
	if MD_TYPE_STRING_DICT.has(type_string):
		type = MD_TYPE_STRING_DICT[type_string]
		text = origin_text.substr(idx + 1)
	
	match type:
		PName.LineType.Normal:
			font_size = Config.font_size
		PName.LineType.Tile_Larger:
			font_size = 32
		PName.LineType.Tile_Medium:
			font_size = 28
		PName.LineType.Tile_Small:
			font_size = 24
		_:
			font_size = Config.font_size


## 获取当前字符串总高度（包括换行高度）
func get_total_height(width : int) -> float:
	if text.strip_edges() == "":
		return get_font_height()
	return font.get_multiline_string_size(text, alignment, width, font_size, -1, TextServer.BREAK_GRAPHEME_BOUND).y + Config.line_spacing


## 一行的字体的高度
func get_font_height() -> float:
	return font.get_height(font_size) + Config.line_spacing


## 获取字符串换行后的子行位置
func get_sub_line(point: Vector2, width: float) -> int:
	return ceili( (point.y - line_y_point) / get_font_height() )

## 绘制到这个节点上
func draw_to(canvas: CanvasItem, margin: Rect2, width: float):
	# 绘制内容
	canvas.draw_multiline_string(
		font, 
		Vector2(margin.position.x, line_y_point + get_font_height() - 4), 
		text, 
		alignment, 
		width, 
		font_size, 
		-1,
		font_color, 
		TextServer.BREAK_GRAPHEME_BOUND
	)

