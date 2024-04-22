#============================================================
#	Camera Limit By Map
#============================================================
# @datetime: 2022-3-15 00:34:43
#============================================================
## 设置镜头的有限的范围
class_name CameraLimit
extends BaseCameraByTileMap


## 额外设置的范围
@export var margin : Rect2 = Rect2(0,0,0,0):
	set(v):
		margin = v
		update_camera()

var __init_update_zoom_timer = (func():
	var f = func():
		var timer := Timer.new()
		timer.wait_time = 0.5
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(func():
			if camera and camera.zoom != _last_zoom:
				_last_zoom = camera.zoom
				_update_camera()
		)
		add_child(timer)
		_update_camera()
	if not is_inside_tree():
		self.ready.connect(f, Object.CONNECT_ONE_SHOT)
	else:
		f.call()
).call()

var _last_zoom : Vector2


#============================================================
#  SetGet
#============================================================
func get_limit() -> Rect2:
	return CameraUtil.get_limit(camera)


#============================================================
#   自定义
#============================================================
#(override)
func _update_camera():
	var rect = Rect2(tilemap.get_used_rect())
	if tilemap.tile_set == null:
		printerr("[ CameraLimit ] 这个 TileMap 没有设置 tile_set 属性")
		return
	
	if not tilemap.is_inside_tree(): await tilemap.ready
	
	var tile_size = Vector2(tilemap.tile_set.tile_size)
	rect.position *= tile_size
	rect.size *= tile_size
	rect.position += tilemap.global_position
	
#	rect.size *= camera.zoom
	
	camera.limit_left = rect.position.x + margin.position.x
	camera.limit_right = rect.end.x + margin.size.x
	camera.limit_top = rect.position.y + margin.position.y
	camera.limit_bottom = rect.end.y + margin.size.y
	
	
	print_debug(rect)
	

