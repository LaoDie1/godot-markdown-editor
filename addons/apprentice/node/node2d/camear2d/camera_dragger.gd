#============================================================
#    Camera Dragger
#============================================================
# - author: zhangxuetu
# - datetime: 2023-07-04 23:55:04
# - version: 4.0
#============================================================
## 相机拖拽器
class_name CameraDragger
extends BaseCameraDecorator


@export var speed : float = 1
@export var current_zoom_scale : float = 1:
	set(v):
		current_zoom_scale = v
		if not is_inside_tree():
			await ready
		var zoom = pow(2, current_zoom_scale)
		camera.zoom = Vector2(zoom, zoom)

var dragging : bool = false
var last_mouse_pos : Vector2
var last_camera_pos : Vector2


func _ready():
	await get_tree().process_frame
	self.current_zoom_scale = current_zoom_scale


func _unhandled_input(event):
	if InputUtil.is_click_left(event, true):
		dragging = true
		last_mouse_pos = get_local_mouse_position()
		last_camera_pos = camera.global_position
	elif InputUtil.is_motion(event, MOUSE_BUTTON_MASK_LEFT):
		camera.global_position = last_camera_pos + (last_mouse_pos - get_local_mouse_position()) #* speed
	elif InputUtil.is_click_left(event, false):
		dragging = false
	
	var down_or_up = InputUtil.get_mouse_wheel(event)
	if down_or_up != 0:
		current_zoom_scale -= 0.5 * down_or_up
		

