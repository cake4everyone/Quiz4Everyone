extends Node2D

var host = ""
var token = ""


func _ready():
	load_config()


func _on_button_pressed():
	$LoginHTTP.request_completed.connect(_on_http_login_completed)
	var auth = Marshalls.utf8_to_base64($Input/EMail.text + ":" + $Input/Password.text)
	var err = $LoginHTTP.request("http://" + host + "/login", ["Authorization: Basic " + auth], HTTPClient.METHOD_POST)
	if(err != 0):
		print("Error: " + err)

func _on_http_login_completed(result, response_code, headers, body):
	var json = JSON.new()
	var error = json.parse(body.get_string_from_ascii())
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		print("Expected JSON Dictionary, but got TYPE: " + str(typeof(data)))
		return
	token = data.token
	print("Login successful: " + data.username)


func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()


func _on_twitch_pressed():
	$LoginHTTP.request_completed.connect(_on_http_twitch_completed)
	var auth = Marshalls.utf8_to_base64($Input/EMail.text + ":" + $Input/Password.text)
	var err = $LoginHTTP.request("http://" + host + "/test", ["Authorization: Basic " + auth], HTTPClient.METHOD_POST)
	if(err != 0):
		print("Error: " + err)

func _on_http_twitch_completed(result, response_code, headers, body):
	print("res: " + str(response_code))
	var state = "abc123"
	var lastBody = body.get_string_from_ascii()
	OS.shell_open("https://id.twitch.tv/oauth2/authorize?response_type=code&client_id=tee4z9o13lkzx1ysdug3ta37mav862&redirect_uri=https%3A%2F%2Fwebhook.cake4everyone.de/auth/twitch&scope=moderator%3Amanage%3Achat_messages&state=" + state)
