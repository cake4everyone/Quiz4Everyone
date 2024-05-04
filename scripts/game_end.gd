extends CanvasLayer

func _ready():
	show_round_data(scene_manager.round_data)

## show_round_data displays the given round_data data on screen.
func show_round_data(data: Dictionary):
	print(data)
	$RoundCounter.text = "Runde %d/%d (%s)" % [data.current_round, data.max_round, data.category]

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
	var answer: ColorRect = $Quiz/Answers.get_child(data.correct - 1)
	answer.color = Color.hex(0x004200ff)

	$StreamerAnswer.color = Color.hex(0x004200ff) if data.streamer_vote == data.correct else Color.hex(0x780000ff)
	$StreamerAnswer/Label.text = "You voted %s" % [String.chr(65 + data.streamer_vote - 1)]

	var total_votes: int = data.chat_vote_count[0] + data.chat_vote_count[1] + data.chat_vote_count[2] + data.chat_vote_count[3]

	$ChatVotes.size.x = len(data.answers) * 100
	for i in range(len(data.answers)):
		var vote: VBoxContainer = VBoxContainer.new()
		vote.alignment = BoxContainer.ALIGNMENT_END
		vote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var bar: ProgressBar = ProgressBar.new()
		bar.max_value = total_votes if total_votes != 0 else 1
		bar.value = data.chat_vote_count[i]
		bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
		bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vote.add_child(bar)
		
		var label: Label = Label.new()
		label.text = String.chr(65 + i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		vote.add_child(label)

		$ChatVotes/Background/Graphs.add_child(vote)
	
	$Points/Graph/StreamerPoints.size_flags_stretch_ratio = data.streamer_points if data.streamer_points != data.chat_points else 1
	$Points/Graph/StreamerPoints/Label.text = str(data.streamer_points)
	$Points/Graph/ChatPoints.size_flags_stretch_ratio = data.chat_points if data.streamer_points != data.chat_points else 1
	$Points/Graph/ChatPoints/Label.text = str(data.chat_points)

## on_next_pressed is called when the user clicks the next button to continue to the next question.
func on_next_pressed():
	scene_manager.change_scene(self, "menu")
