class_name SceneManager extends Node

const scene_path_format: String = "res://scenes/%s.tscn"
const DISCORD_APP_ID = 1282067747106455572

var round_duration: int
var round_data: Dictionary = {}

func _ready():
	DiscordRPC.app_id = DISCORD_APP_ID
	update_discord("login")

func change_scene(from: Node, to_scene_name: String):
	if from is Menu:
		self.round_duration = from.round_duration
	elif from is QuestionScene:
		self.round_data = from.round_data
	elif from is QuestionEndScene:
		self.round_data = {}

	var scene_path = scene_path_format % [to_scene_name]
	from.get_tree().call_deferred("change_scene_to_file", scene_path)
	api.got_ws_message = Callable()

	update_discord(to_scene_name)

func update_discord(to_scene_name: String, data: Dictionary = {}):
	if data == {}:
		data = self.round_data
	match to_scene_name:
		"login":
			DiscordRPC.details = ""
			DiscordRPC.state = "Logging in..."
			DiscordRPC.large_image = "cake"
			DiscordRPC.large_image_text = "by Cake4Everyone"
		"menu":
			DiscordRPC.details = ""
			DiscordRPC.state = "In Menu"
			DiscordRPC.large_image = "cake"
			DiscordRPC.large_image_text = "by Cake4Everyone"
		"question":
			print("round data: ", data)
			if data == {}:
				DiscordRPC.details = "Question"
			else:
				DiscordRPC.details = "Question (%d/%s)" % [data.current_round, data.max_round]
			DiscordRPC.state = "In game"
			DiscordRPC.large_image = "cake"
			DiscordRPC.large_image_text = "by Cake4Everyone"
		"question_end":
			print("round data: ", data)
			if data == {}:
				DiscordRPC.details = "Question Result"
			else:
				DiscordRPC.details = "Question Result (%d/%s)" % [data.current_round, data.max_round]
			DiscordRPC.state = "In game"
			DiscordRPC.large_image = "cake"
			DiscordRPC.large_image_text = "by Cake4Everyone"
		"game_end":
			print("round data: ", round_data)
			DiscordRPC.details = "Game result"
			DiscordRPC.state = "Game overview"
			DiscordRPC.large_image = "cake"
			DiscordRPC.large_image_text = "by Cake4Everyone"
		_:
			DiscordRPC.details = ""
			DiscordRPC.state = ""
			DiscordRPC.large_image = "cake"
			DiscordRPC.large_image_text = "by Cake4Everyone"
	
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
