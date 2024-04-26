#============================================================
#    Block
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 20:42:52
# - version: 4.3.0.dev5
#============================================================
# 数据块
class_name Block


var begin : int = -1
var end : int = -1
var token : int

var text : String 
var next_block : Block # 连着通一个块中的其他样式


func _init(bytes: PackedByteArray, begin: int) -> void:
	self.begin = begin


func format_code(indent: int = 0):
	var text = "\t".repeat(indent) + text
	
	var blocks : Array[Block] = []
	var last : Block = next_block
	while last:
		blocks.append(last)
		last = last.next_block
	
	var items = blocks.map(func(block: Block): return block.format_code(indent + 1))
	text += "".join(items)
	return text
