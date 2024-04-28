extends Node2D

var quizOn: bool = false
var voted: bool = false

var api_next_round: Callable
var api_vote: Callable

func _process(_delta: float):
	if quizOn&&!voted:
		check_vote()

func check_vote():
	if Input.is_key_pressed(KEY_A)||Input.is_key_pressed(KEY_1)||Input.is_key_pressed(KEY_KP_1): api_vote.call("1")
	elif Input.is_key_pressed(KEY_B)||Input.is_key_pressed(KEY_2)||Input.is_key_pressed(KEY_KP_2): api_vote.call("2")
	elif Input.is_key_pressed(KEY_C)||Input.is_key_pressed(KEY_3)||Input.is_key_pressed(KEY_KP_3): api_vote.call("3")
	elif Input.is_key_pressed(KEY_D)||Input.is_key_pressed(KEY_4)||Input.is_key_pressed(KEY_KP_4): api_vote.call("4")
	else: return
	voted = true
	$Quiz/Answers/VoteIcon.self_modulate = Color.ORANGE

func vote_response(ok: bool):
	if ok:
		print("You have voted!")
		$Quiz/Answers/VoteIcon.self_modulate = Color.GREEN
	else:
		print("vote wasnt valid")
		$Quiz/Answers/VoteIcon.self_modulate = Color.WHITE
	voted = ok

## start_next_round shows a 3 second countdown before showing the round data.
func start_next_round():
	$Quiz.hide()
	voted = false
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
	print(round_data)
	$RoundCounter.text = "Runde %d/%d (%s)" % [round_data.current_round, round_data.max_round, round_data.category]
	$RoundCounter.show()

	$Quiz/Question/QuestionLabel.text = round_data.question
	$Quiz/Answers/A/AnswerLabel.text = round_data.answers[0]
	$Quiz/Answers/B/AnswerLabel.text = round_data.answers[1]
	if len(round_data.answers) >= 3:
		$Quiz/Answers/C/AnswerLabel.text = round_data.answers[2]
		$Quiz/Answers/C.show()
	else:
		$Quiz/Answers/C.hide()
	if len(round_data.answers) >= 4:
		$Quiz/Answers/D/AnswerLabel.text = round_data.answers[3]
		$Quiz/Answers/D.show()
	else:
		$Quiz/Answers/D.hide()

	$Quiz/Answers/VoteIcon.self_modulate = Color.WHITE
	$Quiz/Answers/VoteIcon.show()
	$Quiz.show()

func on_round_end(data: Dictionary):
	print("Got round ending: %s" % [data])
	quizOn = false
	voted = false
	$RoundCounter.hide()
	$Quiz/Answers/VoteIcon.hide()
	if data.current_round == data.max_round:
		print("game ended!")
	else:
		start_next_round()
