extends VBoxContainer

signal enter_game
var pressed = false

func _on_button_pressed():
	if pressed:
		return

	pressed = true
	enter_game.emit()
