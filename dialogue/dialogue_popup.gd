class_name DialoguePopup extends Control

@export var text : ScaleDownTextToFit

func set_text(text : String) -> void:
	self.text.set_text_scaled("[center]" + text + "[/center]")