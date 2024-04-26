#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 17:19:07
# - version: 4.3.0.dev5
#============================================================
extends Control

const DEBUG_CONTENT = """
ID: {id}
FONT_HEIGHT: {font_height}
TYPE: {type}
TYPE_STRING: {type_string}
FONT_SIZE: {font_size}
SHOW_TEXT: {text}
ORIGIN_TEXT: {origin_text}
"""

@onready var menu : SimpleMenu = %Menu
@onready var document_canvas : DocumentCanvas = %DocumentCanvas
@onready var document_text_edit: TextEdit = %DocumentTextEdit

@onready var debug_editor = %DebugEditor
@onready var file_item_list : ItemList = %FileItemList
@onready var open_file_dialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog

var current_file : String:
	set(v):
		if current_file != v:
			current_file = v
			if current_file != "":
				document_canvas.open_file(current_file)
				document_text_edit.text = FileUtil.read_as_string(current_file)
			else:
				document_canvas.file_path = ""
				document_canvas.init_lines([])
				document_text_edit.text = ""


#============================================================
#  内置
#============================================================
func _ready():
	menu.init_menu({
		"File": ["New", "-", "Open", "Save", "-", "Print"]
	})
	menu.init_shortcut({
		"/File/New": SimpleMenu.parse_shortcut("Ctrl+N"),
		"/File/Open": SimpleMenu.parse_shortcut("Ctrl+O"),
		"/File/Save": SimpleMenu.parse_shortcut("Ctrl+S"),
	})
	menu.init_icon({
		"/File/New": Icons.get_icon("File"),
		"/File/Open": Icons.get_icon("Load"),
		"/File/Save": Icons.get_icon("Save"),
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
func add_file_item(file_path: String):
	if FileAccess.file_exists(file_path):
		var idx : int = file_item_list.item_count
		file_item_list.add_item(file_path.get_file())
		file_item_list.set_item_icon(idx, Icons.get_icon("File"))
		file_item_list.set_item_metadata(idx, file_path)
		file_item_list.set_item_tooltip(idx, file_path)


func open_file(file_path: String):
	current_file = file_path

func save_file(file_path: String):
	var text = document_canvas.get_string()
	if FileUtil.write_as_string(file_path, text):
		print("已保存文件：", file_path)
		current_file = file_path
		add_file_item(file_path)
		Config.add_opened_file(file_path)
	else:
		printerr("保存失败：", FileAccess.get_open_error())


#============================================================
#  连接信号
#============================================================
func _on_document_canvas_selected(line_item: LineItem):
	if debug_editor.visible:
		var data = JsonUtil.object_to_dict(line_item)
		data["font_height"] = line_item.get_text_height(document_canvas.get_width())
		data["type_string"] = LineType.find_key(line_item.type)
		debug_editor.text = DEBUG_CONTENT.format( data ).strip_edges()


func _on_menu_menu_pressed(idx, menu_path):
	match menu_path:
		"/File/New":
			current_file = ""
			file_item_list.deselect_all()
		
		"/File/Open":
			open_file_dialog.popup_centered_ratio()
		
		"/File/Save":
			if current_file == "" or not FileAccess.file_exists(current_file):
				save_file_dialog.popup_centered_ratio()
			else:
				save_file(current_file)
		
		"/File/Print":
			var text = document_canvas.get_string()
			print(text)


func _on_open_file_dialog_file_selected(path: String):
	current_file = path
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
	open_file(file_path)


func _on_save_file_dialog_file_selected(path: String) -> void:
	save_file(path)

