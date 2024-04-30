#============================================================
#    Line Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 13:30:22
# - version: 4.3.0.dev5
#============================================================
## 行
##
##创建出来时默认加载字符串的行高，等实际加载显示这个行时，再去计算行高。
class_name LineItem


signal height_changed(previous, current)


## 绘制的文字断行方式
const TEXT_BREAK_MODE : int = (
	TextServer.BREAK_MANDATORY 
	| TextServer.BREAK_GRAPHEME_BOUND
)

static var _incr_id : int = -1 # 自增行。每次创建一个当前类的对象，则会自增1


# TODO 下面存在子节点行，并进行处理（待添加）
var children: Array[LineItem]

var id : int = -1 ## 唯一ID
var origin_text : String: ## 原始字符串
	set(v):
		if origin_text != v:
			origin_text = v
			_text = v
			update_status = false
			text_block_update_status = false
var type : int = LineType.Normal ## 行类型
var offset_y : int ## 画布所在的 y 轴点
var alignment : int = HORIZONTAL_ALIGNMENT_LEFT ## 文本对齐方式
var document : Document
var margin : Margin = Margin.new() ## 边距
var blocks : Array = [] ## 文字数据块 # TODO 后续绘制时如果为空，则懒加载数据块

var view_status : bool = false: ## 在视线中的状态
	set(v):
		if view_status != v:
			view_status = v
			if view_status and not update_status:
				update_status = true
				handle_markdown()
var update_status : bool = false ## 是否更新过内容
var text_block_update_status : bool = false ## 文本块更新状态

var font : Font ## 字体
var font_size : int = 16 ## 字体大小
var font_color : Color = Color(1,1,1,1) ## 字体颜色

var _text : String # 显示出来的字符串
var _image : Texture2D: # 当前标签图片
	set(v):
		if _image != v:
			_image = v
			update_status = false
var _line_height : int: # 高度缓存
	set(v):
		if _line_height != v:
			var previous = _line_height
			_line_height = v
			height_changed.emit(previous, v)


#============================================================
#  Standard
#============================================================
func _init(params: Dictionary):
	_incr_id += 1
	self.id = _incr_id
	
	#self.font = Engine.get_main_loop().current_scene.get_theme_default_font()
	self.font = ConfigKey.Display.font.value()
	self.font_size = ConfigKey.Display.font_size.value()
	self.font_color = ConfigKey.Display.text_color.value()
	
	for p in params:
		self[p] = params[p]
	self._line_height = get_text_height()



#============================================================
#  SetGet
#============================================================
static func reset_incr_id() -> void:
	LineItem._incr_id = -1

## 获取计算后的行高
func get_line_height() -> int:
	return _line_height

## 获取当前字符串总高度（包括换行高度）
func get_text_height() -> int:
	if _text == "":
		return 8
	#assert(type != LineType.Error, "还没有设置行的类型")
	if type == LineType.ImageUrl:
		return _line_height + margin.top + margin.bottom
	return get_height_by_text(_text)

## 获取这个字符串的总高度
func get_height_by_text(t: String) -> int:
	if t.strip_edges() == "":
		return get_height_of_one_line()
	var text_width : int = document.width - margin.left - margin.right
	return (
		font.get_multiline_string_size(t, alignment, text_width, font_size, -1, TEXT_BREAK_MODE).y 
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
	return ceili( (point.y - offset_y) / get_height_of_one_line() )

## 获取在画布上的 Rect
func get_rect() -> Rect2:
	var pos = Vector2(0, offset_y)
	var size = Vector2( document.width, get_line_height())
	return Rect2(pos, size)

## 获取内容的 Rect
func get_content_rect() -> Rect2:
	var rect = get_rect()
	rect.position.x += margin.left
	rect.position.y += margin.top
	rect.size.x -= margin.left - margin.right
	rect.size.y -= margin.top - margin.bottom
	return rect


#============================================================
#  操作
#============================================================
## 处理 markdown 字符串行（视线内时调用）
func handle_markdown() -> void:
	# 初始化属性
	type = LineType.Normal
	margin = Margin.new()
	margin.left = 8
	if not Engine.is_editor_hint():
		font_size = ConfigKey.Display.font_size.value()
	
	if origin_text == "":
		return
	
	var info = LineType.get_markdown_line_info(origin_text)
	self.type = info["type"]
	if not text_block_update_status:
		self._text = info["text"]
		text_block_update_status = true
		if type != LineType.Code:
			# TODO 文本段落
			_handle_text_block(_text)
	
	match type:
		LineType.Tile_Larger:
			font_size = font_size * 2
		LineType.Tile_Medium:
			font_size = font_size * 1.65
		LineType.Tile_Small:
			font_size = font_size * 1.25
		LineType.Quote:
			margin.left = 16
			margin.top = 8
			margin.bottom = 16
		LineType.UnorderedList, LineType.SerialNumber:
			margin.left = 24
		LineType.Code:
			margin.top = 8
			margin.left = 2
			margin.bottom = 8
			
			_text = ""
			var lines = origin_text.split("\n")
			for i in range(1, lines.size()-1):
				_text += lines[i] + "\n"
			margin.left = 16
		LineType.SeparationLine:
			_text = ""
		LineType.ImageUrl:
			_image = null
			# 请求这个图片
			var url : String = info["url"]
			_handle_image_url(url, func(image: Image):
				if image and not image.is_empty():
					_image = ImageTexture.create_from_image(image)
					_line_height = image.get_size().y
				else:
					_line_height = get_height_of_one_line()
			)
			return
			
		LineType.Normal:
			margin.top = 8
			margin.bottom = 8
			
		_:
			printerr("其他类型：", type, "  ", info.get("tag"))
	
	# 行高
	_line_height = get_text_height()


func _handle_text_block(text: String):
	var new_text : String = ""
	blocks = BlockType.handle_block(text)
	for item in blocks:
		match item["type"]:
			BlockType.Type.TEXT:
				new_text += item["text"]
				
			BlockType.Type.IMAGE:
				_handle_image_url(item["url"], func(image: Image):
					var texture = ImageTexture.create_from_image(image)
				)
				
			BlockType.Type.LINK:
				if item.get("name", "") != "":
					new_text += item["name"]
				else:
					new_text += item["url"]
	_text = new_text


# 处理图片 URL。这个 [code]callback[/code] 回调方法需要有一个 [Image] 类型的参数接收返回的图片 
func _handle_image_url(url: String, callback: Callable):
	if url.begins_with("http"):
		# 网络图片
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
	else:
		# 本地图片
		var path : String = url
		if not path.begins_with("/"):
			# 相对路径，这个文件下的同级路径
			path = document.file_path.get_base_dir().path_join(url)
		callback.call( Image.load_from_file(path) )


## 绘制到这个节点上。（这时开始计算实际高度）
##[br]
##[br]- [code]canvas[/code]  绘制到的目标画布
func draw_to(canvas: CanvasItem):
	assert(view_status == true, "没有更新 view_status 状态为 true")
	
	var line_rect : Rect2 = get_rect()
	line_rect.position.x += 1
	line_rect.size.x -= 1
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
			canvas.draw_line( Vector2(0, y), Vector2(document.width, y), Color(0,0,0,0.15), 1)
			return
			
		LineType.Code:
			# 代码边框
			canvas.draw_rect( line_rect, Color(0,0,0,0.2), false, 1)
			canvas.draw_rect( line_rect, Color(0,0,0,0.1) )
		
		LineType.UnorderedList:
			var pos : Vector2 = line_rect.position
			pos.x += margin.left / 2 # 边距中间
			pos.y += get_font_height() * 0.75 # 第一行中间
			canvas.draw_circle( pos, 3, font_color)
		
		LineType.ImageUrl:
			if _image:
				var content_rect = get_content_rect()
				canvas.draw_texture(_image, content_rect.position)
				return
	
	if _text:
		var content_rect = get_content_rect()
		var text_width : int = content_rect.size.x
		var text_pos : Vector2 = content_rect.position
		text_pos.y += get_font_height() - 2 # 需要向下偏移一点距离
		canvas.draw_multiline_string(font, text_pos, _text, alignment, text_width, font_size, -1, font_color, TEXT_BREAK_MODE)

