#============================================================
#    Test Document
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 11:01:16
# - version: 4.3.0.dev5
#============================================================
# 绘制内容到当前场景根节点上，进行绘制测试。需要打开 canvas 场景
@tool
class_name TestDocuemnt
extends EditorScript


const file_path = r"C:\Users\z\Desktop\test1.md"
static var document : Document


func _run() -> void:
	var canvas = EditorUtil.get_edited_scene_root() as Control
	document = Document.new(canvas.size.x, file_path)
	print(document.get_doc_height())
	
	#canvas.call_draw(DrawObject.new(canvas).draw)


class DrawObject:
	extends Object
	# 必须要用 Object，防止被取消引用
	
	var canvas: CanvasItem
	var document: Document = TestDocuemnt.document
	
	func _init(canvas: CanvasItem) -> void:
		self.canvas = canvas
		FuncUtil.execute_deferred(ObjectUtil.queue_free.bind(self))
	
	func draw():
		canvas.draw_circle(Vector2(100,100), 100, Color.RED)
		
	
