extends Node2D

var quizOn = false
var streamerAnswer = ""

func _process(delta):
	if(quizOn == true):
		if(Input.is_action_pressed("AnswerA") == true):
			streamerAnswer = "A"
		if(Input.is_action_pressed("AnswerB") == true):
			streamerAnswer = "B"
		if(Input.is_action_pressed("AnswerC") == true):
			streamerAnswer = "C"
		if(Input.is_action_pressed("AnswerD") == true):
			streamerAnswer = "D"

func _on_main_start_quiz():
	self.show()
	_start_countdown()


func _start_countdown():
	$StartCountdown.show()
	$StartCountdown.text = "3"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "2"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "1"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.hide()
	_quizloop()
	
func _quizloop():
	quizOn = true
	
	
	
