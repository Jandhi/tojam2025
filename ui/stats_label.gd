class_name StatsLabel extends HBoxContainer

@export var attack_texture : TextureRect
@export var attack_text : RichTextLabel
@export var health_text : RichTextLabel
@export var armour_texture : TextureRect
@export var armour_text : RichTextLabel


func set_unit(unit : Unit) -> void:
	var is_magic = unit.melee_is_magic
	var dmg = unit.melee_damage

	if unit.attack_range > 1:
		is_magic = unit.ranged_is_magic
		dmg = unit.ranged_damage
		attack_texture.texture = preload("res://textures/icons/magic.png") if is_magic else preload("res://textures/icons/ranged.png")
	else:
		attack_texture.texture = preload("res://textures/icons/magic.png") if is_magic else preload("res://textures/icons/melee.png")

	attack_text.text = str(dmg).substr(0, 2)
	health_text.text = str(unit.max_health).substr(0, 2)

	var armour_amt = unit.armour

	armour_texture.texture = preload("res://textures/icons/melee_armor.webp")

	if unit.resist > 0:
		armour_texture.texture = preload("res://textures/icons/magic_armor.webp")
		armour_amt = unit.resist

	armour_text.text = "0" if armour_amt == 0 else str(armour_amt).substr(0, 2)
	
