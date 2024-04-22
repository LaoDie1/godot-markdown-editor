#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:53:36
# - version: 4.3.0.dev5
#============================================================
extends Node


@onready var font : Font = Engine.get_main_loop().current_scene.get_theme_default_font()


var top_font_size : int = 16
var font_size : int = 18
var accent_color : Color = Color(0.7578, 0.5261, 0.2944, 1)
var text_color : Color = Color(0,0,0,0.8)
var line_spacing : float = 2
