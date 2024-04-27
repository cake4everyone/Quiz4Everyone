extends Node2D

var quizOn: bool = false
var streamerAnswer: String = ""

var api_next_round: Callable

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

## start_next_round shows a 3 second countdown before showing the round data.
func start_next_round():
	$StartCountdown.show()
	$StartCountdown.text = "3"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "2"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "1"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.hide()
	api_next_round.call()
	quizOn = true

## show_round_data displays the given round data on screen.
func show_round_data(round_data: Dictionary):
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
