extends Node2D

var quizOn: bool = false
var streamerAnswer: String = ""

signal round_info
signal game_info

func _process(_delta: float):
	if quizOn:
		if Input.is_action_pressed("AnswerA"):
			streamerAnswer = "A"
		if Input.is_action_pressed("AnswerB"):
			streamerAnswer = "B"
		if Input.is_action_pressed("AnswerC"):
			streamerAnswer = "C"
		if Input.is_action_pressed("AnswerD"):
			streamerAnswer = "D"

func on_main_start_quiz():
	self.show()
	start_countdown()
	round_info.emit()

func start_countdown():
	$StartCountdown.show()
	$StartCountdown.text = "3"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "2"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "1"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.hide()
	quizOn = true
