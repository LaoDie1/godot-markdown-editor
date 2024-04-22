#============================================================
#    Log
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 18:13:59
# - version: 4.2.1.stable
#============================================================
@tool
extends VBoxContainer


@onready var log_item_tree: Tree = %LogItemTree
@onready var log_number_option = %LogNumberOption
@onready var commit_id_line_edit = %CommitIDLineEdit
@onready var file_item_tree = %FileItemTree

@onready var log_tree_root : TreeItem = log_item_tree.create_item()
@onready var file_item_root : TreeItem = file_item_tree.create_item()



#============================================================
#  内置
#============================================================
func _ready() -> void:
	visibility_changed.connect(update_log, Object.CONNECT_ONE_SHOT)
	
	log_number_option.clear()
	for item in ["10", "20", "50", "100", "All"]:
		log_number_option.add_item(item)
	
	log_item_tree.set_column_title(0, "Commit ID")
	log_item_tree.set_column_title(1, "Date")
	log_item_tree.set_column_title(2, "Description")
	log_item_tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	log_item_tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	log_item_tree.set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_LEFT)
	
	update_log.call_deferred()



#============================================================
#  自定义
#============================================================
## 更新日志列表
func update_log():
	if not visible or log_item_tree == null:
		return
	
	commit_id_line_edit.text = ""
	log_item_tree.clear()
	file_item_tree.clear()
	
	log_tree_root = log_item_tree.create_item()
	file_item_root = file_item_tree.create_item()
	
	# 显示的日志数量
	var log_number : int = 0
	var item_id = log_number_option.get_selected_id()
	var item_text = log_number_option.get_item_text(item_id)
	if item_text != "All":
		log_number = int(item_text)
	
	# 提交列表
	var result = await GitPlugin_Log.execute(log_number)
	var idx = 0
	for data in result:
		var tree_item = log_item_tree.create_item(log_tree_root)
		tree_item.set_text(0, data["id"].substr(0, 11))
		tree_item.set_text(1, data["date"])
		tree_item.set_text(2, data["desc"])
		tree_item.set_metadata(0, data)
		
		idx += 1



#============================================================
#  连接信号
#============================================================
func _on_log_number_option_item_selected(index):
	update_log.call_deferred()


func _on_log_item_tree_item_selected():
	commit_id_line_edit.text = ""
	file_item_tree.clear()
	file_item_root = file_item_tree.create_item()
	
	var item = log_item_tree.get_selected()
	if item:
		var data = item.get_metadata(0)
		var commit_id = str(data["id"])
		commit_id_line_edit.text = commit_id
		
		var files = await GitPlugin_Show.files(commit_id)
		for file:String in files:
			var file_item : TreeItem = file_item_tree.create_item(file_item_root)
			file_item.set_text(0, file)
			file_item.set_icon(0, GitPlugin_Icons.get_icon(file) )
			file_item.set_metadata(0, file)
			
			if file.get_file() != "":
				file_item.add_button(0, GitPlugin_Icons.get_icon_by_name("ActionCopy"))


func _on_copy_button_pressed():
	var commit_id : String = commit_id_line_edit.text
	DisplayServer.clipboard_set(commit_id.strip_edges())
	print_debug("已复制：", commit_id)


func _on_file_item_tree_button_clicked(item: TreeItem, column, id, mouse_button_index):
	if id == 0:
		var file_path = item.get_metadata(0)
		DisplayServer.clipboard_set(file_path)
		print_debug("已复制：", file_path)

