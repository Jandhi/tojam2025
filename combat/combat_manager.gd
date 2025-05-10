class_name CombatManager extends Node

@export var player_leader : UnitController
@export var grid : Grid
@export var selected_circle : SelectedCircle
@export var unit_display : UnitDisplay

var player_units : Array[UnitController] = []
var enemy_units : Array[UnitController] = []
var all_units : Array[UnitController] = []

var combat_is_playing : bool = false

const TICK_LENGTH = 0.5

func _ready() -> void:
	selected_circle.visible = false
	setup_units()

func play_combat():
	grid.add_units()
	var victory = true
	combat_is_playing = true

	for unit in player_units:
		unit.is_moveable = false
	
	while true:
		print("Tick")
		if player_leader.health <= 0:
			victory = false
			break
		
		if enemy_units.all(func(unit): return unit.health <= 0):
			break

		for unit in player_units:
			unit.tick()
			
		for unit in enemy_units:
			unit.tick()
			
		await get_tree().create_timer(TICK_LENGTH).timeout

	for unit in player_units:
		unit.animated_sprite.play("idle")
	for unit in enemy_units:
		unit.animated_sprite.play("idle")

	if victory:
		print("Victory!")
	else:
		print("Defeat!")

func setup_units():
	grid.add_units()

	for unit in all_units:
		unit.hovered.connect(func(): 
			hover_unit(unit)
		)
		unit.unhovered.connect(func(): 
			unhover_unit(unit)
		)
		unit.attempted_to_move_commander_to_roster.connect(func():
			DialogueManager.instance.show_dialogue("You can't move the commander to the roster!", unit.global_position)
		)

func hover_unit(unit: UnitController):
	selected_circle.reparent(unit)
	selected_circle.global_position = unit.global_position
	selected_circle.visible = true
	unit_display.set_unit(unit)

func unhover_unit(_unit: UnitController):
	selected_circle.reparent(grid)
	selected_circle.visible = false
	unit_display.set_unit(null)
