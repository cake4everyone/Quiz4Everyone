extends Node2D
signal game_start
signal get_categories

# Called when the node enters the scene tree for the first time.
func _ready():
	$dd_mode.add_item("Streamer VS Chat", 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func on_main_start_setup():
	self.show()
	get_categories.emit()

# Called when the server responded with the dictionary of get_categories.
func on_server_api_got_categories(categories: Dictionary):
	for category in categories:
		var c: HBoxContainer = $copy_category.duplicate()
		c.get_child(0).max_value = categories[category]
		c.get_child(1).text = category
		c.show()
		$category_box/categories.add_child(c)

# Called when pressed the start game button.
# It collects all the selected categories and creates a new game on the server.
func on_btn_start_pressed():
	var categories: Dictionary = {}
	for category: HBoxContainer in $category_box/categories.get_children():
		var amount: int = category.get_child(0).value
		if amount == 0:
			continue
		categories[category.get_child(1).text] = amount

	var game_data: Dictionary = {}
	game_data["categories"] = categories
	game_data["round_duration"] = 30 # time for each round in seconds
	game_start.emit(JSON.stringify(game_data))
