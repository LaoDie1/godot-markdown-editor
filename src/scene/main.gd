#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 17:19:07
# - version: 4.3.0.dev5
#============================================================
## 整体软件界面
extends Control


@onready var menu : SimpleMenu = %Menu
@onready var markdown_edit: MarkdownEdit = %MarkdownEdit
@onready var document_text_edit: TextEdit = %DocumentTextEdit

@onready var open_file_dialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var scan_files_dialog: FileDialog = %ScanFilesDialog
@onready var file_tree : SimpleFileTree = %FileTree


## 当前打开的文件（设置属性，会自动打开文件）
var current_file : String:
	set(v):
		if current_file != v or v == "":
			current_file = v
			if current_file != "":
				markdown_edit.file_path = current_file # 自动打开文件
				document_text_edit.text = markdown_edit.get_text()
			else:
				markdown_edit.file_path = ""
				document_text_edit.text = ""


#============================================================
#  内置
#============================================================
func _ready():
	menu.init_menu({
		"File": ["New", "Open", "Scan Files", "Save",],
		"Operate": ["Show Debug", "Print", ],
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
	menu.set_menu_as_checkable("/Operate/Show Debug", true)
	
	open_file_dialog.current_dir = ConfigKey.Dialog.open_dir.value("")
	save_file_dialog.current_dir = ConfigKey.Dialog.save_dir.value("")
	scan_files_dialog.current_dir = ConfigKey.Dialog.scan_dir.value("")
	
	add_file_items( ConfigKey.Path.opened_files.value().keys(), true )
	Engine.get_main_loop().root.files_dropped.connect(
		func(files):
			for file in files:
				add_file_item(file)
	)


func _exit_tree():
	ConfigKey.Path.opened_files.update(
		DataUtil.array_to_dictionary(file_tree.get_files())
	)


#============================================================
#  自定义
#============================================================
func add_file_item(file_path: String, force: bool = false):
	if FileAccess.file_exists(file_path) and (Config.add_open_file(file_path) or force):
		file_tree.add_file(file_path)
		return true
	return false


func add_file_items(files: Array, force: bool = false):
	for file in files:
		add_file_item(file, force)


func open_file(path: String):
	current_file = path
	ConfigKey.Path.current_dir.update(path.get_base_dir())
	if add_file_item(path):
		file_tree.select_file(path)


func save_file(file_path: String):
	var text : String = markdown_edit.get_text()
	if FileUtil.write_as_string(file_path, text):
		print("已保存文件：", file_path)
		current_file = file_path
		add_file_item(file_path)
	else:
		printerr("保存失败：", FileAccess.get_open_error())



#============================================================
#  连接信号
#============================================================
func _on_menu_menu_pressed(idx, menu_path):
	match menu_path:
		"/File/New":
			current_file = ""
			file_tree.deselect_all()
		
		"/File/Open":
			open_file_dialog.popup_centered_ratio(0.5)
			
		"/File/Scan Files":
			scan_files_dialog.popup_centered()
		
		"/File/Save":
			if current_file == "" or not FileAccess.file_exists(current_file):
				save_file_dialog.popup_centered_ratio()
			else:
				save_file(current_file)
		
		"/Operate/Print":
			var text = markdown_edit.get_text()
			print(text)


func _on_menu_menu_check_toggled(idx, menu_path, status):
	match menu_path:
		"/Operate/Show Debug":
			markdown_edit.show_debug = status


func _on_scan_files_dialog_dir_selected(dir: String) -> void:
	var files = FileUtil.scan_file(dir, true).filter(
		func(file: String): return file.get_extension().to_lower() in [
			"", "txt", "md"
		]
	)
	add_file_items(files)
	ConfigKey.Dialog.scan_dir.update(dir)


func _on_open_file_dialog_file_selected(path: String):
	open_file(path)
	ConfigKey.Dialog.open_dir.update(path.get_base_dir())


func _on_save_file_dialog_file_selected(path: String):
	save_file(path)
	ConfigKey.Dialog.save_dir.update(path.get_base_dir())

func _on_file_item_tree_item_selected():
	var item : TreeItem = file_tree.get_selected()
	var file_path = item.get_metadata(0)
	open_file(file_path)
	
	
