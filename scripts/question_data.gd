class_name QuestionData extends Node

var mediaDict: Dictionary = {}

func _init(data: Dictionary, root: CanvasLayer):
	print(data)
	root.find_child("RoundCounter").text = "Runde %d/%d (%s)" % [data.current_round, data.max_round, data.category.title]

	setLabel(root.find_child("Question"), data.question)
	setLabel(root.find_child("A"), data.answers[0])
	setLabel(root.find_child("B"), data.answers[1])
	if len(data.answers) >= 3:
		setLabel(root.find_child("C"), data.answers[2])
	else:
		setLabel(root.find_child("C"))
	if len(data.answers) >= 4:
		setLabel(root.find_child("D"), data.answers[3])
	else:
		setLabel(root.find_child("D"))

	if len(mediaDict) > 0:
		var media: String = mediaDict.keys()[0]
		api.round_media(media, on_round_media_response, mediaDict[media].size.x, mediaDict[media].size.y)

func setLabel(node: ColorRect, data: Dictionary = {}):
	if data == {}:
		node.hide()
		return

	var label: Label = node.find_child("Label", false)
	var image: TextureRect = node.find_child("Image", false)

	image.hide()

	if data.type == 0:
		label.text = data.text
		label.show()
	elif data.type == 1:
		label.hide()
		mediaDict[data.text] = image

func on_round_media_response(success: bool, media: String, data: PackedByteArray):
	if success:
		print("media ", media)
		var img: Image = Image.new()
		img.load_png_from_buffer(data)
		mediaDict[media].texture = ImageTexture.create_from_image(img)
		mediaDict[media].show()
	else:
		print("Faild to get media %s data: %s" % [media, data.get_string_from_ascii()])

	mediaDict.erase(media)
	if len(mediaDict) == 0:
		return

	var next_media: String = mediaDict.keys()[0]
	api.round_media(next_media, on_round_media_response, mediaDict[next_media].size.x, mediaDict[next_media].size.y)
