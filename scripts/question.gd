class_name QuestionScene extends CanvasLayer

var quizOn: bool = false
var voted: bool = false
var countdown: float
var round_data: Dictionary = {}

func _ready():
	countdown = scene_manager.round_duration

	api.set_ws_response(on_server_api_got_ws_message)
	start_next_round()

func _process(delta: float):
	if quizOn:
		countdown -= delta
		if countdown < 0:
			countdown = 0
		$Countdown.text = str(floor(countdown))
		if !voted:
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
	$Countdown.hide()
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
	$Countdown.show()
	$RoundCounter.text = "Runde %d/%d (%s)" % [data.current_round, data.max_round, data.category.title]
	$RoundCounter.show()

	if data.question.type == 0:
		$Quiz/Question/Image.hide()
		$Quiz/Question/Label.text = data.question.text
		$Quiz/Question/Label.show()
	elif data.question.type == 1:
		$Quiz/Question/Label.hide()
		var img: Image = Image.new()
		var err: Error = img.load_png_from_buffer(data.question.text.to_utf8_buffer())
		if err != OK:
			print("img error ", err)
		print("img ", img)
			
		var imgtex: ImageTexture = ImageTexture.new()
		imgtex.set_image(img)
		print("imgtex ", imgtex)
		$Quiz/Question/Image.texture = imgtex
		$Quiz/Question/Image.show()

	if data.answers[0].type == 0:
		$Quiz/Answers/A/Image.hide()
		$Quiz/Answers/A/Label.text = data.answers[0].text
		$Quiz/Answers/A/Label.show()
	elif data.answers[0].type == 1:
		$Quiz/Answers/A/Label.hide()
		var img: Image = Image.new()
		img.load_png_from_buffer(data.question.text.to_utf8_buffer())
		$Quiz/Answers/A/Quiz/Answers/A/Image.Texture = ImageTexture.create_from_image(img)
		$Quiz/Answers/A/Image.show()
	if data.answers[1].type == 0:
		$Quiz/Answers/B/Image.hide()
		$Quiz/Answers/B/Label.text = data.answers[1].text
		$Quiz/Answers/B/Label.show()
	elif data.answers[1].type == 1:
		$Quiz/Answers/B/Label.hide()
		var img: Image = Image.new()
		img.load_png_from_buffer(data.question.text.to_utf8_buffer())
		$Quiz/Answers/B/Image.Texture = ImageTexture.create_from_image(img)
		$Quiz/Answers/B/Image.show()

	if len(data.answers) >= 3:
		if data.answers[2].type == 0:
			$Quiz/Answers/C/Image.hide()
			$Quiz/Answers/C/Label.text = data.answers[2].text
			$Quiz/Answers/C/Label.show()
		elif data.answers[2].type == 1:
			$Quiz/Answers/C/Label.hide()
			var img: Image = Image.new()
			img.load_png_from_buffer(data.question.text.to_utf8_buffer())
			$Quiz/Answers/C/Image.Texture = ImageTexture.create_from_image(img)
			$Quiz/Answers/C/Image.show()
		$Quiz/Answers/C.show()
	else:
		$Quiz/Answers/C.hide()
	if len(data.answers) >= 4:
		if data.answers[3].type == 0:
			$Quiz/Answers/D/Image.hide()
			$Quiz/Answers/D/Label.text = data.answers[3].text
			$Quiz/Answers/D/Label.show()
		elif data.answers[3].type == 1:
			$Quiz/Answers/D/Label.hide()
			var img: Image = Image.new()
			img.load_png_from_buffer(data.question.text.to_utf8_buffer())
			$Quiz/Answers/D/Image.Texture = ImageTexture.create_from_image(img)
			$Quiz/Answers/D/Image.show()
		$Quiz/Answers/D.show()
	else:
		$Quiz/Answers/D.hide()

	$Quiz/Answers/VoteIcon/Icon.self_modulate = Color.WHITE
	$Quiz/Answers/VoteIcon.show()
	$Quiz.show()

	scene_manager.update_discord("question", data)

func on_round_end(data: Dictionary):
	print("Got round_data ending: %s" % [data])
	quizOn = false
	voted = false
	$RoundCounter.hide()
	$Quiz/Answers/VoteIcon.hide()

	self.round_data = data
	if data.current_round == data.max_round:
		scene_manager.change_scene(self, "game_end")
	else:
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
