#============================================================
#    Line Type
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 03:25:47
# - version: 4.3.0.dev5
#============================================================
## 判断这个行的类型
class_name LineType


# 行类型
enum {
	Error = -1, ## 错误的行类型
	
	Normal = 0, ## 普通行
	UnorderedList = 10001, ## 无序列表
	SerialNumber, ## 序号
	Checkbox, ## 复选框
	Quote, ## 引用
	Tag, ## 标签
	SeparationLine, ## 分隔线
	Code, ## 代码
	ImageUrl, ## 图片
	
	Tile_Larger = 20001, ## 大标题
	Tile_Medium, ## 中等标题
	Tile_Small, ## 小标题
	Center, ## 居中
}


# 后面需要空格
const MarkdownTagHead = {
	# 后面需要空格
	"": Normal,
	"#": Tile_Larger,
	"##": Tile_Medium,
	"###": Tile_Small,
	"-": UnorderedList,
	"*": UnorderedList,
	">": Quote,
}
# 后面不需要空格
const MarkdownTagBlock = {
	"---": SeparationLine,
	"```": Code,
}


class LineRegEx:
	var tag_head_regex: RegEx = RegEx.new()
	var tag_block_regex: RegEx = RegEx.new()
	var img_regex: RegEx = RegEx.new()
	
	func _init() -> void:
		tag_head_regex.compile("^(?<indent>\\s*)(?<tag>\\S{1,10})")
		tag_block_regex.compile("^(?<indent>\\s*)(?<tag>.{1,10})")
		img_regex.compile("^\\s*!\\[(?<name>.*?)\\]\\((?<url>.*?)\\)\\s*$")
	
	func get_tag_head(text: String) -> RegExMatch:
		var result = tag_head_regex.search(text) 
		if result:
			var tag = result.get_string("tag")
			if MarkdownTagHead.has(tag):
				return result
		return null
	
	func get_tag_block(text: String) -> RegExMatch:
		return tag_block_regex.search(text.left(5))
	
	func get_img(text: String) -> RegExMatch:
		return img_regex.search(text)

static var line_regex : LineRegEx = LineRegEx.new()



#============================================================
#  自定义
#============================================================
## 获取 markdown 文本信息
static func get_markdown_line_info(origin_text: String) -> Dictionary:
	var text_head_match : RegExMatch = line_regex.get_tag_head(origin_text)
	if text_head_match:
		var tag : String = text_head_match.get_string("tag")
		var indent_str : String = text_head_match.get_string("indent")
		var type : int = MarkdownTagHead[tag]
		var text : String = origin_text.right( -tag.length() - 1 )
		return {
			"indent": indent_str.length(),
			"type": type,
			"tag": tag,
			"text":  text,
		}
	
	var text_block_match : RegExMatch = line_regex.get_tag_block(origin_text)
	if text_block_match:
		if text_block_match:
			var tag : String  = text_block_match.get_string("tag")
			for k in MarkdownTagBlock:
				if tag.begins_with(k):
					var indent_str : String = text_block_match.get_string("indent")
					var type : int = MarkdownTagBlock[k]
					var text : String = origin_text
					return {
						"indent": indent_str.length(),
						"type": type,
						"tag": k,
						"text":  text,
					}
	
	# 匹配图片
	var image_match : RegExMatch = line_regex.get_img(origin_text)
	if image_match:
		var name : String = image_match.get_string("name")
		var url : String = image_match.get_string("url")
		return {
			"type": ImageUrl,
			"url": url,
			"text": name,
		}
	
	return {
		"indent": 0,
		"type": Normal,
		"text": origin_text,
	}


## 返回这个类型的 key 名
static func find_key(type: int) -> String:
	var script = LineType as GDScript
	var map = script.get_script_constant_map()
	for key in map:
		if map[key] == type:
			return key
	return ""
