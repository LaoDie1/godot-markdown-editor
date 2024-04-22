#============================================================
#    Angle Ratio Cache
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-13 12:36:52
# - version: 4.0
#============================================================
## 角度比值缓存
##
##求得这个角度在 -360 到 360 之间的百分比的值
class_name AngleRatioCache


const MAX_ANGLE : int = 360


var _angle_to_ratio : Array = []


func _init():
	const KEY = "AngleRatioCache_angle_to_ratio"
	if Engine.has_meta(KEY):
		_angle_to_ratio = Engine.get_meta(KEY)
	
	else:
		var value = PI / 30
		_angle_to_ratio.resize(MAX_ANGLE)
		for i in MAX_ANGLE:
			_angle_to_ratio[i] = sin(deg_to_rad(i))
		# 数据缓存到 Engine 对象的元数据中
		Engine.set_meta(KEY, _angle_to_ratio)


## 获取这个角度在 360 度内的比 [-1, 1)
func get_value(angle: float) -> float:
	return _angle_to_ratio[int(angle) % MAX_ANGLE]
