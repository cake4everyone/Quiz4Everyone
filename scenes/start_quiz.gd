extends Node2D
signal start

# Called when the node enters the scene tree for the first time.
func _ready():
	$dd_mode.add_item("Streamer VS Chat", 0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_main_start_setup():
	self.show()
	

func _on_btn_start_pressed():
	pass
