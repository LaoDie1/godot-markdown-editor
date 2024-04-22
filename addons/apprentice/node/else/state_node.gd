#============================================================
#    State Node
#============================================================
# - author: zhangxuetu
# - datetime: 2022-12-01 12:48:31
# - version: 4.0
#============================================================
## 状态节点
##
##通过 [method add_state] 进行添加子状态，返回添加的状态节点可以继续进行添加下一层级的状态
##[br]通过 [method listen_enter] 等开头为 [code]listen[/code] 的方法进行监听状态的改变。然后通过
##[method trans_to_child] 方法进行切换状态
##[br]
##[br]示例。场景有个 state_root 名称的 [StateNode] 根节点，并向其添加如下几个状态：
##[codeblock]
##enum States {
##    IDLE,
##    MOVE,
##    JUMP,
##}
##[/codeblock]
##
##[br]添加状态
##[codeblock]
##var idle_state = state_root.add_state(States.IDLE)
##var move_state = state_root.add_state(States.MOVE)
##var jump_state = state_root.add_state(States.JUMP)
### 或者
##var state_list = state_root.add_multi_states(States.values())
##[/codeblock]
##
##[br]监听状态
##[codeblock]
##idle_state.listen_enter(func():
##    var data: Dictionary = idle_state.get_last_data()
##    print("已进入 idle 状态：", data)
##)
##idle_state.listen_exit(func():
##    print("已退出 idle 状态：")
##)
##idle_state.listen_process(func():
##    print("正在执行 idle 过程")
## 
##)
##[/codeblock]
##
##[br]启动或切换状态
##[codeblock]
### idle 状态切换到 move 状态
##idle_state.trans_to(States.MOVE)
### 或者 state_root 对子节点进行切换，切换到 move 状态
##state_root.trans_to_child(State.Move)
##
### 默认启动 idle 状态
##idle_state.auto_start = true
##state_root.enter_state({})
### 或者直接启动和上面的是相同的
##state_root.enter_child_state(States.IDLE)
##[/codeblock]
class_name StateNode
extends Node


## 进入当前状态
signal entered_state(data: Dictionary)
## 执行线程
signal state_processed()
## 退出当前状态
signal exited_state
## 子节点进入状态
signal child_state_entered(state_name, data: Dictionary)
## 子节点退出状态
signal child_state_exited(state_name)
## 状态发生切换。[code]previous[/code]上个状态名称，[code]current[/code]当前状态名，
##[code]data[/code]当前状态进入时传入的数据
signal child_state_changed(previous, current, data: Dictionary)

## 新增状态
signal newly_added_state(state_name)
## 移除状态
signal removed_state(state_name)


# 根节点状态
var _root_state : StateNode
# 当前状态名称
var _state_name
# 父状态节点
var _parent_state : StateNode
# 名称对应的状态节点
var _name_to_state_node : Dictionary = {}
# 线程执行时的回调
var _process_callback_data : Array[Dictionary] = []

# 最后一次进入状态时的数据
var _last_enter_data : Dictionary = {}
# 当前执行的子状态名
var _current_child_state = null


#============================================================
#  SetGet
#============================================================
## 获取状态。通过枚举添加时使用这个进行获取会很方便。
func get_state_node(state_name) -> StateNode:
	return _name_to_state_node.get(state_name)

## 是否存在有这个子状态
func has_state(state_name) -> bool:
	return _name_to_state_node.has(state_name)

## 获取子状态名列表
func get_state_name_list() -> Array:
	return _name_to_state_node.keys()

## 获取当前执行的子级状态名称
func get_current_state():
	return _current_child_state

## 获取当前运行的状态子节点
func get_current_state_node() -> StateNode:
	return get_state_node(_current_child_state) \
		if _current_child_state != null \
		else null

## 获取进入这个状态时的数据。如果是根状态节点，可以当做一个全局的数据
func get_last_data() -> Dictionary:
	return _last_enter_data

## 获取父状态
func get_parent_state() -> StateNode:
	return _parent_state

## 当前状态是否正在运行中
func is_running() -> bool:
	return (_root_state == self 
		or get_parent_state().get_current_state_node() == self
	)

## 获取根节点状态
func get_root_state_node() -> StateNode:
	return _root_state

## 获取自身状态名称
func get_self_state_name():
	return _state_name

## 查找子状态节点
##[br]
##[br][code]state_name[/code]  状态名
##[br][code]from_parent[/code]  从这个状态开始。不传入默认为当前根节点
##[br][code]return[/code]  返回找到的状态节点
func find_state_node(state_name, from_parent: StateNode = null) -> StateNode:
	if from_parent == null:
		from_parent = _root_state
	if from_parent.has_state(state_name):
		return get_state_node(state_name)
	var state_node : StateNode
	for child_state_name in get_state_name_list():
		state_node = find_state_node(state_name, get_state_node(child_state_name))
		if state_node != null:
			return state_node
	return null


## 获取所有父节点的名称
func get_all_parent_state_name() -> Array:
	if self == _root_state:
		return []
	var list : Array = []
	var p = self
	while p != _root_state:
		list.append(p.get_parent_state().get_child_state_name(p))
		p = p.get_parent_state()
	list.reverse()
	return list


## 获取所有父级祖父级节点
##[br]
##[br][b]注意：[/b] 不包含根节点
func get_all_parent_state_node() -> Array[StateNode]:
	if self == _root_state:
		return []
	var list : Array = []
	var p = self
	while p != null:
		list.append(p.get_parent_state())
		p = p.get_parent_state()
	list.reverse()
	return list



#============================================================
#  内置
#============================================================
func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			set_physics_process(false)
			set_process(false)
			var p = self
			while p is StateNode:
				_root_state = p
				p = p.get_parent()
		
		NOTIFICATION_READY:
			set_physics_process(false)
			set_process(false)
			if _root_state == self:
				enter_state({})


func _physics_process(delta: float) -> void:
	_process_listener.call_items()
	_state_process(delta)
	self.state_processed.emit()


## 虚方法，专门用于重写
func _state_process(delta):
	pass



#============================================================
#  自定义
#============================================================
## 注册状态
func register_state(state_name, state_node: StateNode) -> void:
	assert(not _name_to_state_node.has(state_name), "已经添加过 " + str(state_name) + " 状态")
	
	# 连接信号
	state_node.entered_state.connect( 
		func(data):
			self.child_state_entered.emit( state_name, data ) 
	)
	state_node.exited_state.connect( 
		func(): 
			self.child_state_exited.emit( state_name ) 
	)
	
	# 存储数据
	_name_to_state_node[state_name] = state_node
	state_node._parent_state = self
	state_node._state_name = state_name
	
	self.newly_added_state.emit(state_name)


## 添加状态
##[br]
##[br][code]state[/code]  状态名。可以是任意类型
##[br][code]state_node[/code]  指定的状态节点
##[br][code]return[/code]  返回添加的状态节点
func add_state(state_name, state_node: StateNode = null) -> StateNode:
	if state_node == null:
		state_node = StateNode.new()
		state_node.name = str(state_name)
		add_child(state_node, true)
	register_state(state_name, state_node)
	return state_node


## 添加状态数据
##[br]
##[br][code]name_to_node[/code]  状态名对应的状态节点
func add_state_data(name_to_node: Dictionary):
	for state_name in name_to_node:
		add_state(state_name, name_to_node[state_name])


## 添加多个状态节点
##[br]
##[br][code]list[/code]  状态名列表
##[br][code]return[/code]  返回对应状态节点列表
func add_multi_states(list: Array) -> Array[StateNode]:
	var nodes : Array[StateNode] = []
	for state in list:
		nodes.append(add_state(state))
	return nodes


## 移除状态
func remove_state(state_name) -> bool:
	if has_state(state_name):
		assert(_current_child_state != state_name, "当前状态正在运行！")
		self.removed_state.emit(state_name)
		_name_to_state_node.erase(state_name)
		return true
	return false


## 进入子状态
func enter_child_state(state_name, data: Dictionary = {}) -> void:
	assert(is_inside_tree(), "此节点还未添加到场景中")
	if state_name == _current_child_state:
		push_error("已经在这个状态中，不能重复切换. state name: %s" % [state_name] )
		return 
	
	assert(_name_to_state_node.has(state_name), "没有这个状态")
	assert(is_running(), "当前状态(%s)还未启动！" % [ get_self_state_name() ])
	
	if _current_child_state:
		trans_to_child(state_name, data)
	
	else:
		_current_child_state = state_name
		get_current_state_node().enter_state(data)

## 退出子状态
func exit_child_state() -> void:
	if _current_child_state:
		get_current_state_node().exit_state()
		_current_child_state = null

## 父节点执行的状态转换到自己这个状态
func trans_to_self(data: Dictionary = {}):
	var parent_state = get_parent_state()
	if parent_state.is_running():
		parent_state.trans_to_child(_state_name, data)

## 当前子状态切换到另一种状态
func trans_to_child(
	state_name, 
	data: Dictionary = {}, 
	ignore_running : bool = false ## 忽略是否已在这个状态中
) -> void:
	assert(self.is_inside_tree(), "此状态还未添加到树中")
	assert(is_running(), "当前状态还未启动")
#	assert(_current_child_state != null, "子状态机还未启动，请使用 enter_child_state 先启动子节点")
	assert(_name_to_state_node.has(state_name), "没有这个状态(%s)" % [ state_name ])
	if not ignore_running:
		assert(state_name != _current_child_state, "已经在这个状态中，不能重复切换")
	else:
		if state_name == _current_child_state:
			return 
	
	# 退出上次状态
	var previous_state = _current_child_state
	if _current_child_state:
		get_current_state_node().exit_state()
	# 进入当前状态
	_current_child_state = state_name
	get_current_state_node().enter_state(data)
	
	self.child_state_changed.emit( previous_state, state_name, data )


## 将当前状态切换到同级的其他状态中
func trans_to(state, data: Dictionary = {}) -> void:
	assert(_root_state != self, "当前是根状态，不能切换到其他状态")
	assert(get_parent_state().get_current_state_node() == self, "当前状态没有运行，不能切换这个状态")
	assert(is_running(), "当前状态还未启动")
	
	get_parent_state().trans_to_child(state, data)


## 全局切换状态
func global_trans_to(state_name, data: Dictionary) -> void:
	var state_node = find_state_node(state_name)
	assert(state_node, "没有这个状态")
	
	var list = state_node.get_all_parent_state_node()
	list.reverse()
	# 逐个进入
	var curr_state_name = state_name
	for parent_state_node in list:
		parent_state_node.enter_child_state(curr_state_name)
		curr_state_name = parent_state_node.get_self_state_name()


## 进入当前状态
##[br]
##[br][code]data[/code]  进入时的数据
func enter_state(data: Dictionary) -> void:
	assert(self.is_inside_tree(), "状态还未添加到节点树中")
	
	_last_enter_data = data
	_enter_listener.call_items()
	
	set_physics_process(true)
	set_process(true)
	_enter_state(data)
	self.entered_state.emit(data)

## 虚方法，专门用于重写
func _enter_state(data: Dictionary):
	pass


## 退出当前状态
func exit_state() -> void:
	if not is_inside_tree():
		await ready
	assert(_root_state != self, "根状态节点不能退出")
	assert(is_running(), "状态还未启动，不能退出状态")
	
	exit_child_state()
	
	if is_running():
		_exit_listener.call_items()
	
	set_physics_process(false)
	set_process(false)
	
	_exit_state()
	self.exited_state.emit()


## 虚方法，用于重写
func _exit_state():
	pass



#============================================================
#  监听状态器。要注意以下几点要求
# 
# - listen 监听的方法没有参数
# - 如果要中断后面的优先级的方法的执行，则返回 true 即可
# - listen 方法会返回一个取消监听的回调方法
#============================================================
class StateListener:
	var _priority : PriorityQueue = PriorityQueue.new()
	
	func call_items() -> bool:
		for item in _priority.get_all_item():
			if Callable(item["callback"]).call():
				return true
		return false
	
	# 返回断开连接的方法
	func listen(priority: int, callback: Callable) -> Callable:
		_priority.append(priority, {
			"callback": callback, 
			"priority": priority,
		})

		return func(): _priority.erase(priority, callback)

var _enter_listener : StateListener = StateListener.new()
var _exit_listener : StateListener = StateListener.new()
var _process_listener : StateListener = StateListener.new()

##  监听登录状态，可以设置调用的优先级。(向上查看注释内容)
func listen_enter(callable: Callable, priority: int = 0) -> Callable:
	return _enter_listener.listen(priority, callable)

##  监听退出状态，可以设置调用的优先级。(向上查看注释内容)
func listen_exit(callable: Callable, priority: int = 0) -> Callable:
	return _exit_listener.listen(priority, callable)

##  监听状态线程，可以设置调用的优先级。(向上查看注释内容)
func listen_process(callable: Callable, priority: int = 0) -> Callable:
	return _process_listener.listen(priority, callable)
