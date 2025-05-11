extends Node

var bloodsister = preload("res://unit_data/bloodsister.tscn")
var brotherhood = preload("res://unit_data/brotherhood.tscn")
var churchman = preload("res://unit_data/churchman.tscn")
var cultist = preload("res://unit_data/cultist.tscn")
var hedgewitch = preload("res://unit_data/hedgewitch.tscn")
var night_court_archer = preload("res://unit_data/night_court_archer.tscn")
var nun = preload("res://unit_data/nun.tscn")
var sellswordf = preload("res://unit_data/sellswordf.tscn")
var sellswordm = preload("res://unit_data/sellswordm.tscn")
var zombie = preload("res://unit_data/zombie.tscn")

var units = [
	bloodsister,
	brotherhood,
	churchman,
	cultist,
	hedgewitch,
	night_court_archer,
	nun,
	sellswordf,
	sellswordm,
	zombie
]

func spawn_unit() -> UnitController:
	var unit_scene = units[randi() % units.size()]
	var unit = unit_scene.instantiate()
	unit.name = unit_scene.name
	unit.is_player_unit = true
	unit.grid_pos = Vector2i(0, 0)
	unit.set_process(true)
	unit.set_process_input(true)
	return unit