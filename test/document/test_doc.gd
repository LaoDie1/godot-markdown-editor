#============================================================
#    Doc Height
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 10:59:46
# - version: 4.3.0.dev5
#============================================================
extends Control


static var document : Document


@onready var doc_canvas: DocCanvas = %DocCanvas


func _ready() -> void:
	var file_path = "res://test/SimpleTest.md"
	doc_canvas.load_file(file_path)


