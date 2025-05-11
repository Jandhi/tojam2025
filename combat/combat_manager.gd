class_name CombatManager extends Node

@export var grid : Grid
@export var selected_circle : SelectedCircle
@export var unit_display : UnitDisplay
@export var dialogue_manager : DialogueManager

var player_leader : UnitController
var player_units : Array[UnitController] = []
var enemy_units : Array[UnitController] = []
var all_units : Array[UnitController] = []

var combat_is_playing : bool = false

var allowed_distance_from_leader : int = 2

const TICK_LENGTH = 0.5

func _ready() -> void:
	selected_circle.visible = false
	setup_units()

	dialogue_manager.show_dialogue_out_of_boredom.connect(func():
		if combat_is_playing:
			return
		
		var unit = player_units.pick_random()
		dialogue_manager.bored(unit)
	)

func play_combat():
	if combat_is_playing:
		return

	if player_units.any(func(unit): return grid.distance_to_commander(unit.grid_pos) > allowed_distance_from_leader):
		DialogueManager.instance.minions_are_too_far_from_commander(player_leader)
		return

	var victory = true
	combat_is_playing = true

	for unit in player_units:
		unit.force_reset_positions()
		unit.is_moveable = false
		unit.morale += unit.morale_modifier
		unit.morale_modifier = 0
	
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

			if unit.health <= 0:
				enemy_units.erase(unit)
				all_units.erase(unit)
				unit.queue_free()
			
		await get_tree().create_timer(TICK_LENGTH).timeout

	for unit in player_units:
		unit.animated_sprite.play("idle")
	for unit in enemy_units:
		unit.animated_sprite.play("idle")

	if victory:
		print("Victory!")
	else:
		print("Defeat!")

	combat_is_playing = false
	finished_battle()

func finished_battle():
	for unit in player_units:
		unit.heal(unit.unit.max_health)

		if not unit.is_in_roster:
			var grid_pos = unit.original_grid_position
			if unit.health <= 0:
				unit.appear(grid_pos)
			else:
				unit.teleport(grid_pos)

		unit.is_moveable = true


func setup_units():
	grid.add_units()

	for unit in all_units:
		setup_unit(unit)

func setup_unit(unit: UnitController):
	unit.hovered.connect(func(): 
		hover_unit(unit)
	)
	unit.unhovered.connect(func(): 
		unhover_unit(unit)
	)
	unit.attempted_to_move_commander_to_roster.connect(func():
		DialogueManager.instance.show_dialogue(DialogueManager.instance.cant_move_commander_to_roster_dialogues.pick_random(), unit)
	)
	unit.too_far_from_commander.connect(func():
		DialogueManager.instance.too_far_from_commander(unit)
	)

	if unit.is_player_commander:
		player_leader = unit

func hover_unit(unit: UnitController):
	selected_circle.reparent(unit)
	selected_circle.global_position = unit.global_position
	selected_circle.visible = true
	unit_display.set_unit(unit)

	for other in all_units:
		if other == unit:
			continue
		
		other.is_hovered = false


func unhover_unit(_unit: UnitController):
	selected_circle.reparent(grid)
	selected_circle.visible = false
	unit_display.set_unit(null)
