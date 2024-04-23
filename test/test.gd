#============================================================
#    Test
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 18:14:39
# - version: 4.3.0.dev5
#============================================================
extends Node2D


@onready var texture_rect: TextureRect = $TextureRect

@onready var path = r"C:\Users\z\AppData\Local\godot_markdown_editor\0cd5a08f44fa54683a6647b238e82917.webp"
@onready var image = FileUtil.load_image(path)
@onready var texture = ImageTexture.create_from_image(image)

func _ready() -> void:
	pass
	#var path = r"C:\Users\z\AppData\Local\godot_markdown_editor\0cd5a08f44fa54683a6647b238e82917.webp"
	#var image = FileUtil.load_image(path)
	#var texture = ImageTexture.create_from_image(image)
	#texture_rect.texture = texture
	
	#var url = "https://pica.zhimg.com/80/v2-93b13d8959eceb3898a5d4c908f0f46c_720w.webp?source=1def8aca"
	#ImageRequest.queue_request(url, func(data):
		#texture_rect.texture = ImageTexture.create_from_image(data.image)
	#)

func _process(delta: float) -> void:
	if Engine.get_process_frames() % 20 == 0:
		queue_redraw()

func _draw() -> void:
	draw_texture(texture, Vector2(100, 100), Color(1,1,1,0.5))


