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
@onready var file_item_list : ItemList = %FileItemList


const DEBUG_CONTENT = """
ID: {id}
FONT_HEIGHT: {font_height}
TYPE: {type}
TYPE_STRING: {type_string}
FONT_SIZE: {font_size}
TEXT: {origin_text}
"""


#============================================================
#  内置
#============================================================
func _ready():
	menu.init_menu({
		"File": ["New", "-", "Open", "Save", "-", "Print"]
	})
	
	menu.init_shortcut({
		"/File/Open": SimpleMenu.parse_shortcut("Ctrl+O"),
		"/File/Save": SimpleMenu.parse_shortcut("Ctrl+S"),
	})
	
	var current_dir = Config.get_value(ConfigKey.Path.current_dir, "")
	open_file_dialog.current_dir = current_dir
	for file in Config.get_opened_files():
		add_file_item(file)


func _process(delta):
	if Time.get_ticks_msec() % 200 == 0:
		if document_canvas._selected_line_item:
			_on_document_canvas_selected( document_canvas._selected_line_item )


#============================================================
#  自定义
#============================================================
func add_file_item(file_path):
	file_item_list.add_item(file_path)
	file_item_list.set_item_metadata(file_item_list.item_count - 1, file_path)


#============================================================
#  连接信号
#============================================================
func _on_document_canvas_selected(line_item: LineItem):
	if debug_editor.visible:
		var data = JsonUtil.object_to_dict(line_item)
		data["font_height"] = line_item.get_height(document_canvas.get_width())
		data["type_string"] = PName.LineType.find_key(line_item.type)
		debug_editor.text = DEBUG_CONTENT.format( data ).strip_edges()


func _on_menu_menu_pressed(idx, menu_path):
	match menu_path:
		"/File/New":
			document_canvas.file_path = ""
			document_canvas.init_lines([])
		
		"/File/Open":
			open_file_dialog.popup_centered_ratio(0.75)
		
		"/File/Save":
			push_error("暂未实现功能")
			printerr("暂未实现功能")
		
		"/File/Print":
			var text = document_canvas.get_as_string()
			print(text)


func _on_open_file_dialog_file_selected(path: String):
	document_canvas.open_file(path)
	Config.set_value(ConfigKey.Path.current_dir, path.get_base_dir())
	if Config.add_opened_file(path):
		add_file_item(path)
		file_item_list.select( file_item_list.item_count - 1 )
	else:
		for id in file_item_list.item_count:
			if file_item_list.get_item_metadata(id) == path:
				file_item_list.select(id)
				break


func _on_file_item_list_item_selected(index: int):
	var file_path = file_item_list.get_item_metadata(index)
	document_canvas.open_file(file_path)
