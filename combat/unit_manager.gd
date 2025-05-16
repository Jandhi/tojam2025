extends Node



var units = [
	preload("res://unit_data/battlesister.tscn"),
	preload("res://unit_data/battlesisterArcher.tscn"),
	preload("res://unit_data/bloodsister.tscn"),
	preload("res://unit_data/bloodSisterArcher.tscn"),
	preload("res://unit_data/brotherhood.tscn"),
	preload("res://unit_data/brotherhoodArcher.tscn"),
	preload("res://unit_data/churchman.tscn"),
	preload("res://unit_data/cultist.tscn"),

	preload("res://unit_data/hedgewitch.tscn"),
	preload("res://unit_data/imp.tscn"),
	preload("res://unit_data/night_court.tscn"),
	preload("res://unit_data/night_court_archer.tscn"),
	preload("res://unit_data/nun.tscn"),
	preload("res://unit_data/sellswordarcher.tscn"),
	preload("res://unit_data/sellswordm.tscn"),
	preload("res://unit_data/treeman.tscn"),
	preload("res://unit_data/troll.tscn"),
	preload("res://unit_data/zombie.tscn"),
	preload("res://unit_data/zombie.tscn"),
	preload("res://unit_data/skeleton.tscn"),
	preload("res://unit_data/skeletonArcher.tscn"),
	preload("res://unit_data/vampire.tscn"),
	preload("res://unit_data/knight.tscn"),
	preload("res://unit_data/boneMage.tscn"),
	preload("res://unit_data/succubus.tscn"),
]

var gold_units = [
	preload("res://unit_data/battlesister.tscn"),
	preload("res://unit_data/battlesisterArcher.tscn"),
	preload("res://unit_data/brotherhood.tscn"),
	preload("res://unit_data/brotherhoodArcher.tscn"),
	preload("res://unit_data/churchman.tscn"),
	preload("res://unit_data/sellswordarcher.tscn"),
	preload("res://unit_data/sellswordm.tscn"),
	preload("res://unit_data/skeleton.tscn"),
	preload("res://unit_data/skeletonArcher.tscn"),
	preload("res://unit_data/knight.tscn"),
]

func spawn_unit() -> UnitController:
	var unit_scene = [units, gold_units].pick_random().pick_random()
	var unit = unit_scene.instantiate()
	unit.grid_pos = Vector2i(0, 0)
	unit.set_process(true)
	unit.set_process_input(true)
	return unit
