#============================================================
#    Test
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 18:14:39
# - version: 4.3.0.dev5
#============================================================
extends Node2D


@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	pass
	
	var url = "https://pica.zhimg.com/80/v2-93b13d8959eceb3898a5d4c908f0f46c_720w.webp?source=1def8aca"
	ImageRequest.queue_request(url, func(data):
		texture_rect.texture = ImageTexture.create_from_image(data.image)
	)

