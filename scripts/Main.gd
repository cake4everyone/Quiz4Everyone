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


func _on_server_api_game_started():
	$StartQuiz.hide()
	start_Quiz.emit()


func _on_server_api_game_informed(extra_arg_0):
	print(extra_arg_0)
