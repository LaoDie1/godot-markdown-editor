#============================================================
#    Float Text
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-16 22:27:38
# - version: 4.0
#============================================================
## 漂浮文字
class_name FloatText


static func create(
	text: String, 
	position: Vector2, 
	font_size: int, ## 字体大小
	offset: Vector2, ## 偏移向量。移动到 position + offset 的位置
	duration: float, ## 持续时间
	color : Color = Color.WHITE, # 字体颜色
	scale : Vector2 = Vector2(1, 1), # 缩放到的最大值
) -> Label:
	var label = Label.new()
	label.text = text
	label.scale = Vector2(0,0)
	label.add_theme_font_size_override("font_size", font_size)
	label.self_modulate = color
	Engine.get_main_loop().current_scene.add_child(label)
	
	label.top_level = true
	label.global_position = position - label.size / 2
	label.pivot_offset = label.size / 2
	label.create_tween() \
		.tween_property(label, "position", label.position + offset, duration) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
	label.create_tween().tween_property(label, "scale", scale, 0.2) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT) \
		.finished.connect(func():
			if is_instance_valid(label):
				await label.get_tree().create_timer(duration).timeout
				if is_instance_valid(label):
					label.create_tween().tween_property(label, "modulate:a", 0, 0.25).set_ease(Tween.EASE_OUT)
	)
	return label
