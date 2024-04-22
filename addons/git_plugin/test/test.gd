#============================================================
#    Test
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 21:08:18
# - version: 4.2.1.stable
#============================================================
extends Node2D


func print_data(data):
	print( JSON.stringify(data, "\t") )


func _ready() -> void:
	var files = await GitPlugin_Show.files("e1e9b2e64615505277655531905e782e7be9b3f9")
	print(files)

