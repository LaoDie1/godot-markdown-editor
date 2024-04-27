#============================================================
#    Block Regex
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 11:15:35
# - version: 4.3.0.dev5
#============================================================
## 处理块
class_name BlockUtil


class BlockRegex:
	var regex = RegEx.new()
	
	func _init() -> void:
		regex.compile(
			"(?<img_url>!\\[(.*?)\\]\\((.*?)\\))"
			+ "|(?<title_link>\\[(.*?)\\]\\((.*?)\\))"
			+ "|(?<link>\\<(.*?)\\>)"
		)


static var block_regex : BlockRegex = BlockRegex.new()


static func handle_block(text: String):
	var block_regex = BlockRegex.new()
	var results : Array[RegExMatch] = block_regex.regex.search_all(text)
	print(results)
	#for result in results:
		#var img_url = result.get_string("img_url")
		#var title_link = result.get_string("title_link")
		#var link = result.get_string("link")
		#print(img_url, title_link, link)
	
