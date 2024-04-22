#============================================================
#    Panel Border
#============================================================
# - datetime: 2023-02-18 17:42:14
#============================================================
## 添加到 Panel 或 PanelContainer 节点下，更新 panel 样式边框
@tool
class_name PanelBorder
extends Node


const PROPERTY_PANEL_STYLE = "theme_override_styles/panel"

@export var border_color : Color = Color.WHITE:
	set(v):
		border_color = v
		_update_panel()
@export var draw_back_color : bool = true:
	set(v):
		draw_back_color = v
		_update_panel()
@export var back_color : Color = Color.BLACK:
	set(v):
		back_color = v
		_update_panel()
@export var border_width : int = -1 :
	set(v):
		border_width = v
		_update_panel()
@export var expand_margin : int = -1 :
	set(v):
		expand_margin = v
		_update_panel()
@export var corner_radius : int = -1 :
	set(v):
		corner_radius = v
		_update_panel()


func _enter_tree():
	var panel = get_parent()
	if panel is Panel or panel is PanelContainer:
		if panel[PROPERTY_PANEL_STYLE] == null:
			var style = StyleBoxFlat.new()
			panel[PROPERTY_PANEL_STYLE] = style
			style.draw_center = false
	_update_panel()


func _update_panel():
	if get_parent() == null:
		await self.ready
		await get_tree().process_frame
	
	var panel = get_parent() as Control
	if panel is Panel or panel is PanelContainer:
		var style = panel[PROPERTY_PANEL_STYLE]
		style.border_color = border_color
		if style is StyleBoxFlat:
			for dir in ["left", "top", "right", "bottom"]:
				style.set("border_width_" + dir, max(0, border_width))
				style.set("expand_margin_" + dir, max(0, expand_margin))
			for dir in ["top_left", "top_right", "bottom_right", "bottom_left"]:
				style.set("corner_radius_" + dir, max(0, corner_radius))
			
			style.draw_center = draw_back_color
			if draw_back_color:
				style.bg_color = back_color


func _get_configuration_warnings() -> PackedStringArray:
	var list := PackedStringArray()
	if not (get_parent() is Panel or get_parent() is PanelContainer):
		list.append("父节点不是 Panel 或 PanelContainer 类型的节点")
	else:
		var panel = get_parent() as Control
		var panel_style = panel.get(PROPERTY_PANEL_STYLE) as StyleBox
		if panel_style != null:
			if not panel_style is StyleBoxFlat:
				list.append(PROPERTY_PANEL_STYLE + " 属性资源类型不是 StyleBoxFlat")
			
		else:
			list.append("没有设置 " + PROPERTY_PANEL_STYLE + " 属性")
	
	return list
