class_name DialogueManager extends Node

static var instance : DialogueManager

signal show_dialogue_out_of_boredom

@export var dialogue_popup : PackedScene
var time_since_last_popup : float = 0.0
var min_time_between_popups : float = 2.0
var max_time_between_popups : float = 30.0

func _ready() -> void:
	instance = self
	
func _process(delta: float) -> void:
	time_since_last_popup += delta

	if time_since_last_popup > max_time_between_popups:
		time_since_last_popup = min_time_between_popups
		show_dialogue_out_of_boredom.emit()
		return

func show_dialogue(text : String, position : Vector2) -> void:
	if time_since_last_popup < min_time_between_popups:
		return

	time_since_last_popup = 0.0
	position += Vector2(0, -120) # vertical offset

	var current_dialogue = dialogue_popup.instantiate() as DialoguePopup
	add_child(current_dialogue)
	current_dialogue.set_text(text)
	current_dialogue.position = position

	var tween = get_tree().create_tween().set_parallel()
	# fade in
	current_dialogue.modulate = Color(1, 1, 1, 0)
	tween.tween_property(current_dialogue, "modulate:a", 1, 0.5)
	tween.tween_property(current_dialogue, "position", position + Vector2(0, -20), 0.5)

	await get_tree().create_timer(1.5).timeout

	# fade out
	var tween_out = get_tree().create_tween().set_parallel()
	tween_out.tween_property(current_dialogue, "modulate:a", 0, 0.5)
	tween_out.tween_property(current_dialogue, "position", position + Vector2(0, -40), 0.5)

	await tween_out.finished
	current_dialogue.queue_free()
