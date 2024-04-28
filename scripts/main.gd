extends Node2D

const CHAT_VOTE: String = "CHAT_VOTE"
const ROUND_END: String = "ROUND_END"

func _ready():
	$API.game_started = on_game_started
	$API.got_categories = $Menu.update_category_list
	$API.got_ws_message = on_server_api_got_ws_message
	$API.login_completed = on_login_completed
	$API.next_round_completed = $Question.show_round_data
	$API.streamervote_completed = $Question.vote_response
	$Login.api_login = $API.login
	$Menu.start_game = $API.game_start
	$Question.api_next_round = $API.round_next
	$Question.api_vote = $API.streamervote

	$Login.show()

func on_login_completed():
	$Login.hide()
	$Menu.show()
	$API.category()

func on_game_started():
	$Menu.hide()
	$Question.show()
	$Question.start_next_round()

func on_server_api_got_ws_message(msg: Dictionary):
	match msg.type:
		CHAT_VOTE:
			print("Got chat vote: %s" % [msg])
		ROUND_END:
			$Question.on_round_end(msg)
		_:
			print("Got unkown ws message type: '%s': %s" % [msg.type, msg])
