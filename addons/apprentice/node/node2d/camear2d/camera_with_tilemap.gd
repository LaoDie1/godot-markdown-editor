#============================================================
#    Camera 2d Base
#============================================================
# - datetime: 2022-08-23 23:23:44
#============================================================
class_name BaseCameraByTileMap
extends BaseCameraDecorator


@export var enabled : bool = true
@export var tilemap : TileMap : 
	set(value):
		tilemap = value
		if not is_inside_tree(): 
			await ready
		update_configuration_warnings()
		update_camera()

var __readied = FuncUtil.execute_deferred(func():
	await Engine.get_main_loop().process_frame
	Engine.get_main_loop() \
		.root.size_changed \
		.connect(update_camera)
	update_camera()
)


#============================================================
#  自定义
#============================================================
## 更新摄像机
func update_camera() -> void:
	if not is_inside_tree():
		await ready
	if enabled:
		if camera != null and tilemap != null:
			_update_camera.call_deferred()
		else:
			printerr("[ BaseCameraByTileMap ] 没有设置 Camera 或 TileMap 属性")
	else:
		printerr("[ BaseCameraByTileMap ] 未启用")


# 更新摄像机
func _update_camera():
	pass


