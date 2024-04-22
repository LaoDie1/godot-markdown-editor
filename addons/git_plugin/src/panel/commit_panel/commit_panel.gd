#============================================================
#    Commit Panel
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 17:53:38
# - version: 4.2.1.stable
#============================================================
@tool
extends Panel


@onready var tab_container = %TabContainer
@onready var commit = %Commit
@onready var log = %Log
@onready var remotes = %Remotes


func _ready():
	var remote_list = await GitPlugin_Remote.list()
	if remote_list.is_empty():
		tab_container.current_tab = remotes.get_index()

