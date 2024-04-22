#============================================================
#    Camera Util
#============================================================
# - datetime: 2022-09-04 10:30:56
#============================================================

##  摄像机工具类
class_name CameraUtil


##  获取当前镜头
static func get_current_camera2d() -> Camera2D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene and tree.current_scene.get_viewport() and tree.current_scene.get_viewport().get_camera_2d():
		return tree.current_scene.get_viewport().get_camera_2d()
	return null


##  缩放镜头
static func zoom(camera: Camera2D, value: Vector2, duration: float):
	if is_instance_valid(camera):
		# 镜头缩放
		var tree := Engine.get_main_loop() as SceneTree
		tree.create_tween().tween_property(camera, "zoom", value, duration)


##  缩放当前镜头
static func zoom_current(value: Vector2, duration: float):
	var camera := get_current_camera2d()
	if camera:
		zoom(camera, value, duration)

## 获取相机的范围
static func get_limit(camera: Camera2D) -> Rect2:
	return Rect2( Vector2(camera.limit_left, camera.limit_top), Vector2(camera.limit_right, camera.limit_bottom) )

## 设置相机的可见范围
static func set_limit(camera: Camera2D, rect: Rect2, scale: float = 1.0):
	camera.limit_left = rect.position.x * scale
	camera.limit_right = rect.end.x * scale
	camera.limit_top = rect.position.y * scale
	camera.limit_bottom = rect.end.y * scale

