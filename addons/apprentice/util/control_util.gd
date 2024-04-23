#============================================================
#    Control Util
#============================================================
# - datetime: 2023-02-12 13:31:18
#============================================================
## 操作 Control 的节点
class_name ControlUtil


##  点击 Control 节点
##[br]
##[br][code]control[/code]  
##[br][code]button_index[/code]  
##[br][code]pressed[/code]  
static func click(
	control : Control, 
	button_index: int = MOUSE_BUTTON_LEFT, 
	pressed : bool = true
) -> void:
	var event = InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = pressed
	if control.has_method("_gui_input"):
		control._gui_input(event)
	else:
		control.gui_input.emit(event)
	
	if control is BaseButton:
		control.pressed.emit()
	


##  点击 Control 节点时执行方法
##[br]
##[br][code]node[/code]  点击的节点
##[br][code]callable[/code]  回调方法
##[br][code]execute_once[/code]  连接一次
static func connect_click_event(node: Control, callable: Callable, execute_once: bool = false):
	node.gui_input.connect(func(event):
		if InputUtil.is_click_left(event):
			callable.call()
	, Object.CONNECT_ONE_SHOT 
		if execute_once 
		else Object.CONNECT_ONE_SHOT
	)


##  创建一个 [TextureRect] 节点
static func create_texture_rect(texture: Texture, custom_minimum_size: Vector2 = Vector2(0,0)) -> TextureRect:
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture = texture
	texture_rect.custom_minimum_size =custom_minimum_size
	return texture_rect


##  设置节点的style值的属性
##[br]
##[br][code]control[/code]  [Control]类节点
##[br][code]property[/code]  style属性名
##[br][code]value[/code]  属性值
static func set_panel_style(control: Control, property: String, value) -> void:
	control.set_indexed("theme_override_styles/panel:" + property, value)


## 获取中心位置
static func get_center(control: Control) -> Vector2:
	return control.global_position + control.size / 2

