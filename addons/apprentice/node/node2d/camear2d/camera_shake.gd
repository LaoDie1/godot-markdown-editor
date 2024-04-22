#============================================================
#	Camera
#============================================================
# 相机抖动
#============================================================
# @datetime: 2022-3-3 20:52:31
#============================================================
class_name CameraShake
extends BaseCameraDecorator


const TRAUMA = 2


@export var noise : Noise
##  抖动幅度
@export_range(0.0, 2.0) var trauma : float = 0.0
##  抖动衰退
@export_range(0.0, 1.0) var decay : float = 0.6
##  时间缩放
@export var time_scale : float = 100.0
@export var max_x : int = 150
@export var max_y : int = 150
@export var max_r : int = 25


var __time = 0.0


#============================================================
#   自定义
#============================================================
func _process(delta):
	__time += delta
	
	var shake = pow(trauma, 2)
	camera.offset.x = noise.get_noise_3d(__time * time_scale, 0, 0) * max_x * shake
	camera.offset.y = noise.get_noise_3d(0, __time * time_scale, 0) * max_y * shake
	camera.rotation_degrees = noise.get_noise_3d(0, 0, __time * time_scale) * max_r * shake
	
	if trauma > 0: 
		trauma = clamp(trauma - (delta * decay), 0, TRAUMA)

