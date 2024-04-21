extends Node

var ws: WebSocketPeer = WebSocketPeer.new()
var host: String = ""
var api_token: String = ""

signal login_complete
signal game_started
signal game_informed

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTP_Category.request_completed.connect(category_resp)
	$HTTP_GameInfo.request_completed.connect(game_info_resp)
	$HTTP_GameQuit.request_completed.connect(game_quit_resp)
	$HTTP_GameStart.request_completed.connect(game_start_resp)
	$HTTP_Login.request_completed.connect(login_resp)
	$HTTP_Logout.request_completed.connect(logout_resp)
	$HTTP_RoundInfo.request_completed.connect(round_info_resp)
	$HTTP_RoundNext.request_completed.connect(round_next_resp)
	$HTTP_StreamerVote.request_completed.connect(streamervote_resp)
	load_config()
	
func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()

func category():
	$HTTP_Category.request(host + "/category", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)

func category_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Category: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func game_info():
	$HTTP_GameInfo.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)
	
func game_info_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Game Info: " + str(response_code) + "\n" + body.get_string_from_ascii())
	var data = json_parse(body)
	game_informed.emit(data)
	
func game_quit():
	$HTTP_GameQuit.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_DELETE)
	
func game_quit_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Game Quit: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func game_start(body: String):
	$HTTP_GameStart.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST, body)

func game_start_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Game Start: " + str(response_code) + "\n" + body.get_string_from_ascii())
	game_started.emit()
	
func login(auth: String):
	$HTTP_Login.request(host + "/login", ["Authorization: Basic " + auth], HTTPClient.METHOD_POST)
	
func login_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if (response_code != 200):
		print("Login failed: ", response_code)
		return
	var data = json_parse(body)
	print("Login successful: " + data.username)
	api_token = data.token
	login_complete.emit()
	
func logout():
	$HTTP_Logout.request(host + "/logout", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)
	
func logout_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Logout: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func round_info():
	$HTTP_RoundInfo.request(host + "/round", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)
	
func round_info_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Round Info: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func round_next():
	$HTTP_RoundNext.request(host + "/round/next", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)

func round_next_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Round Next: " + str(response_code) + "\n" + body.get_string_from_ascii())
	
func streamervote():
	$HTTP_StreamerVote.request(host + "/vote", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)
	
func streamervote_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Streamervote: " + str(response_code) + "\n" + body.get_string_from_ascii())

func json_parse(body: PackedByteArray) -> Dictionary:
	var json = JSON.new()
	var error = json.parse(body.get_string_from_ascii())
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return Dictionary()
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		print("Expected JSON Dictionary, but got TYPE: " + str(typeof(data)))
		return Dictionary()
	return data

# Websocket
func connect_to_ws():
	var headers = PackedStringArray(["Authorization: Q4E " + api_token])
	ws.set_handshake_headers(headers)
	var err = ws.connect_to_url("ws://" + host + "/chat")
	if err != OK:
		print("Error connecting to WS:", err)

	print("Connected Succesfully")

func send_message_to_ws(message: String) -> Error:
	var err = ws.send_text(message)
	if err != OK:
		print("Error sending to WS: ", err)
		return err
	print("WS <= ", message)
	return OK

# some docs
func read_from_ws() -> PackedByteArray:
	var received_data: PackedByteArray = PackedByteArray()
	while ws.get_available_packet_count():
		received_data += ws.get_packet()
		print("WS => ", received_data.get_string_from_ascii())
	
	return received_data
