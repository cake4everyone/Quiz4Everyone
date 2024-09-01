class_name Menu extends CanvasLayer

## Time for each round in seconds
var round_duration: int
const CATEGORY = preload("res://scenes/components/copy_category.tscn")

## ready is called when the node enters the scene tree for the first time.
func _ready():
	$RoundCreation/CreationMenu/ModeSelect.add_item("Streamer VS Chat", 0)
	if (scene_manager.round_duration > 0):
		round_duration = scene_manager.round_duration
		$RoundCreation/CreationMenu/RoundDuration.value = round_duration
	api.category(on_category_response)

## on_category_response is called as when the categories api call completed.
func on_category_response(success: bool, categories: Dictionary={}):
	if !success:
		print("failed to get categories!")
		return
	update_category_list(categories)

## update_category_list updates the category selection list with the given dictionary (mapping String to int).
func update_category_list(categories: Dictionary):
	for category in categories:
		var c = CATEGORY.instantiate()
		c.get_child(1).max_value = categories[category]
		c.get_child(2).text = category
		c.show()
		$RoundCreation/CreationMenu/CategoryBox/Categories.add_child(c)

## on_btn_start_pressed is called when pressed the start game button.
## It collects all the selected categories and creates a new game on the server.
func on_btn_start_pressed():
	$RoundCreation/CreationMenu/Start.disabled = true
	round_duration = $RoundCreation/CreationMenu/RoundDuration.value
	var categories: Dictionary = {}
	for category: HBoxContainer in $RoundCreation/CreationMenu/CategoryBox/Categories.get_children():
		var amount: int = category.get_child(1).value
		if amount == 0:
			continue
		categories[category.get_child(2).text] = amount

	var game_data: Dictionary = {}
	game_data["categories"] = categories
	game_data["round_duration"] = round_duration
	api.game_start(JSON.stringify(game_data), on_game_start_response)

func on_cancel_pressed():
	$RoundCreation.hide()

func on_game_start_response(success: bool):
	if !success:
		print("failed to create new game!")
		$RoundCreation/CreationMenu/Start.disabled = false
		return
	scene_manager.change_scene(self, "question")

func on_play_pressed():
	$RoundCreation.show()

func on_quit_pressed():
	get_tree().quit()
