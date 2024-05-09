class_name SceneManager extends Node

const scene_path_format: String = "res://scenes/%s.tscn"

var round_duration: int
var round_data: Dictionary = {}

func change_scene(from: Node, to_scene_name: String):
	if from is Menu:
		self.round_duration = from.round_duration
	elif from is QuestionScene:
		self.round_data = from.round_data

	var scene_path = scene_path_format % [to_scene_name]
	from.get_tree().call_deferred("change_scene_to_file", scene_path)
	api.got_ws_message = Callable()
