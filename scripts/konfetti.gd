extends Control

func shoot(player_won):
	if(player_won):
		modulate = Color("ac4912")
	else:
		modulate = Color("6441a4")

	print("\n Hallooooooooooo")
	$canon1.emitting = true
	$canon2.emitting = true
