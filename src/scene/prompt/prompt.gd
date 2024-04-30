#============================================================
#    Prompt
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-29 12:37:35
# - version: 4.3.0.dev5
#============================================================
## 提示信息
class_name Prompt
extends MarginContainer


@onready var prompt_label: Label = %PromptLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var color_rect: ColorRect = %ColorRect


static var instance: Prompt


func _init() -> void:
	instance = self


func _ready() -> void:
	animation_player.play("RESET")
	color_rect.color.a = 0


## 显示消息
static func show_message(
	message: String, 
	params: Array = [], 
	join_string: String = "", 
	color: Color = Color.BLACK
):
	instance.prompt_label.text = message + join_string.join(params)
	instance.animation_player.stop()
	instance.animation_player.play("run")
	instance.color_rect.color = color


static func show_error(message: String, 
	params: Array = [], 
	join_string: String = ""
):
	show_message(message, params, join_string, Color.FIREBRICK)


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	color_rect.color.a = 1


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	color_rect.color.a = 0

