@tool
extends Control


const ICONS = preload("res://addons/simplemenu/example/icons.tres")


@onready var simple_menu = %SimpleMenu


func _ready():
	simple_menu.init_menu({
		"File": [
			"Open", "Save", "Save As", "-",
			{"Export As": [ "Export PNG", "Export JPG" ] }, "-",
			"Quit",
		],
		"Edit": [
			"Undo", "Redo", "-",
			"Copy", "Cut", "Clear",
		]
	})
	
	simple_menu.init_shortcut({
		"/File/Open": SimpleMenu.parse_shortcut("Ctrl+O"),
		"/File/Save": SimpleMenu.parse_shortcut("Ctrl+S"),
		"/File/Save As": SimpleMenu.parse_shortcut("Ctrl+Shift+S"),
		"/Edit/Undo": SimpleMenu.parse_shortcut("Ctrl+Z"),
		"/Edit/Redo": SimpleMenu.parse_shortcut("Ctrl+Shift+Z"),
		"/Edit/Copy": SimpleMenu.parse_shortcut("Ctrl+C"),
		"/Edit/Cut": SimpleMenu.parse_shortcut("Ctrl+X"),
	})
	
	simple_menu.init_icon({
		"/File/Open": ICONS.get_icon("File", "EditorIcons"),
		"/File/Save As": ICONS.get_icon("Save", "EditorIcons"),
		"/Edit/Undo": ICONS.get_icon("UndoRedo", "EditorIcons"),
		"/Edit/Copy": ICONS.get_icon("ActionCopy", "EditorIcons"),
		"/Edit/Cut": ICONS.get_icon("ActionCut", "EditorIcons"),
		"/Edit/Clear": ICONS.get_icon("Clear", "EditorIcons"),
	})


func _on_simple_menu_menu_pressed(idx, menu_path):
	# Implement menu functions 
	print("Clicked: ", menu_path)



