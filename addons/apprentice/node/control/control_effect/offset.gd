#============================================================
#    Offset
#============================================================
# - datetime: 2023-02-22 22:50:36
#============================================================
# 节点偏移
class_name ControlEffect_Offset
extends ControlEffect


## 偏移的节点的距离
@export var offset : Vector2 = Vector2(0, 0)
## 初始值。如果为 [constant Vector2.INF]，则按照节点的初始值进行设置
@export var from : Vector2 = Vector2.INF
## 值曲线
@export var curve : Curve
## 值逐级递增值的大小
@export var increase_offset : Vector2 = Vector2(0, 0)


var _idx = 0


#(override)
func _get_origin_data(node) -> Vector2:
	return node.position

#(override)
func _execute_before():
	_idx = 0

#(override)
func _execute_handle(node, state):
	assert(curve != null, "curve 属性不能为空！")
	var tmp = from
	if tmp == Vector2.INF:
		tmp = get_origin_data(node)
	_idx += 1
	var to = get_origin_data(node) + offset + increase_offset * _idx
	FuncUtil.execute_curve_tween(curve, node, "position", to, duration, not state, tmp)

