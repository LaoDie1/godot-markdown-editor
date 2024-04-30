#============================================================
#    Block Type
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 20:42:52
# - version: 4.3.0.dev5
#============================================================
## 文本数据块
class_name BlockType


enum Type {
	TEXT,     ## 文本
	IMAGE,    ## 图片
	LINK,     ## 链接
	
	ITALIC,   ## *
	BOLD,     ## **
	ITALIC_BOLD, ## ***
	CODE,     ## 代码  `
	DELETE,   ## 删除线 ~~
}


class BlockRegex:
	var regex = RegEx.new()
	func _init() -> void:
		regex.compile(
			"(?<IMAGE>!\\[(.*?)\\]\\((.*?)\\))"   # 图片
			+ "|(?<LINK>\\[(.*?)\\]\\((.*?)\\))" # 链接
			+ "|(?<LINK>\\<(.*?)\\>)"
			#+ "|(?<BOLD>(\\*{1,})(.*?)(\\*{1,}))"
		)

static var block_regex : BlockRegex = BlockRegex.new()


## 处理文本块（代码块则不需要调用）
static func handle_block(text: String) -> Array:
	var block_regex = BlockRegex.new()
	var blocks : Array = []
	var last_from : int = 0
	var result : RegExMatch = block_regex.regex.search(text, last_from)
	while result != null:
		blocks.append( {
			"type": Type.TEXT,
			"text": text.substr(last_from, result.get_start() - last_from),
		} ) 
		
		var type : int = Type.get( result.names.keys()[0], 0)
		var data = {
			"type": type,
			"text": result.get_string(),
		}
		match type:
			Type.IMAGE:
				data["name"] = result.strings[2]
				data["url"] = result.strings[3]
			Type.LINK:
				if result.strings[6] != "":
					data["name"] = result.strings[5]
					data["url"] = result.strings[6]
				else:
					data["url"] = result.strings[8]
		blocks.append(data)
		last_from = result.get_end()
		result = block_regex.regex.search(text, last_from)
	
	if last_from < text.length():
		blocks.append({
			"type": Type.TEXT,
			"text": text.substr(last_from),
		})
	return blocks


