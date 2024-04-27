extends Node2D

var quizOn: bool = false
var streamerAnswer: String = ""

signal next_round
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

func start_countdown():
	$StartCountdown.show()
	$StartCountdown.text = "3"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "2"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "1"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.hide()
	next_round.emit()
	quizOn = true

func on_server_api_next_round_complete(round_data: Dictionary):
	$RoundCounter.text = "Round %d/%d (%s)" % [round_data.current_round, round_data.max_round, round_data.category]

	$Quiz/Question/Label.text = round_data.question
	$Quiz/Answers/AnswerA/Label.text = round_data.answers[0]
	$Quiz/Answers/AnswerB/Label.text = round_data.answers[1]
	if len(round_data.answers) >= 3:
		$Quiz/Answers/AnswerC/Label.text = round_data.answers[2]
		$Quiz/Answers/AnswerC.show()
	else:
		$Quiz/Answers/AnswerC.hide()
	if len(round_data.answers) >= 4:
		$Quiz/Answers/AnswerD/Label.text = round_data.answers[3]
		$Quiz/Answers/AnswerD.show()
	else:
		$Quiz/Answers/AnswerD.hide()

	$Quiz.show()
