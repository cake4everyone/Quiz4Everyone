extends Node2D
signal game_start

# Called when the node enters the scene tree for the first time.
func _ready():
	$dd_mode.add_item("Streamer VS Chat", 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func on_main_start_setup():
	self.show()

func on_btn_start_pressed():
	var body = """{
		"categories": {
			"testcookie": 5
		},
		"round_duration": 30
	}"""
	game_start.emit(body)
