extends Node2D

var quizOn = false
var streamerAnswer = ""

func _on_main_start_quiz():
	self.show()
	quizOn = true
	load_data()
	


func load_data():
	pass

func _process(delta):
	if(quizOn == true && streamerAnswer == ""):
		if(Input.is_action_just_pressed("AnswerA")):
			streamerAnswer = "A"
		elif(Input.is_action_just_pressed("AnswerB")):
			streamerAnswer = "B"
		elif(Input.is_action_just_pressed("AnswerC")):
			streamerAnswer = "C"
		elif(Input.is_action_just_pressed("AnswerD")):
			streamerAnswer = "D"
	$Label.text = streamerAnswer
