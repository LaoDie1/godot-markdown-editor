#============================================================
#    Effect Util
#============================================================
# - datetime: 2022-12-27 20:59:12
#============================================================
## 执行一些效果
class_name EffectUtil


##  振动
##[br]
##[br][code]node[/code]  振动的节点
##[br][code]duration[/code]  振动持续时间
##[br][code]amplitude[/code]  振动幅度
##[br][code]origin_pos[/code]  这个节点的原始所在位置
static func shock(
	node: CanvasItem, 
	duration: float, 
	amplitude: int = 100, 
	origin_pos:= Vector2(INF, INF),
	lock_x: bool = false,
	lock_y: bool = false,
	property: String = "position"
):
	if not is_instance_valid(node):
		return
	
	# 执行前的位置
	if origin_pos == Vector2(INF, INF):
		origin_pos = node[property]
	# 根据噪点获取随机值
	var noise : Noise = FastNoiseLite.new()
	
	var x : float
	var y : float
	FuncUtil.execute_fragment_process(duration, func():
		if is_instance_valid(node):
			x = origin_pos.x if lock_x else noise.get_noise_2d(randf_range(-1, 1), 0)
			y = origin_pos.y if lock_y else noise.get_noise_2d(0, randf_range(-1, 1))
			node[property] = origin_pos + Vector2(x, y) * amplitude * 10
		
	, Timer.TIMER_PROCESS_IDLE, node).set_finish_callback(func():
		if is_instance_valid(node):
			node[property] = origin_pos
	)


##  击中效果，闪烁颜色。如果有 shader 可能没有效果
##[br]
##[br][code]node[/code]  设置显示效果的画布节点
##[br][code]show_color[/code]  显示的颜色
##[br][code]duration[/code]  持续效果时间，时间不宜过小，否则效果可能显示不出来，不要超过
##interval 参数时间
##[br][code]interval[/code]  间隔显示时间（要比 duration 时间长，否则会一直是的 show_color 的颜色）
##[br][code]total[/code]  效果总次数。
##[br][code]origin_color[/code]  原来的颜色
static func color_change(
	node: CanvasItem, 
	show_color: Color, 
	duration: float, 
	interval: float, 
	total: int, 
	origin_color := Color(INF, INF, INF, INF)
):
	if origin_color == Color(INF, INF, INF, INF):
		origin_color = node.modulate
	
	var tree := Engine.get_main_loop().current_scene.get_tree() as SceneTree
	
	FuncUtil.execute_intermittent(interval, total, func():
		node.modulate = show_color
		await tree.create_timer(duration).timeout
		if is_instance_valid(node):
			node.modulate = origin_color
	
	, false, Timer.TIMER_PROCESS_PHYSICS, node).set_finish_callback(func():
		node.modulate = origin_color
	)


##  果冻效果
##[br]
##[br][code]target[/code]  施加效果的目标
##[br][code]duration[/code]  持续时间
##[br][code]from[/code]  从这个值开始缩放
##[br][code]to[/code]  最终缩放到这个大小，如果不传入这个参数，默认为当时的大小
static func jelly(
	target: CanvasItem, 
	duration: float, 
	from : Vector2 = Vector2(0,0), 
	to : Vector2 = Vector2(INF,INF)
):
	if to == Vector2(INF, INF):
		to = target.get_global_transform_with_canvas().get_scale()
	if is_instance_valid(target):
		var tween = Engine.get_main_loop().create_tween()
		tween \
			.tween_property(target, "scale", to, duration) \
			.from(from) \
			.set_trans( Tween.TRANS_ELASTIC ) \
			.set_ease( Tween.EASE_OUT )
		return tween
	return null


##  淡出/淡入
##[br]
##[br][code]target[/code]  影响的目标
##[br][code]duration[/code]  持续时间
##[br][code]to[/code]  结束时的透明度
##[br][code]from[/code]  开始的透明度
##[br][code]trans[/code]  过渡速度类型
##[br][code]ease_[/code]  插值类型
static func fade_in_out(
	target:CanvasItem, 
	duration: float, 
	to : float, 
	from = null,
	trans:= Tween.TRANS_LINEAR, 
	ease_: int = -1,
) -> Tween:
	assert(from == null or from is float, "form 参数类型错误")
	
	if from != null:
		target.modulate.a = from
	var tween = Engine.get_main_loop().create_tween()
	FuncUtil.on_enter_tree( func():
		tween \
			.tween_property(target, "modulate:a", to, duration) \
			.set_trans(trans)
		if ease_ > -1:
			tween.set_ease(ease_)
	, target)
	return tween


## 节点移动
static func move(
	target: CanvasItem, 
	duration: float,
	to: Vector2,
	from = null,
	trans:= Tween.TRANS_LINEAR, 
	ease_: int = -1,
) -> Tween:
	assert(from == null or from is Vector2 or from is Vector2i, "form 参数类型错误")
	
	if from != null:
		target.position = Vector2(from)
	
	var tween = Engine.get_main_loop().create_tween()
	FuncUtil.on_enter_tree(func():
		tween \
			.tween_property(target, "position", to, duration) \
			.set_trans(trans)
		if ease_ > -1:
			tween.set_ease(ease_)
	, target)
	return tween

