extends Node2D

var host = ""
var api_token = ""

signal start_Quiz
signal start_Login
signal start_Setup

# Called when the node enters the scene tree for the first time.
func _ready():
	#load_config()
	start_Login.emit()
	$Login.show()
	
	
func load_config():
	var file = FileAccess.open("res://config.yaml", FileAccess.READ)
	host = file.get_line()


func _on_login_login_complete():
	$Login.hide()
	start_Quiz.emit()


func _on_start_quiz_start():
	pass
