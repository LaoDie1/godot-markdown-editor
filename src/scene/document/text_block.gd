#============================================================
#    Text Block
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 19:42:48
# - version: 4.3.0.dev5
#============================================================
## 每行的文本块。
class_name TextBlock


var text : String
var type : int = BlockType.TEXT 
var styles : Array = []  # 一个文本块有多个样式标记


func _init(text: String) -> void:
	pass
