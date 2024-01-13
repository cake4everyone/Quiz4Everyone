extends Node2D
var ws: WebSocketPeer = WebSocketPeer.new()
var host = ""

signal StartQuiz

func _ready():
	$QuestionScene.hide()
	$Start.hide()
	load_config()

func connect_to_ws():
	var err = ws.connect_to_url("ws://"+host+"/login")
	if err != OK:
		print("Error:", err)
		return

	print("Connected Succesfully")

func _send_message_to_ws(message : String):
	print("send data: ", message)
	print("sent data: ", ws.send_text(message))

func _process(delta):
	ws.poll()
	if ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		return

	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("connection lost")
		set_process(false)
		return

	if(Input.is_action_just_pressed("ui_accept") and $Password.text != ""):
		_send_message_to_ws($Password.text)
		$Password.text = ""
		$Start.show()
	receive()

func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()

func _on_button_pressed():
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func receive():
	while ws.get_available_packet_count():
		var received_data = ws.get_packet()
		print("Data received: ", received_data)

func _on_start_pressed():
	StartQuiz.emit()
	$Password.hide()
	_send_message_to_ws("GAME: Test")
	await get_tree().create_timer(1).timeout
