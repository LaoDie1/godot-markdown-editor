#============================================================
#    Scale
#============================================================
# - datetime: 2023-02-22 23:31:09
#============================================================
# 缩放
class_name ControlEffect_Scale
extends ControlEffect


## 缩放大小
@export var zoom : Vector2 = Vector2(2, 2)
## 初始值。如果为 [constant Vector2.INF]，则按照节点的初始值进行设置
@export var from : Vector2 = Vector2.INF
## 值曲线
@export var curve : Curve


#(override)
func _get_origin_data(node) -> Vector2:
	return node.scale


#(override)
func _execute_handle(node, state):
	assert(curve != null, "curve 属性不能为空！")
	var tmp : Vector2
	if from == Vector2.INF:
		tmp = get_origin_data(node)
	else:
		tmp = from
	
	var to = zoom
	FuncUtil.execute_curve_tween(curve, node, "scale", to, duration, not state, tmp)

