extends Node2D
var start_game: Callable

## ready is called when the node enters the scene tree for the first time.
func _ready():
	$dd_mode.add_item("Streamer VS Chat", 0)

## process is called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

## update_category_list updates the category selection list with the given dictionary (mapping String to int).
func update_category_list(categories: Dictionary):
	for category in categories:
		var c: HBoxContainer = $copy_category.duplicate()
		c.get_child(0).max_value = categories[category]
		c.get_child(1).text = category
		c.show()
		$category_box/categories.add_child(c)

## on_btn_start_pressed  is called when pressed the start game button.
## It collects all the selected categories and creates a new game on the server.
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
	start_game.call(JSON.stringify(game_data))
