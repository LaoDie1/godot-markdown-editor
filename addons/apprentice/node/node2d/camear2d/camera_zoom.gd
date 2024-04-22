#============================================================
#	Camera Zoom
#============================================================
# @datetime: 2022-3-16 16:41:15
#============================================================
## 设置相机镜头为地图的大小范围的缩放
class_name CameraZoom
extends BaseCameraByTileMap


enum ScaleType {
	Normal,	## 按照常比例进行缩放
	Min,	## 按照最小的范围进行缩放
	Max,	## 按照最大的范围进行缩放
}

@export var scale_type : ScaleType = ScaleType.Min
@export var min_zoom : Vector2 = Vector2.ZERO
@export var max_zoom : Vector2 = Vector2.INF
# 在缩放后的基础上再次计算缩放
@export var zoom_scale : Vector2 = Vector2(1.0, 1.0)


#============================================================
#   自定义
#============================================================
#(override)
func _update_camera():
	var rect : Rect2 = tilemap.get_used_rect()
	rect.size *= tilemap.cell_quadrant_size
	var camera_scale = (tilemap.get_viewport_rect().size / rect.size) * 2
	camera_scale *= zoom_scale
	match scale_type:
		ScaleType.Normal:
			camera.zoom = camera_scale
		
		ScaleType.Min:
			var z = min(camera_scale.x, camera_scale.y)
			camera.zoom = Vector2(z, z)
		
		ScaleType.Max:
			var z = max(camera_scale.x, camera_scale.y)
			camera.zoom = Vector2(z, z)
	
	# 不能低于最小也不能超出最大
	camera.zoom.x = clamp(camera.zoom.x, min_zoom.x, max_zoom.x)
	camera.zoom.y = clamp(camera.zoom.y, min_zoom.y, max_zoom.y)

