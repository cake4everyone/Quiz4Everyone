extends Node2D

# set by main scene
var api_login: Callable

## on_login_button_pressed is called when user pressed the login button on the screen.
func on_login_button_pressed():
	var auth: String = Marshalls.utf8_to_base64("%s:%s" % [$EMail.text, $Password.text])
	api_login.call(auth)
