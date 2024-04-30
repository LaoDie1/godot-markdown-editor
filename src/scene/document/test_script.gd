#============================================================
#    Test Script
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 11:23:02
# - version: 4.3.0.dev5
#============================================================
@tool
extends EditorScript


func _run() -> void:
	pass
	
	var text = "你好 hello <https://aaa/> ![img](/test/img.png)  ~~aaa~~ [百度](www.baidu.com) "
	var results = BlockType.handle_block(text)
	JsonUtil.print_stringify( results , "\t")

