extends Node2D
var tcp: StreamPeerTCP = StreamPeerTCP.new()
var host = ""
var port = 0


func _ready():
	load_config()
	var error = tcp.connect_to_host(host, port)
	if error != OK:
		print("Error:", error)
		return
		
	print(tcp.get_connected_host(), tcp.get_connected_port())
	print("Connected Succesfully")
	
func _send_message_to_tcp(message : String):
	var data = message.to_ascii_buffer()
	print(data)
	print(tcp.get_status())
	print(tcp.put_data(data))

func _process(delta):
	tcp.poll()
	if(tcp.get_status() != 2):
		return
		
	if(Input.is_action_just_pressed("ui_accept") and $Password.text != ""):
		_send_message_to_tcp($Password.text)
		$Password.text = ""
	
func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()
	port = int(file.get_line())

func _on_button_pressed():
	tcp.disconnect_from_host()
