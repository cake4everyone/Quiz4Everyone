extends Node2D

func _ready():
	$API.game_started = on_game_started
	$API.got_categories = $Menu.update_category_list
	$API.login_completed = on_login_completed
	$API.next_round_completed = $Question.show_round_data
	$Login.api_login = $API.login
	$Menu.start_game = $API.game_start
	$Question.api_next_round = $API.round_next

	$Login.show()

func on_login_completed():
	$Login.hide()
	$Menu.show()
	$API.category()

func on_game_started():
	$Menu.hide()
	$Question.show()
	$Question.start_next_round()
