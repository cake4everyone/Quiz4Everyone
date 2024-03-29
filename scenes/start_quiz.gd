extends Node2D
signal start

# Called when the node enters the scene tree for the first time.
func _ready():
	$dd_mode.add_item("Select Modi", 0)
	$dd_mode.add_item("Streamer VS Chat", 1)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_start_setup():
	$HTTP_Requests/HTTP_GameStart.request_completed.connect(_start_game_res)
	$HTTP_Requests/HTTP_GameInfo.request_completed.connect(_info_game_res)
	

func _start_game_res():
	pass

func _info_game_res():
	pass

func _quit_game_res():
	pass
	


func _on_dd_mode_item_selected(index):
	print(index)
	if(index != 0):
		$dd_mode.remove_item(0)
