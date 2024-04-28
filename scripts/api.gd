extends Node2D

var ws: WebSocketPeer = WebSocketPeer.new()
var host: String = ""
var api_token: String = ""

## set by main scene
var game_started: Callable
var got_categories: Callable
var got_ws_message: Callable
var login_completed: Callable
var next_round_completed: Callable

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
	set_process(false)

func _process(_delta: float):
	var msg: Dictionary = read_from_ws()
	if len(msg) > 0:
		got_ws_message.call(msg)

func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()

## category gets the available categories from the server.
func category():
	$HTTP_Category.request(host + "/category", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)

func category_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if response_code != HTTPClient.RESPONSE_OK:
		print("couldn't get categories: got %d expexted %d: %s" % [response_code, HTTPClient.RESPONSE_OK, body.get_string_from_ascii()])
		return
	got_categories.call(json_parse(body))

## game_info gets information about the current state of the game.
func game_info():
	$HTTP_GameInfo.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)

func game_info_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Game Info: " + str(response_code) + "\n" + body.get_string_from_ascii())

## game_quit ends the current running game.
func game_quit():
	$HTTP_GameQuit.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_DELETE)

func game_quit_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Game Quit: " + str(response_code) + "\n" + body.get_string_from_ascii())

## game_start starts new game with the selected categories.
func game_start(body: String):
	$HTTP_GameStart.request(host + "/game", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST, body)

func game_start_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if response_code != HTTPClient.RESPONSE_CREATED:
		print("couldn't create new game: got %d expected %d: %s" % [response_code, HTTPClient.RESPONSE_CREATED, body.get_string_from_ascii()])
		return
	print(body.get_string_from_ascii())
	game_started.call()

## login sends a login request to the server.
func login(auth: String):
	$HTTP_Login.request(host + "/login", ["Authorization: Basic " + auth], HTTPClient.METHOD_POST)

func login_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if (response_code != 200):
		print("Login failed: ", response_code)
		return
	var data = json_parse(body)
	print("Login successful: " + data.username)
	api_token = data.token
	connect_to_ws()
	login_completed.call()

## logout sends a logout request to the server. Resulting in an invalid token until a new login request is
## made.
func logout():
	$HTTP_Logout.request(host + "/logout", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)

func logout_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Logout: " + str(response_code) + "\n" + body.get_string_from_ascii())

## round_info gets information about the current round without spoiling the correct answer.
func round_info():
	$HTTP_RoundInfo.request(host + "/round", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_GET)

func round_info_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Round Info: " + str(response_code) + "\n" + body.get_string_from_ascii())

## round_next advances the game to the round and returning information about the new active round. This is also
## required for the first round after a freshly created game.
func round_next():
	$HTTP_RoundNext.request(host + "/round/next", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)

func round_next_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if response_code != HTTPClient.RESPONSE_OK:
		print("Failed to advance to next sound: got %d expected %d: %s" % [response_code, HTTPClient.RESPONSE_OK, body.get_string_from_ascii()])
		return

	next_round_completed.call(json_parse(body))

## streamervote sets the selected vote of the streamer. Only available once per round.
func streamervote():
	$HTTP_StreamerVote.request(host + "/vote", ["Authorization: Q4E " + api_token], HTTPClient.METHOD_POST)

func streamervote_resp(_result, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("Response Streamervote: " + str(response_code) + "\n" + body.get_string_from_ascii())

## json_parse is a helper function that parses the response body as json.
func json_parse(body: PackedByteArray) -> Dictionary:
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
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
	var err = ws.connect_to_url(host.replace("http", "ws") + "/chat")
	if err != OK:
		print("Error connecting to WS:", err)
		return

	set_process(true)
	print("Websocket connected")

func send_message_to_ws(message: String) -> Error:
	var err = ws.send_text(message)
	if err != OK:
		print("Error sending to WS: ", err)
		return err
	print("WS <= ", message)
	return OK

func read_from_ws() -> Dictionary:
	ws.poll()
	var state: int = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if ws.get_available_packet_count() > 0:
			return json_parse(ws_read_packets())
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = ws.get_close_code()
		var reason = ws.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != - 1])
		set_process(false)

	return {}

func ws_read_packets() -> PackedByteArray:
	var received_data: PackedByteArray = PackedByteArray()
	while ws.get_available_packet_count():
		received_data += ws.get_packet()

	return received_data
