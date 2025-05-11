class_name PopupUI extends Control

signal popup_closed

@export var text : RichTextLabel
@export var close_button : Button
static var prefab : PackedScene = preload("res://ui/popup.tscn")

static func show_popup(root : Node, text : String, button_text : String) -> PopupUI:
	var popup = prefab.instantiate()
	root.add_child(popup)
	popup.text.text = text
	popup.close_button.text = button_text

	return popup

func _on_button_pressed():
	popup_closed.emit()
	queue_free()
