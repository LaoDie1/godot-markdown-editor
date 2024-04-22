#============================================================
#    Float
#============================================================
# - datetime: 2023-02-28 00:34:48
# - version: 4.x
#============================================================
## 漂浮效果
class_name ControlEffect_Float
extends ControlEffect

@export
var noise : Noise
# 振动幅度
@export
var amplitude : float = 5.0
# 振动速度
@export
var speed : float = 100.0


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
	_executing = true
	var t = DataUtil.get_ref_data(100.0)
	var delta = get_physics_process_delta_time()
	var origin = get_origin_data(node)
	
	var interval = 0.5
	var count = duration / interval
	var callable = func():
		t.value += interval * speed
		var offset = Vector2(
			noise.get_noise_1d(t.value),
			noise.get_noise_2d(t.value, t.value),
		) * amplitude 
		
		create_tween().tween_property(node, "position", origin + offset, interval)
	
	callable.call()
	
	FuncUtil.execute_intermittent(interval, count, callable
	).set_finish_callback(func():
		node.position = get_origin_data(node)
		_executing = false
	)
	


