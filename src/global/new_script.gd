#============================================================
#    New Script
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 02:41:10
# - version: 4.3.0.dev5
#============================================================
@tool
extends EditorScript


func _run() -> void:
	pass
	
	var texture : Texture2D = load("res://icon.svg")
	texture.get_image().save_png("res://icon.png")
	
