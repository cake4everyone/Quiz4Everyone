extends Node2D

signal start_Quiz
signal start_Login
signal start_Setup

func _ready():
	start_Login.emit()
	$StartQuiz.hide()
	$QuestionScene.hide()
	$Login.show()


func _on_start_quiz_start():
	pass


func _on_server_api_login_complete():
	$Login.hide()
	start_Setup.emit()
