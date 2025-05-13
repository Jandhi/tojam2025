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

var cant_place_on_right_side_dialogues = [
	"I can't place my minions on the right side of the battlefield!",
	"That's enemy territory!",
	"That's not my side!",
	"That's the enemy's side!",
	"That's not my side of the battlefield!",
]

var cannot_afford_dialogue = [
	"I can't afford that!",
	"It's too expensive!",
	"In this economy!?",
	"That's too much!",
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
		
		if unit.unit.is_female:
			AudioManager.play("mumble", 0.2, 1.0, false, 0.4)
		else:
			AudioManager.play("mumble", 0.2, 1.0, false, -0.1)

func minions_are_too_far_from_commander(unit) -> void:
	show_dialogue(units_are_too_far_from_commander_dialogues.pick_random(), unit, true)

func cannot_afford(unit) -> void:
	show_dialogue(cannot_afford_dialogue.pick_random(), unit)

func too_far_from_commander(unit) -> void:
	show_dialogue(too_far_from_commander_dialogues.pick_random(), unit)

func cant_place_on_right_side(unit) -> void:
	show_dialogue(cant_place_on_right_side_dialogues.pick_random(), unit)

func show_dialogue(text : String, unit, forced : bool = false) -> void:
	if time_since_last_popup < min_time_between_popups and not forced:
		return

	unit.talk_cooldown += 5.0
	time_since_last_popup = 0.0

	var current_dialogue = dialogue_popup.instantiate() as DialoguePopup
	unit.healthbar.add_child(current_dialogue)
	current_dialogue.set_text(text)
	current_dialogue.global_position = unit.healthbar.global_position + Vector2(30, -20)
	var position = current_dialogue.position

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
