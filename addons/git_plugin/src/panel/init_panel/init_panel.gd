#============================================================
#    Init Panel
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 17:00:07
# - version: 4.2.1.stable
#============================================================
@tool
extends Panel


@onready var init_button: Button = %InitButton


#============================================================
#  内置
#============================================================
func _ready() -> void:
	# 移动到最后，显示为最前面
	self.get_parent().move_child.call_deferred(self, self.get_parent().get_child_count()-1)
	self.visible = not DirAccess.dir_exists_absolute("res://.git")
	init_button.visible = not DirAccess.dir_exists_absolute("res://.git")
	init_button.disabled = false
	init_button.pressed.connect(_on_init_button_pressed)



#============================================================
#  连接信号
#============================================================
func _on_init_button_pressed() -> void:
	await GitPlugin_Init.execute("main")
	init_button.disabled = DirAccess.dir_exists_absolute("res://.git")
	self.visible = not DirAccess.dir_exists_absolute("res://.git")
