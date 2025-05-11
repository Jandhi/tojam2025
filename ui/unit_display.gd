class_name UnitDisplay extends Control

@export var unit_name : RichTextLabel
@export var unit_type : RichTextLabel
@export var stats : RichTextLabel
@export var traits : RichTextLabel

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

	unit_name.text = "[b]" + unit.unit_name
	unit_type.text = "[i]" + unit.unit.unit_type
	stats.text = "Health: " + str(unit.health) + "/" + str(unit.unit.max_health) + ", "
	stats.text += "Melee Damage: " + str(unit.unit.melee_damage) + ", "
	if unit.unit.attack_range > 0:
		stats.text += "Ranged Damage: " + str(unit.unit.ranged_damage) + " with range " + str(unit.unit.attack_range) + ", "
	
	if unit.unit.armour > 0:
		stats.text += "Armour: " + str(unit.unit.armour) + ", "
	if unit.unit.resist > 0:
		stats.text += "Resist: " + str(unit.unit.resist) + ", "

	stats.text += "Morale: " + str(unit.morale) + "/10" + "\n"

	traits.text = ""

	for tag in unit.tags:
		if hidden_tags.has(tag):
			continue

		if traits.text != "":
			traits.text += ", "
		traits.text += "[i]" + tag.capitalize() + "[/i]"

	traits.text += "\n"

	for preference in unit.preferences:
		traits.text += preference.get_description() + "\n"
