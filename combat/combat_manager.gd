class_name CombatManager extends Node

@export var grid : Grid
@export var selected_circle : SelectedCircle
@export var unit_display : UnitDisplay
@export var dialogue_manager : DialogueManager
@export var shop_panel : ShopPanel
@export var roster : Grid
@export var main_menu : Control
@export var gold_label : RichTextLabel
@export var pacts_label : RichTextLabel

var player_leader : UnitController
var player_units : Array[UnitController] = []
var enemy_units : Array[UnitController] = []
var all_units : Array[UnitController] = []
var battle_number : int = 0
var pacts : int = 0
var gold : int = 0

var combat_is_playing : bool = false

var allowed_distance_from_leader : int = 2

const TICK_LENGTH = 0.2

func _ready() -> void:
	set_gold(0)
	set_pacts(0)
	AudioManager.play("menu_theme")

	selected_circle.visible = false
	setup_units()

	dialogue_manager.show_dialogue_out_of_boredom.connect(func():
		if combat_is_playing:
			return
		
		var unit = player_units.pick_random()
		dialogue_manager.bored(unit)
	)

func spawn_enemies():
	for i in range(battle_number + 1):
		var unit = UnitManager.spawn_unit()
		unit.swap_colors()
		grid.add_child(unit)
		add_unit_to_enemy(unit)

func add_unit_to_enemy(unit : UnitController):
	enemy_units.append(unit)
	all_units.append(unit)
	unit.grid = grid
	unit.is_player_unit = false
	unit.roster = roster
	unit.is_in_roster = false
	unit.is_in_store = false
	unit.is_moveable = false
	unit.reparent(grid)
	unit.teleport(grid.get_random_enemy_tile())

	setup_unit(unit)
	grid.tiles[unit.grid_pos] = unit
	grid.units.append(unit)

func add_unit_to_player(unit : UnitController):
	player_units.append(unit)
	all_units.append(unit)
	unit.grid = grid
	unit.roster = roster
	unit.is_in_roster = false
	unit.is_in_store = false
	unit.is_moveable = true
	unit.reparent(grid)
	unit.teleport(grid.get_random_player_tile())
	unit.original_grid_position = unit.grid_pos

	grid.tiles[unit.grid_pos] = unit
	grid.units.append(unit)

func cannot_afford():
	dialogue_manager.cannot_afford(player_leader)

func set_gold(amount: int):
	gold = amount
	gold_label.text = str(gold)

func set_pacts(amount: int):
	pacts = amount
	pacts_label.text = str(pacts)

func enter_game():

	var tween = get_tree().create_tween()
	tween.tween_property(main_menu, "position", main_menu.position + Vector2(0, -1080), 1.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_SPRING)

	await tween.finished
	show_roster()
	main_menu.queue_free()

	var popup = PopupUI.show_popup(get_tree().root, "[center]Welcome to the game!\nYou can move your units around the grid. Units want to be within 2 tiles of the mistress to start! This range will increase every 3 battles.\n\n Let's start with some shopping. I'll give you 3 gold and 2 pacts to start.", "I understand")
	popup.popup_closed.connect(func():
		AudioManager.play("loot")
		shop_panel.enter_shop()
		spawn_enemies()

		grid.set_placeable_tiles()
		set_gold(3)
		set_pacts(2)

		var inner_popup = PopupUI.show_popup(get_tree().root, "[center]Units will cost Gold or Pacts.\n\nUnits have preferences they want to abide by, else they lose morale and fight less effectively. Good luck!", "I understand")
		inner_popup.popup_closed.connect(func():
			pass
		)
	)

func get_reward_for_battle():
	AudioManager.play("loot")
	set_pacts(pacts + (battle_number % 2) * int((battle_number + 1) / 2.0))
	set_gold(gold + 2 + int(battle_number / 2.0))
	if(battle_number % 3 == 2):
		allowed_distance_from_leader += 1
		grid.set_placeable_tiles()

func hide_roster():
	var tween = get_tree().create_tween()
	tween.tween_property(roster, "position", Vector2(-400, 640), 1.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_SPRING)

func show_roster():
	var tween = get_tree().create_tween()
	tween.tween_property(roster, "position", Vector2(65, 640), 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SPRING)

func play_combat():

	if combat_is_playing:
		return

	if player_units.any(func(unit): return not unit.is_in_roster and grid.distance_to_commander(unit.grid_pos) > allowed_distance_from_leader):
		DialogueManager.instance.minions_are_too_far_from_commander(player_leader)
		return

	await shop_panel.exit_shop()
	grid.hide_placeable_tiles()
	
	hide_roster()
	AudioManager.play("battle_theme", 0.0, 1.0)
	
	var victory = true
	combat_is_playing = true

	for unit in player_units:
		unit.force_reset_positions()
		unit.is_moveable = false
		unit.morale = clamp(unit.morale +  unit.morale_modifier, 0, 2)
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
		AudioManager.play("victory", 0.0, 1.0, true)
		finished_battle()

	else:
		print("Defeat!")
		AudioManager.play("loss", 0.0, 1.0, true)
		
		var game_over = load("res://ui/game_over.tscn").instantiate()
		game_over.set_days(battle_number)
		get_parent().add_child(game_over)

	combat_is_playing = false
	

func finished_battle():
	grid.set_placeable_tiles()

	for unit in player_units:
		unit.morale += unit.morale_modifier

		

		unit.heal(unit.unit.max_health)
		unit.visible = true
		unit.modulate = Color(1, 1, 1, 1)

		if not unit.is_in_roster:
			var grid_pos = unit.original_grid_position
			if unit.health <= 0:
				unit.appear(grid_pos)
			else:
				unit.teleport(grid_pos)

		unit.is_moveable = true

	for unit in player_units:
		if unit.morale == 0:
			unit.leave(self)
			continue
	
		unit.check_preferences()
	
	await get_tree().create_timer(2.0).timeout
	get_reward_for_battle()
	AudioManager.play("shop_theme")
	spawn_enemies()
	shop_panel.enter_shop()
	show_roster()
	battle_number += 1


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
	unit.attempted_to_place_on_right_side.connect(func():
		DialogueManager.instance.cant_place_on_right_side(player_leader)
	)

	if unit.is_player_commander:
		player_leader = unit

func hover_unit(unit: UnitController):
	if not is_instance_valid(unit):
		return

	selected_circle.reparent(unit)
	selected_circle.global_position = unit.global_position
	selected_circle.visible = true
	unit_display.set_unit(unit)

	for other in all_units:
		if other == unit:
			continue
		
		if other.is_hovered and not other.is_clicked:
			other.is_hovered = false
			other.dropped()
		


func unhover_unit(_unit: UnitController):
	selected_circle.reparent(grid)
	selected_circle.visible = false
	unit_display.set_unit(null)
