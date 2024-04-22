#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 17:19:07
# - version: 4.3.0.dev5
#============================================================
extends Control


@onready var menu = %Menu
@onready var document_canvas = %DocumentCanvas
@onready var debug_editor = %DebugEditor
@onready var open_file_dialog = %OpenFileDialog

const CONTENT = """
ID: {id}
FONT_HEIGHT: {font_height}
TYPE: {type}
FONT_SIZE: {font_size}
TEXT: {origin_text}
"""


#============================================================
#  内置
#============================================================
func _ready():
	menu.init_menu({
		"File": ["Open"]
	})
	
	menu.init_shortcut({
		"/File/Open": SimpleMenu.parse_shortcut("Ctrl+O"),
	})


func _process(delta):
	if Time.get_ticks_msec() % 200 == 0:
		if document_canvas._selected_line_item:
			_on_document_canvas_selected( document_canvas._selected_line_item )



#============================================================
#  连接信号
#============================================================
func _on_document_canvas_selected(line_item: LineItem):
	var data = JsonUtil.object_to_dict(line_item)
	data["font_height"] = line_item.get_total_height(document_canvas.get_width())
	debug_editor.text = CONTENT.format( data ).strip_edges()



func _on_menu_menu_pressed(idx, menu_path):
	match menu_path:
		"/File/Open":
			open_file_dialog.popup_centered_ratio(0.75)


func _on_open_file_dialog_file_selected(path):
	document_canvas.open_file(path)
