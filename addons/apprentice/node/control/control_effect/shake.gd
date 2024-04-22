#============================================================
#    Float Effect
#============================================================
# - datetime: 2023-02-27 23:26:07
# - version: 4.x
#============================================================
## 设置目标进行抖动
class_name ControlEffect_Shake
extends ControlEffect


@export
var noise : Noise
# 振动幅度
@export
var amplitude : float = 5.0
# 振动速度
@export
var speed : float = 200.0
@export
var mark_pos : bool = true


var _executing = false


#(override)
func _get_origin_data(node):
	return node.position

#(override)
func _can_execute(ready_state) -> bool:
	return not _executing

#(override)
func _execute_before():
	update_node_origin()

#(override)
func _execute_handle(node, state):
	assert(noise != null, "noise 属性不能为空！")
	_executing = true
	
	if mark_pos:
		_add_origin_data(node)
	
	var t = DataUtil.get_ref_data(0.0)
	var delta = get_physics_process_delta_time()
	var origin = get_origin_data(node)
	FuncUtil.execute_fragment_process(duration, func():
		t.value += delta * speed
		var offset = Vector2(
			noise.get_noise_1d(t.value),
			noise.get_noise_2d(t.value, t.value),
		) * amplitude 
		node.position = origin + offset
	).set_finish_callback(func():
		node.position = get_origin_data(node)
		_executing = false
	)

