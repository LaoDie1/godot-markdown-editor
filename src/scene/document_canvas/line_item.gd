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
var line_y_point : int 
var id : int

var line_break : int = TextServer.BREAK_ADAPTIVE | TextServer.BREAK_GRAPHEME_BOUND # 换行方式
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
static func reset_incr_id():
	_incr_id = 0


func handle_by_path(file_path: String):
	if text == "":
		text = origin_text
	
	handle_md()
	#if file_path.get_extension().to_lower() in ["md", "txt"]:
		#handle_md()

## 处理 md 文件内容
func handle_md():
	var tmp = origin_text.strip_edges(true, false)
	text = origin_text
	type = PName.LineType.Normal
	line_margin = Margin.new()
	
	if origin_text.strip_edges().begins_with("---"):
		self.type = PName.LineType.SeparationLine
	else:
		var idx = tmp.find(" ")
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
		PName.LineType.Quote:
			line_margin.left = 8
			line_margin.top = 16
			line_margin.bottom = 16
		_:
			font_size = Config.font_size


## 获取当前字符串总高度（包括换行高度）
func get_total_height(width : int) -> float:
	return get_total_height_by_text(text, width)


func get_total_height_by_text(t: String, width: float) -> float:
	if t.strip_edges() == "":
		return get_font_height()
	return font.get_multiline_string_size(t, alignment, width, font_size, -1, line_break).y + Config.line_spacing + line_margin.top + line_margin.bottom


## 一行的字体的高度
func get_font_height() -> float:
	return font.get_height(font_size) + Config.line_spacing + line_margin.top + line_margin.bottom


## 获取字符串换行后的子行位置
func get_sub_line(point: Vector2, width: float) -> int:
	return ceili( (point.y - line_y_point) / get_font_height() )


## 绘制到这个节点上
func draw_to(canvas: CanvasItem, margin: Margin, width: float):
	var pos = Vector2(margin.left + line_margin.left, line_y_point + get_font_height() - 5)
	match type:
		PName.LineType.Quote:
			var p = Vector2( 0, pos.y - get_font_height() + 8)
			var height = get_total_height(width)
			canvas.draw_rect(Rect2(p + Vector2(8, 0), Vector2(width - 8, height)), Color(0.498039, 1, 0, 0.3), true)
			canvas.draw_rect(Rect2(p, Vector2(8, height)), Color.CHARTREUSE, true)
		
		PName.LineType.SeparationLine:
			canvas.draw_line( Vector2(0, pos.y - 4), Vector2(width, pos.y - 4), Color(0,0,0,0.15), 1)
			return
		
	pos.y -= line_margin.bottom
	
	canvas.draw_multiline_string(
		font, 
		pos, 
		text, 
		alignment, 
		width - margin.right - margin.left - line_margin.left, 
		font_size, 
		-1,
		font_color, 
		line_break
	)

