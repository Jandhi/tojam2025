class_name CombatManager extends Node

@export var player_leader : UnitController
var player_units : Array[UnitController] = []
var enemy_units : Array[UnitController] = []
@export var grid : Grid

const TICK_LENGTH = 0.5

func play_combat():
	grid.add_units()
	print(grid.units)
	
	var victory = true
	
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
