extends CanvasLayer

@export var scene_after_login: String

## on_email_text_changed is called when the user changed the text in the email input field. It is
## used to toggle the 'disabled' property of the Login button.
func on_email_text_changed(email_text: String):
	if email_text == ""||$LoginBox/Password.text == "":
		$LoginBox/Login.disabled = true
		return
	$LoginBox/Login.disabled = false

## on_password_text_changed is called when the user changed the text in the password input field. It
## is used to toggle the 'disabled' property of the Login button.
func on_password_text_changed(password_text: String):
	if password_text == ""||$LoginBox/EMail.text == "":
		$LoginBox/Login.disabled = true
		return
	$LoginBox/Login.disabled = false

## on_login_button_pressed is called when user pressed the login button on the screen.
func on_login_button_pressed():
	$LoginBox/Login.disabled = true
	var auth: String = Marshalls.utf8_to_base64("%s:%s" % [$LoginBox/EMail.text, $LoginBox/Password.text])
	api.login(auth, on_login_reponse)

## on_login_reponse is called as when the login api call completed.
func on_login_reponse(success: bool, _username: String=""):
	if !success:
		print("login failed!")
		$LoginBox/Login.disabled = false
		return

	scene_manager.change_scene(self, scene_after_login)
