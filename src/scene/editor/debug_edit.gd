#============================================================
#    Debug Editor
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 04:07:09
# - version: 4.3.0.dev5
#============================================================
extends TextEdit


const DEBUG_CONTENT = """ID: {id}
FONT_HEIGHT: {font_height}
TYPE: {type}
FONT_SIZE: {font_size}
SHOW_TEXT: {text}
ORIGIN_TEXT: {origin_text}
BLOCK: {block}
"""


func show_debug(line: LineItem):
	var data = JsonUtil.object_to_dict(line)
	var items = line.blocks.map(func(block): return block.format_code(0))
	data["block"] = "\n".join(items)
	self.text = DEBUG_CONTENT.format(data)

