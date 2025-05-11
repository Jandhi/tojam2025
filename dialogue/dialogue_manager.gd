class_name DialogueManager extends Node

static var instance : DialogueManager

signal show_dialogue_out_of_boredom

@export var dialogue_popup : PackedScene
var time_since_last_popup : float = 0.0
var min_time_between_popups : float = 2.0
var max_time_between_popups : float = 10.0

var cant_move_commander_to_roster_dialogues = [
	"I must command my minions!",
	"I cannot leave my minions behind!",
]

var units_are_too_far_from_commander_dialogues = [
	"My minions are too far away!",
]

var random_dialogue_by_tag : Dictionary[String, Array] = {
	"human" : [
		"Let's fight already!",
		"Why are we waiting?",
	],
	
	"elf" : [
		"My ears are so pointy!",
	],

	"in_roster" : [
		"Time to put my feet up!"
	]
}

var too_far_from_commander_dialogues = [
	"Commander, I'm too far away!",
	"Commander, I can't hear you!",
]

func _ready() -> void:
	instance = self
	
func _process(delta: float) -> void:
	time_since_last_popup += delta

	if time_since_last_popup > max_time_between_popups:
		time_since_last_popup = min_time_between_popups
		show_dialogue_out_of_boredom.emit()
		return

func bored(unit) -> void:
	if unit.tags.size() == 0:
		return

	var tag = unit.tags.pick_random()
	if tag in random_dialogue_by_tag:
		var dialogue = random_dialogue_by_tag[tag].pick_random()
		show_dialogue(dialogue, unit)

func minions_are_too_far_from_commander(unit) -> void:
	show_dialogue(units_are_too_far_from_commander_dialogues.pick_random(), unit, true)

func too_far_from_commander(unit) -> void:
	show_dialogue(too_far_from_commander_dialogues.pick_random(), unit)

func show_dialogue(text : String, unit, forced : bool = false) -> void:
	if time_since_last_popup < min_time_between_popups and not forced:
		return

	unit.talk_cooldown += 5.0
	var position = unit.global_position

	time_since_last_popup = 0.0
	position += Vector2(0, -100) # vertical offset

	var current_dialogue = dialogue_popup.instantiate() as DialoguePopup
	add_child(current_dialogue)
	current_dialogue.set_text(text)
	current_dialogue.position = position

	var tween = get_tree().create_tween().set_parallel()
	# fade in
	current_dialogue.modulate = Color(1, 1, 1, 0)
	tween.tween_property(current_dialogue, "modulate:a", 1, 0.2)
	tween.tween_property(current_dialogue, "position", position + Vector2(0, -20), 0.2)

	await get_tree().create_timer(1.5).timeout

	# fade out
	var tween_out = get_tree().create_tween().set_parallel()
	tween_out.tween_property(current_dialogue, "modulate:a", 0, 0.2)
	tween_out.tween_property(current_dialogue, "position", position + Vector2(0, -40), 0.2)

	await tween_out.finished
	current_dialogue.queue_free()
