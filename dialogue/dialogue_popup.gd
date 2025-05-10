class_name DialoguePopup extends Control

@export var text : RichTextLabel

func set_text(text : String) -> void:
	self.text.text = "[center]" + text