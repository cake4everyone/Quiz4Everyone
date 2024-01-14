extends Node2D
var ws: WebSocketPeer = WebSocketPeer.new()
var host = ""
var wsrunning = false
var token = ""

signal StartQuiz


# INNATE FUNC

func _ready():
	load_config()
	$LoginHTTP.request_completed.connect(_on_http_request_completed)
	$Password.show()
	$Exit.show()
	$QuestionScene.hide()
	$Start.hide()
	
	
func _process(delta):
	if wsrunning:
		ws.poll()
		if ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
			return

		if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
			print("connection lost")
			set_process(false)
			return

	if(Input.is_action_just_pressed("ui_accept") and $Password.text != ""):
		token = $Password.text
		$Password.text = ""
		$Start.show()
		var login_dict = {
			"password" = "TotsBIOQmtGZheiUaQLg2xvM9",
			"twitch" = token,
		}
		var json_string = JSON.stringify(login_dict)
		$LoginHTTP.request("http://" + host + "/login", [], HTTPClient.METHOD_POST, json_string)
		connect_to_ws()
		
	receive()


func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()


# WEBSOCKET

func connect_to_ws():
	var headers = PackedStringArray(["Authorization: Q4E "+token])
	ws.set_handshake_headers(headers)
	var err = ws.connect_to_url("ws://"+host+"/chat")
	if err != OK:
		print("Error:", err)
		return
	wsrunning = true

	print("Connected Succesfully")

func _send_message_to_ws(message : String):
	var err = ws.send_text(message)
	if err != OK:
		print("Error sending: ", err)
		return
	print("WS <= ", message)


func receive():
	while ws.get_available_packet_count():
		var received_data = ws.get_packet()
		print("WS => ", received_data.get_string_from_ascii())


# USER INTERFACE

func _on_button_pressed():
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func _on_start_pressed():
	StartQuiz.emit()
	$Password.hide()
	$Start.hide()
	_send_message_to_ws("GAME: Test")
	await get_tree().create_timer(1).timeout


#HTTP

func _on_http_request_completed(result, response_code, headers, body):
	print("test ", response_code)
	print(body.get_string_from_ascii())




