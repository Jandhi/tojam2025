extends VBoxContainer

@export var x_days : RichTextLabel

func _ready():
	self.modulate.a = 0

	# Fade in
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 2.0)

func set_days(days : int):
	x_days.text = "[center]" + str(days) + " days survived"

func _on_button_pressed():
	AudioManager.players.clear()
	get_tree().change_scene_to_packed(preload("res://game.tscn"))
