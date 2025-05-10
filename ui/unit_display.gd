class_name UnitDisplay extends Control

@export var unit_name : RichTextLabel
@export var unit_type : RichTextLabel
@export var unit_portrait : TextureRect
@export var stats : RichTextLabel
@export var traits : RichTextLabel

func _ready() -> void:
	set_unit(null)

func set_unit(unit : UnitController):
	if unit == null:
		unit_name.text = ""
		unit_type.text = ""
		unit_portrait.texture = null
		stats.text = ""
		traits.text = ""
		return

	unit_name.text = "[b]" + unit.unit_name
	unit_type.text = "[i]" + unit.unit.unit_type
	unit_portrait.texture = unit.unit.portrait
	stats.text = "Health: " + str(unit.health) + "/" + str(unit.unit.max_health) + "\n"
	
	if unit.unit.armour > 0:
		stats.text += "Armour: " + str(unit.unit.armour) + "\n"
	if unit.unit.resist > 0:
		stats.text += "Resist: " + str(unit.unit.resist) + "\n"
