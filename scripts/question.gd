class_name QuestionScene extends CanvasLayer

var quizOn: bool = false
var voted: bool = false
var round_data: Dictionary = {}

func _ready():
	api.set_ws_response(on_server_api_got_ws_message)
	start_next_round()

func _process(_delta: float):
	if quizOn&&!voted:
		check_vote()

func check_vote():
	if Input.is_key_pressed(KEY_A)||Input.is_key_pressed(KEY_1)||Input.is_key_pressed(KEY_KP_1): api.streamervote("1", on_streamervote_response)
	elif Input.is_key_pressed(KEY_B)||Input.is_key_pressed(KEY_2)||Input.is_key_pressed(KEY_KP_2): api.streamervote("2", on_streamervote_response)
	elif Input.is_key_pressed(KEY_C)||Input.is_key_pressed(KEY_3)||Input.is_key_pressed(KEY_KP_3): api.streamervote("3", on_streamervote_response)
	elif Input.is_key_pressed(KEY_D)||Input.is_key_pressed(KEY_4)||Input.is_key_pressed(KEY_KP_4): api.streamervote("4", on_streamervote_response)
	else: return
	voted = true
	$Quiz/Answers/VoteIcon/Icon.self_modulate = Color.ORANGE

func on_streamervote_response(ok: bool):
	if ok:
		print("You have voted!")
		$Quiz/Answers/VoteIcon/Icon.self_modulate = Color.GREEN
	else:
		print("vote wasnt valid")
		$Quiz/Answers/VoteIcon/Icon.self_modulate = Color.WHITE
	voted = ok

## start_next_round shows a 3 second countdown before showing the round_data data.
func start_next_round():
	$Quiz.hide()
	$RoundCounter.hide()
	voted = false
	$StartCountdown.show()
	$StartCountdown.text = "3"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "2"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.text = "1"
	await get_tree().create_timer(1.0).timeout
	$StartCountdown.hide()
	api.round_next(on_round_next_response)
	quizOn = true

func on_round_next_response(success: bool, data: Dictionary={}):
	if !success:
		print("Faild to get next data!")
		return
	show_round_data(data)

## show_round_data displays the given round_data data on screen.
func show_round_data(data: Dictionary):
	print(data)
	$RoundCounter.text = "Runde %d/%d (%s)" % [data.current_round, data.max_round, data.category]
	$RoundCounter.show()

	$Quiz/Question/Label.text = data.question
	$Quiz/Answers/A/Label.text = data.answers[0]
	$Quiz/Answers/B/Label.text = data.answers[1]
	if len(data.answers) >= 3:
		$Quiz/Answers/C/Label.text = data.answers[2]
		$Quiz/Answers/C.show()
	else:
		$Quiz/Answers/C.hide()
	if len(data.answers) >= 4:
		$Quiz/Answers/D/Label.text = data.answers[3]
		$Quiz/Answers/D.show()
	else:
		$Quiz/Answers/D.hide()

	$Quiz/Answers/VoteIcon/Icon.self_modulate = Color.WHITE
	$Quiz/Answers/VoteIcon.show()
	$Quiz.show()

func on_round_end(data: Dictionary):
	print("Got round_data ending: %s" % [data])
	quizOn = false
	voted = false
	$RoundCounter.hide()
	$Quiz/Answers/VoteIcon.hide()
	if data.current_round == data.max_round:
		print("game ended!")
	else:
		self.round_data = data
		scene_manager.change_scene(self, "question_end")

const CHAT_VOTE: String = "CHAT_VOTE"
const ROUND_END: String = "ROUND_END"

func on_server_api_got_ws_message(msg: Dictionary):
	match msg.type:
		CHAT_VOTE:
			print("Got chat vote: %s" % [msg])
		ROUND_END:
			on_round_end(msg)
		_:
			print("Got unkown ws message type: '%s': %s" % [msg.type, msg])
