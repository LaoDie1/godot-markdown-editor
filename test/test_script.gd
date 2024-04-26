#============================================================
#    Test Script
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 19:01:19
# - version: 4.3.0.dev5
#============================================================
@tool
extends EditorScript


func _run() -> void:
	var text = "hello world"
	var bytes = text.to_utf8_buffer()
	print(bytes[0] == KEY_H)
	
