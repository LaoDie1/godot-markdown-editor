#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 17:19:07
# - version: 4.3.0.dev5
#============================================================
extends Control


@onready var document_canvas = %DocumentCanvas


func _ready():
	document_canvas.open_file(r"C:\Users\z\Desktop\test.md")

