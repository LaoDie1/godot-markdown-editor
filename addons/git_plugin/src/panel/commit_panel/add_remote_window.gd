#============================================================
#    Add Remote Window
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 17:20:08
# - version: 4.2.1.stable
#============================================================
@tool
extends ConfirmationDialog


signal added


@onready var remote_name_line_edit: LineEdit = %RemoteNameLineEdit
@onready var remote_url_line_edit: LineEdit = %RemoteUrlLineEdit


func _on_confirmed() -> void:
	var remote_name = remote_name_line_edit.text.strip_edges()
	var remote_url =  remote_url_line_edit.text.strip_edges()
	if remote_name == "" or remote_url == "":
		visible = true
		return
	
	var result = await GitPlugin_Remote.add(remote_name, remote_url)
	print_debug(result)
	added.emit()

