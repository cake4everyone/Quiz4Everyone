extends Node2D

signal login


func _on_login_button_pressed():
	var auth = Marshalls.utf8_to_base64($Input/EMail.text + ":" + $Input/Password.text)
	login.emit(auth)

