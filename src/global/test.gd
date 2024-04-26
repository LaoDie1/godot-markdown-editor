#============================================================
#    Test
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 03:40:25
# - version: 4.3.0.dev5
#============================================================
@tool
extends EditorScript


func _run() -> void:
	var script = LineType as GDScript
	var map = script.get_script_constant_map()
	JsonUtil.print_stringify(map, "\t")
	
