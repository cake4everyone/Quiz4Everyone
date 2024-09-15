class_name Menu extends CanvasLayer

## Time for each round in seconds
var round_duration: int
const CATEGORY = preload("res://scenes/components/copy_category.tscn")

## ready is called when the node enters the scene tree for the first time.
func _ready():
	$CreationMenu/ModeSelect.add_item("Streamer VS Chat", 0)
	if (scene_manager.round_duration > 0):
		round_duration = scene_manager.round_duration
		$CreationMenu/RoundDuration.value = round_duration
	api.category(on_category_response)

	var category_tree: Tree = $CreationMenu/CategoryBox
	category_tree.create_item()
	category_tree.set_column_title(0, "Category")
	category_tree.set_column_title(1, "Amount")
	category_tree.set_column_expand(1, false)
	category_tree.set_column_custom_minimum_width(1, 100)

## on_category_response is called as when the categories api call completed.
func on_category_response(success: bool, categories: Dictionary = {}):
	if !success:
		print("failed to get categories!")
		return
	update_category_list(categories)

## update_category_list updates the category selection list with the given dictionary (mapping String to int).
func update_category_list(groups: Dictionary):
	var category_tree: Tree = $CreationMenu/CategoryBox
	var tree_root: TreeItem = category_tree.get_root()
	print(groups)
	for group_color in groups:
		var group: Dictionary = groups[group_color]
		var tree_group: TreeItem = category_tree.create_item(tree_root)
		tree_group.set_text(0, group.title)
		tree_group.set_custom_bg_color(0, Color(0.23, 0.23, 0.23))
		tree_group.set_custom_bg_color(1, Color(0.23, 0.23, 0.23))
		var bg_light: bool = false
		for cat in group.categories:
			var category: TreeItem = category_tree.create_item(tree_group)
			category.set_text(0, cat.title)
			category.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
			category.set_range_config(1, 0, cat.count, 1)
			category.set_editable(1, true)
			if bg_light:
				category.set_custom_bg_color(0, Color(0.15, 0.15, 0.15))
				category.set_custom_bg_color(1, Color(0.15, 0.15, 0.15))
			else:
				category.set_custom_bg_color(0, Color(0.05, 0.05, 0.05))
				category.set_custom_bg_color(1, Color(0.05, 0.05, 0.05))
			bg_light = !bg_light

			var category_data: CategoryData = CategoryData.new()
			category_data.id = cat.id
			category_data.group = group.id
			category.set_metadata(0, category_data)

## on_btn_start_pressed is called when pressed the start game button.
## It collects all the selected categories and creates a new game on the server.
func on_btn_start_pressed():
	$CreationMenu/Start.disabled = true
	round_duration = $CreationMenu/RoundDuration.value
	var groups: Dictionary = {}
	var category: TreeItem = $CreationMenu/CategoryBox.get_root().get_first_child()
	while category != null:
		var amount: int = int(category.get_range(1))
		if amount == 0:
			category = category.get_next_in_tree()
			continue
		var category_data: CategoryData = category.get_metadata(0)

		var group_data: Dictionary = {}
		if groups.has(category_data.group):
			group_data = groups[category_data.group]
		var categories: Dictionary = {}
		if group_data.has("categories"):
			categories = group_data["categories"]

		categories[category_data.id] = amount
		group_data["categories"] = categories
		groups[category_data.group] = group_data
		category = category.get_next_in_tree()

	if groups.size() == 0:
		print("no categories selected!")
		return

	var game_data: Dictionary = {}
	game_data["groups"] = groups
	game_data["round_duration"] = round_duration
	print(game_data)
	api.game_start(JSON.stringify(game_data), on_game_start_response)

func on_cancel_pressed():
	$CreationMenu.hide()

func on_game_start_response(success: bool):
	if !success:
		print("failed to create new game!")
		$CreationMenu/Start.disabled = false
		return
	scene_manager.change_scene(self, "question")

func on_play_pressed():
	$CreationMenu.show()

func on_quit_pressed():
	get_tree().quit()

class CategoryData:
	var id: String
	var group: String
