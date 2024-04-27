#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 17:19:07
# - version: 4.3.0.dev5
#============================================================
extends Control


@onready var menu : SimpleMenu = %Menu
@onready var markdown_edit: MarkdownEdit = %MarkdownEdit
@onready var document_text_edit: TextEdit = %DocumentTextEdit

@onready var debug_editor = %DebugEditor
@onready var file_item_list : ItemList = %FileItemList
@onready var open_file_dialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var scan_files_dialog: FileDialog = %ScanFilesDialog

var current_file : String:
	set(v):
		if current_file != v:
			current_file = v
			if current_file != "":
				markdown_edit.file_path = current_file
				document_text_edit.text = markdown_edit.get_text()
			else:
				markdown_edit.file_path = ""
				document_text_edit.text = ""


#============================================================
#  内置
#============================================================
func _ready():
	menu.init_menu({
		"File": ["New", "Open", "Scan Files", "Save", "-", "Print"]
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
		"/File/Scan Files": Icons.get_icon("FolderBrowse"),
	})
	
	var current_dir = Config.get_value(ConfigKey.Path.current_dir, "")
	open_file_dialog.current_dir = current_dir
	add_files(Config.get_opened_files())
	Engine.get_main_loop().root.files_dropped.connect(
		func(files):
			for file in files:
				add_file_item(file)
	)



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

func add_files(files: Array):
	for file in files:
		add_file_item(file)

func open_file(path: String):
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

func save_file(file_path: String):
	var text : String = markdown_edit.get_text()
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
func _on_menu_menu_pressed(idx, menu_path):
	match menu_path:
		"/File/New":
			current_file = ""
			file_item_list.deselect_all()
		
		"/File/Open":
			open_file_dialog.popup_centered_ratio(0.5)
			
		"/File/Scan Files":
			scan_files_dialog.popup_centered()
		
		"/File/Save":
			if current_file == "" or not FileAccess.file_exists(current_file):
				save_file_dialog.popup_centered_ratio()
			else:
				save_file(current_file)
		
		"/File/Print":
			var text = markdown_edit.get_text()
			print(text)


func _on_file_item_list_item_selected(index: int):
	var file_path = file_item_list.get_item_metadata(index)
	open_file(file_path)


func _on_scan_files_dialog_dir_selected(dir: String) -> void:
	var files = FileUtil.scan_file(dir, true).filter(
		func(file: String): return file.get_extension().to_lower() in [
			"", "txt", "md"
		]
	)
	add_files(files)
