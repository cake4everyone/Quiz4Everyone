extends Node

var host = ""
var api_token = ""

signal login_complete
signal game_started
signal game_informed

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTP_Category.request_completed.connect(_category_res)
	$HTTP_GameInfo.request_completed.connect(_game_info_res)
	$HTTP_GameQuit.request_completed.connect(_game_quit_res)
	$HTTP_GameStart.request_completed.connect(_game_start_res)
	$HTTP_Login.request_completed.connect(_login_res)
	$HTTP_Logout.request_completed.connect(_logout_res)
	$HTTP_RoundInfo.request_completed.connect(_round_info_res)
	$HTTP_RoundNext.request_completed.connect(_round_next_res)
	$HTTP_StreamerVote.request_completed.connect(_streamervote_res)
	load_config()
	
	
func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()


func _category():
	$HTTP_Category.request(host + "/category", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)

func _category_res(result, response_code, headers, body):
	print("Response Category: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
	
func _game_info():
	$HTTP_GameInfo.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)
	
func _game_info_res(result, response_code, headers, body):
	print("Response Game Info: " + str(response_code) + "\n" + body.get_string_from_ascii())
	var data = _json_parse(body)
	game_informed.emit(data)
	
	
func _game_quit():
	$HTTP_GameQuit.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_DELETE)
	
func _game_quit_res(result, response_code, headers, body):
	print("Response Game Quit: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
	
func _game_start(body):
	$HTTP_GameStart.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST, body)

func _game_start_res(result, response_code, headers, body):
	print("Response Game Start: " + str(response_code) + "\n" + body.get_string_from_ascii())
	game_started.emit()
	
	
func _login(auth):
	$HTTP_Login.request(host + "/login", ["Authorization: Basic " + auth], HTTPClient.METHOD_POST)
	
func _login_res(result, response_code, headers, body):
	var data = _json_parse(body)
	print("Login successful: " + data.username)
	api_token = data.token
	login_complete.emit()
	
	
func _logout():
	$HTTP_Logout.request(host + "/logout", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)
	
func _logout_res(result, response_code, headers, body):
	print("Response Logout: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
	
func _round_info():
	$HTTP_RoundInfo.request(host + "/round", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)
	
func _round_info_res(result, response_code, headers, body):
	print("Response Round Info: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
	
func _round_next():
	$HTTP_RoundNext.request(host + "/round/next", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)

func _round_next_res(result, response_code, headers, body):
	print("Response Round Next: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
	
func _streamervote():
	$HTTP_StreamerVote.request(host + "/vote", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)
	
func _streamervote_res(result, response_code, headers, body):
	print("Response Streamervote: " + str(response_code) + "\n" + body.get_string_from_ascii())
	

func _json_parse(body):
	var json = JSON.new()
	var error = json.parse(body.get_string_from_ascii())
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		print("Expected JSON Dictionary, but got TYPE: " + str(typeof(data)))
		return
	return data
