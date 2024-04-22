# editor_script_00.gd
@tool
extends EditorScript


func _run():
	
	var dir = DirAccess.open("res://")
	print(dir.get_current_dir())
	

