#============================================================
#    Path Texture
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-18 22:55:00
# - version: 4.0
#============================================================
## 创建路径图像
@tool
class_name PathTexture
extends Line2D


## 运行后会自动更新，勾选后每次都会运行显示不同的内容
@export var auto_update : bool = false
## 更新显示内容
@export var update: bool = true:
	set(v): 
		update = true
		_update_content()
## 种子值
@export var seed_value : int = 0
## 模板节点，创建的节点会以这个节点设置显示图像
@export var template : CanvasItem
## 间隔距离
@export var separactor : float = 10
## 每个间隔生成节点的概率
@export_range(0, 1) var probability : float = 0.3


var _last_node_list : Array[Node] = []
var _random_gene  : RandomNumberGenerator = RandomNumberGenerator.new()


#============================================================
#  内置
#============================================================
func _ready():
	_update_content()


#============================================================
#  自定义
#============================================================
func _update_content():
	for node in _last_node_list:
		node.queue_free()
	_last_node_list.clear()
	
	# 模板节点
	if template == null:
		return
	
	if auto_update or seed_value == 0:
		seed_value = _random_gene.randi()
	_random_gene.seed = seed_value
	
	var from : Vector2
	var to : Vector2
	var dir : Vector2
	var size : Vector2
	for i in range(1, points.size()):
		from = points[i - 1]
		to = points[i]
		dir = from.direction_to(to)
		for dist in range(0, from.distance_to(to), separactor):
			if _random_gene.randf() < probability:
				var texture_rect = template.duplicate() as Node
				texture_rect.position += from + dir * dist
				texture_rect.visible = true
				add_child(texture_rect, true)
				_last_node_list.append(texture_rect)
	
