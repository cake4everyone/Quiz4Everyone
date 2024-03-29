extends Node2D

var api_token = ""
var host = ""

var quizOn = false
var streamerAnswer = ""


func _on_main_start_quiz():
	self.show()
	host = Main.host
	api_token = Main.api_token
	$HTTP_Requests/HTTP_GameStart.request_completed.connect(_start_game_res)
	$HTTP_Requests/HTTP_GameInfo.request_completed.connect(_info_game_res)
	$HTTP_Requests/HTTP_GameQuit.request_completed.connect(_quit_game_res)
	$HTTP_Requests/HTTP_RoundInfo.request_completed.connect(_info_round_res)
	$HTTP_Requests/HTTP_RoundNext.request_completed.connect(_next_round_res)
	$HTTP_Requests/HTTP_Category.request_completed.connect(_category_res)
	$HTTP_Requests/HTTP_StreamerVote.request_completed.connect(_streamervote_res)
	


func _on_game_start_pressed():
	$HTTP_Requests/HTTP_GameStart.request("http://" + host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST, '{"categories":{"Testkeks":5}}')

func _on_round_info_pressed():
	$HTTP_Requests/HTTP_RoundInfo.request("http://" + host + "/round", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)

func _on_round_next_pressed():
	$HTTP_Requests/HTTP_RoundNext.request("http://" + host + "/round/next", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)

func _on_game_quit_pressed():
	$HTTP_Requests/HTTP_GameQuit.request("http://" + host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_DELETE)
	

func _start_game_res(result, response_code, headers, body):
	print("Response Start Game: " + str(response_code) + "\n" + body.get_string_from_ascii())
	$HTTP_Requests/HTTP_GameInfo.request("http://" + host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)
	
func _info_game_res(result, response_code, headers, body):
	print("Response Info Game: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func _quit_game_res(result, response_code, headers, body):
	print("Response Quit Game: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func _info_round_res(result, response_code, headers, body):
	print("Response Info Round: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func _next_round_res(result, response_code, headers, body):
	print("Response Next Round: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func _category_res(result, response_code, headers, body):
	print("Response Category: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func _streamervote_res(result, response_code, headers, body):
	print("Response Streamervote: " + str(response_code) + "\n" + body.get_string_from_ascii())
	

