class_name SceneManager extends Node

const scene_path_format: String = "res://scenes/%s.tscn"

func change_scene(from: Node, to_scene_name: String):
	var scene_path = scene_path_format % [to_scene_name]
	from.get_tree().call_deferred("change_scene_to_file", scene_path)
