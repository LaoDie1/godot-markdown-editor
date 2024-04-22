#============================================================
#    Node Pool
#============================================================
# - author: zhangxuetu
# - datetime: 2023-08-04 20:06:02
# - version: 4.0
#============================================================
## 节点池。如果放弃使用，直接将节点从树中移除即可
##[codeblock]
##node.get_parent().remove_child(node)
##[/codeblock]
##不要使用 [method Node.queue_free]
class_name NodePool


static func instantiate(type_or_create_callback):
	var key := StringName("NodePool_%s" % [hash(type_or_create_callback)])
	var p : NodePool
	if not Engine.has_meta(key) or not is_instance_valid(Engine.get_meta(key)):
		Engine.set_meta(key, NodePool.new(10))
	p = Engine.get_meta(key)
	if type_or_create_callback is PackedScene:
		p.callback = func(): return type_or_create_callback.instantiate()
	elif type_or_create_callback is Object:
		p.callback = func(): return type_or_create_callback.new()
	elif type_or_create_callback is Callable:
		p.callback = type_or_create_callback
	return p.create()


var callback: Callable
var pool: Array[Node] = []
var last_pool: Array[Node] = []


func _init(count: int):
	(func():
		for i in count:
			_add_new_node()
	).call_deferred()


func _add_new_node():
	var node : Node = callback.call() as Node
	pool.append(node)
	node.tree_exited.connect( func(): 
		if is_instance_valid(node):
			last_pool.push_back(node) 
	)


## 从池中获取一个节点
func create():
	if pool.is_empty() and not last_pool.is_empty():
		pool = last_pool
		last_pool = []
	if pool.is_empty():
		_add_new_node()
	return pool.pop_back()


