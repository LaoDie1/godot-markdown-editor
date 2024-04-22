# editor_script_01.gd
@tool
extends EditorScript


func _run():
	var r = RandomRooms.new()
	r.size = Vector2i(10, 8)
	r.generate(3, 5)
	r.display()

