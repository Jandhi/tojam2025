class_name UnitDisplay extends Control

@export var unit_name : ScaleDownTextToFit
@export var unit_type : RichTextLabel
@export var stats : RichTextLabel
@export var traits : RichTextLabel
@export var morale : RichTextLabel

var italic_font = preload("res://fonts/PTSerif-Italic.ttf")
var bold_font = preload("res://fonts/PTSerif-Bold.ttf")

var hidden_tags = [
	"in_roster",
]

func _ready() -> void:
	set_unit(null)

func set_unit(unit : UnitController):
	if unit == null:
		visible = false
		return

	visible = true

	unit_name.set_text_scaled("[b]" + unit.unit_name)
	
	unit_type.text = italicize_text(unit.unit.unit_type.capitalize())

	for tag in unit.tags:
		if hidden_tags.has(tag):
			continue

		unit_type.text += italicize_text(", " + tag.capitalize())

	stats.text = "Health: " + str(unit.health) + "/" + str(unit.unit.max_health) + ", "
	stats.text += "Melee Damage: " + str(unit.unit.melee_damage) + ", "
	if unit.unit.attack_range > 0:
		stats.text += "Ranged Damage: " + str(unit.unit.ranged_damage) + " with range " + str(unit.unit.attack_range) + ", "
	
	if unit.unit.armour > 0:
		stats.text += "Armour: " + str(unit.unit.armour) + ", "
	if unit.unit.resist > 0:
		stats.text += "Resist: " + str(unit.unit.resist) + ", "

	var morale_descriptor = ""

	match unit.morale + unit.morale_modifier:
		0:
			morale_descriptor = "[shake]Fuming[/shake] (will desert at end of battle)"
		1:
			morale_descriptor = "Angry"
		2:
			morale_descriptor = "Happy"

	morale.text = color_text_pink(bold_text("Morale:")) + " " + morale_descriptor 

	traits.text = "Traits:\n"

	for preference in unit.preferences:
		var preference_text = preference.get_description()

		var parts = preference_text.split(":")
		var preference_name = parts[0]
		var preference_value = parts[1]

		traits.text += color_text_pink(bold_text(preference_name + ":")) + preference_value + "\n"

func italicize_text(text : String) -> String:
	return "[font=" + italic_font.resource_path + "]" + text + "[/font]"

func bold_text(text : String) -> String:
	return "[font=" + bold_font.resource_path + "]" + text + "[/font]"

func color_text_pink(text : String) -> String:
	return "[color=#d70053]" + text + "[/color]"
