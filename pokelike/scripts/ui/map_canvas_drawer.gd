# res://scripts/ui/map_canvas_drawer.gd
extends Control

@onready var route_map: Control = $"../.."

func _draw() -> void:
	if route_map and route_map.has_method("draw_map_paths"):
		route_map.draw_map_paths(self)
