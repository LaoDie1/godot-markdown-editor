#============================================================
#    Control Effect Fade
#============================================================
# - datetime: 2023-03-02 23:17:23
# - version: 4.x
#============================================================
## 淡入淡出
class_name ControlEffect_Fade
extends ControlEffect


@export
var color : Color = Color(1, 1, 1, 0)
@export
var curve : Curve



#(override)
func _get_origin_data(node):
	return node.modulate


#(override)
func _execute_handle(node, state):
	assert(curve != null, "curve 属性不能为空！")
	var from = get_origin_data(node)
	var to = color
	
	FuncUtil.execute_curve_tween(curve, node, "modulate", to, duration, not state, from)
