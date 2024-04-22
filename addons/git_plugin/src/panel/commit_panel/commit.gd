#============================================================
#    Commit
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 17:42:32
# - version: 4.2.1.stable
#============================================================
@tool
extends VBoxContainer


signal pushed


@onready var branch_name_option = %BranchNameOption
@onready var remote_name_option = %RemoteNameOption
@onready var unstaged_changes_file_tree: GitPlugin_FileTree = %UnstagedChangesFileTree
@onready var staged_changes_file_tree: GitPlugin_FileTree = %StagedChangesFileTree
@onready var committed_file_tree: GitPlugin_FileTree = %CommittedFileTree
@onready var commit_message_text_edit: TextEdit = %CommitMessageTextEdit
@onready var commit_changes: Button = %CommitChanges
@onready var commit_message_prompt_animation_player = %CommitMessagePromptAnimationPlayer
@onready var committed_file_tree_animation_player = %CommittedFileTreeAnimationPlayer
@onready var push_button = %PushButton
@onready var pull_button = %PullButton
@onready var unstaged_changes_file_count_label = %UnstagedChangesFileCountLabel
@onready var staged_files_count_label = %StagedFilesCountLabel
@onready var committed_file_count_label = %CommittedFileCountLabel


#============================================================
#  内置
#============================================================
func _ready() -> void:
	# TODO 对两个 OptionButton 添加切换远程名称和分支的功能
	
	if not DirAccess.dir_exists_absolute(".git"):
		return
	
	# 远程仓库名
	var remote_name_list = await GitPlugin_Remote.list()
	if not remote_name_list.is_empty():
		remote_name_option.clear()
		for item in remote_name_list:
			remote_name_option.add_item(item)
	
	# 分支信息
	var current_branch = await GitPlugin_Branch.show_current()
	var branch_list = await GitPlugin_Branch.list()
	if not branch_list.is_empty():
		branch_name_option.clear()
	var idx = -1
	for item:String in branch_list:
		item = item.trim_prefix("*").strip_edges()
		idx += 1
		branch_name_option.add_item(item)
		branch_name_option.set_item_metadata(idx, item)
		branch_name_option.set_item_icon(idx, GitPlugin_Icons.get_icon_by_name("VcsBranches"))
		if item == current_branch:
			branch_name_option.selected = idx
	
	# call_deferred 用于等待节点显示出来
	update.call_deferred()


#============================================================
#  自定义
#============================================================
## 更新文件列表
func update():
	if not visible:
		return
	
	var data = await GitPlugin_Status.execute()
	
	# 未跟踪
	var untracked_files = data["untracked"]
	unstaged_changes_file_tree.init_items(untracked_files)
	unstaged_changes_file_count_label.text = "(%d)" % untracked_files.size()
	
	# 已修改
	var changes_not_staged_for_commit : Array = data["changed"]
	staged_changes_file_tree.init_items(changes_not_staged_for_commit)
	staged_files_count_label.text = "(%d)" % changes_not_staged_for_commit.size()
	
	# 已提交
	var committed_files : Array = data.get("committed", [])
	committed_file_tree.init_items(committed_files)
	committed_file_count_label.text = "(%d)" % committed_files.size()


## 点击文件
func edit_file(item_file: String, file: String):
	if Engine.is_editor_hint() and ResourceLoader.exists(file):
		if not file.begins_with("res://"):
			file = "res://" + file
		
		match file.get_extension():
			"tres", "res", "gd":
				var res = load(file)
				EditorInterface.edit_resource(res)
			"tscn", "scn":
				EditorInterface.open_scene_from_path(file)
		
		if ResourceLoader.exists(file):
			print_debug("编辑文件：", file)
			EditorInterface.get_file_system_dock().navigate_to_path(file)
			EditorInterface.select_file(file)


#============================================================
#  连接信号
#============================================================
func _on_add_all_unstaged_file_pressed() -> void:
	var files = unstaged_changes_file_tree.get_selected_files()
	if not files.is_empty():
		var result = await GitPlugin_Add.execute(files)
		update()


func _on_remove_all_pressed() -> void:
	var files = committed_file_tree.get_selected_files()
	if not files.is_empty():
		var result = await GitPlugin_Restore.execute(files)
		update()


func _on_add_all_staged_files_pressed() -> void:
	var files = staged_changes_file_tree.get_selected_files()
	if not files.is_empty():
		var result = await GitPlugin_Add.execute(files)
		update()


func _on_commit_changes_pressed() -> void:
	var enabled : bool = true
	if committed_file_tree.get_selected_item_file().is_empty():
		committed_file_tree_animation_player.play("flicker")
		enabled = false
	if commit_message_text_edit.text.strip_edges() == "":
		commit_message_prompt_animation_player.play("flicker")
		enabled = false
	if not enabled:
		return
	
	# 提交
	var result = await GitPlugin_Commit.execute(
		commit_message_text_edit.text.strip_edges()
	)
	commit_message_text_edit.text = ""
	
	update()
	
	pushed.emit()


func _on_push_pressed() -> void:
	push_button.disabled = true
	var remote_name = remote_name_option.get_item_text(remote_name_option.get_selected_id())
	var branch_name = branch_name_option.get_item_text(branch_name_option.get_selected_id())
	await GitPlugin_Push.execute(remote_name, branch_name)
	push_button.disabled = false


func _on_pull_button_pressed():
	pull_button.disabled = true
	var remote_name = remote_name_option.get_item_text(remote_name_option.get_selected_id())
	var branch_name = branch_name_option.get_item_text(branch_name_option.get_selected_id())
	await GitPlugin_Pull.execute(remote_name, branch_name)
	pull_button.disabled = false


func _on_staged_changes_file_tree_actived_file(item_file: String, file: String) -> void:
	var results = await GitPlugin_Add.execute([ file ])
	if results[0]["error"] == OK:
		staged_changes_file_tree.remove_item(item_file)
		committed_file_tree.add_item(item_file)


func _on_unstaged_changes_file_tree_actived_file(item_file: String, file: String) -> void:
	var results = await GitPlugin_Add.execute([ file ])
	if results[0]["error"] == OK:
		unstaged_changes_file_tree.remove_item(item_file)
		committed_file_tree.add_item(item_file)


func _on_committed_file_tree_actived_file(item_file, file):
	var results = await GitPlugin_Add.execute([ file ])
	if results[0]["error"] == OK:
		staged_changes_file_tree.add_item(item_file)
		committed_file_tree.remove_item(item_file)

