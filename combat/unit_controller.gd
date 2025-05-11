class_name UnitController extends Node2D

signal hovered
signal unhovered
signal attempted_to_move_commander_to_roster
signal too_far_from_commander
signal attempted_to_place_on_right_side

@export var unit_name : String
@export var unit : Unit
@export var tags : Array[String] = []
@export var preferences : Array[PlacementPreference] = []
@export var grid_pos : Vector2i
@export var is_player_unit : bool = true
@export var is_player_commander : bool = false
@export var grid : Grid
@export var roster : Grid
@export var animated_sprite : AnimatedSprite2D
@export var hover_box : Control
@export var arrow_prefab : PackedScene

@export_group("Healthbar")
@export var healthbar : Control
@export var healthbar_white : ColorRect
@export var healthbar_red : ColorRect

var cooldown : int = 0
var talk_cooldown : float = 0
var health : int = 0
var just_moved : bool = false
var is_hovered : bool = false
var is_clicked : bool = false
var is_moveable : bool = true
var is_in_roster : bool = false
var is_in_store : bool = false
var was_dragged : bool = false
var movement_tween : Tween = null
var pickup_tween : Tween = null
var morale_modifier : int = 0
var morale : int = 10
var level : int = 1
var base_animated_sprite_position : Vector2 = Vector2(0, 0)
var base_healthbar_position : Vector2 = Vector2(0, 0)
var original_grid_position : Vector2i = Vector2i(0, 0)

func _ready():
	base_animated_sprite_position = animated_sprite.position
	base_healthbar_position = healthbar.position
	hover_box.mouse_entered.connect(func():
		if health <= 0:
			return
		is_hovered = true
		hovered.emit()
	)
	hover_box.mouse_exited.connect(func():
		if is_clicked:
			return

		is_hovered = false
		unhovered.emit()
	)

	if grid != null:
		grid_pos = grid.world_to_grid(self.position)
		original_grid_position = grid_pos
		grid.tiles[grid_pos] = self
		grid.units.append(self)
		position = grid.grid_to_world(grid_pos)
		z_index = grid_pos.y

	set_unit(unit)

	if not is_player_unit:
		animated_sprite.flip_h = true
		animated_sprite.self_modulate = Color(1, 0.5, 0.5)
		is_moveable = false

func _process(delta: float) -> void:
	talk_cooldown = clamp(talk_cooldown - delta, 0, INF)

func force_reset_positions():
	animated_sprite.position = base_animated_sprite_position
	healthbar.position = base_healthbar_position

func dropped():
	

	if pickup_tween != null:
		pickup_tween.stop()
	pickup_tween = get_tree().create_tween().set_parallel()
	pickup_tween.tween_property(animated_sprite, "position", base_animated_sprite_position, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	pickup_tween.tween_property(healthbar, "position", base_healthbar_position, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	was_dragged = false

	if not is_in_roster and grid.distance_to_commander(grid_pos) > grid.combat_manager.allowed_distance_from_leader:
		too_far_from_commander.emit()

	var complains = check_preferences()

	for neighbour in grid.get_neighbours(grid_pos):
		if not grid.tiles.has(neighbour):
			continue

		grid.tiles[neighbour].check_preferences()
	
	if not complains:
		if unit.is_female:
			AudioManager.play("grunt", 0.2, 1.0, false, 0.4)
		else:
			AudioManager.play("grunt", 0.2, 1.0, false, -0.1)

func check_preferences() -> bool:
	var preferences_list = []
	var complains = false
	
	for preference in preferences:
		preferences_list.append(preference)
	
	preferences_list.shuffle()

	var complaint = ""

	morale_modifier = 0

	for preference in preferences_list:
		if not preference.evaluate_fulfilled(self, grid, grid.combat_manager):
			morale_modifier -= 1

			if complaint == "":
				complains = true
				complaint = preference.get_complaint()

	if complaint != "" and talk_cooldown <= 0:
		DialogueManager.instance.show_dialogue(complaint, self)
		if unit.is_female:
			AudioManager.play("mumble", 0.2, 1.0, false, 0.4)
		else:
			AudioManager.play("mumble", 0.2, 1.0, false, -0.1)

	# Update morale on screen
	if is_hovered:
		hovered.emit()

	return complains

func set_unit(new_unit: Unit):
	self.unit = new_unit
	self.unit_name = new_unit.generate_name()
	health = new_unit.max_health
	
	for tag in new_unit.tags:
		tags.append(tag)

	for preference in new_unit.preferences:
		preferences.append(preference)

func _input(event: InputEvent) -> void:
	if not is_moveable:
		return

	# If the mouse is down, drag
	if event is InputEventMouseButton:
		if event.is_pressed() and is_hovered:
			is_clicked = true
			if pickup_tween != null:
				pickup_tween.stop()
			pickup_tween = get_tree().create_tween().set_parallel()
			pickup_tween.tween_property(animated_sprite, "position", base_animated_sprite_position + Vector2(0, -50), 0.1)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)
			pickup_tween.tween_property(healthbar, "position", base_healthbar_position + Vector2(0, -50), 0.1)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)

		if event.is_released():
			is_clicked = false

			if is_hovered:
				dropped()
	
	if event is InputEventMouseMotion and is_clicked:
		var new_location = grid.world_to_grid(event.position - grid.position + Vector2(30, 50))

		if not grid.is_in_bounds(new_location):
			# moving to roster
			new_location = roster.world_to_grid(event.position - roster.position + Vector2(30, 50))

			if not roster.is_in_bounds(new_location):
				return

			if roster.tiles.has(new_location):
				return

			if is_player_commander:
				attempted_to_move_commander_to_roster.emit()
				return

			if movement_tween != null:
				movement_tween.stop()


			if is_in_roster:
				roster.tiles.erase(grid_pos)
				grid_pos = new_location
				original_grid_position = grid_pos
				roster.tiles[grid_pos] = self
				z_index = grid_pos.y
				movement_tween = get_tree().create_tween()
				movement_tween.tween_property(self, "position", roster.grid_to_world(grid_pos), 0.2)
				was_dragged = true
			else:
				var old_location = grid_pos
				grid.tiles.erase(grid_pos)
				grid_pos = new_location
				original_grid_position = grid_pos
				roster.tiles[grid_pos] = self
				reparent(roster, true)
				z_index = grid_pos.y
				movement_tween = get_tree().create_tween()
				movement_tween.tween_property(self, "position", roster.grid_to_world(grid_pos), 0.2)
				is_in_roster = true
				tags.append("in_roster")

				if not was_dragged:
					for neighbour in grid.get_neighbours(old_location):
						if not grid.tiles.has(neighbour):
							continue

						grid.tiles[neighbour].check_preferences()

				was_dragged = true

			
			return

		if new_location == grid_pos:
			return

		if grid.tiles.has(new_location):
			return

		if new_location.x >= grid.grid_size.x / 2.0:
			attempted_to_place_on_right_side.emit()
			return

		if movement_tween != null:
			movement_tween.stop()
		
		if is_in_roster:
			roster.tiles.erase(grid_pos)
			grid_pos = new_location
			original_grid_position = grid_pos
			grid.tiles[grid_pos] = self
			reparent(grid)
			is_in_roster = false
			tags.erase("in_roster")
			z_index = grid_pos.y
			movement_tween = get_tree().create_tween()
			movement_tween.tween_property(self, "position", grid.grid_to_world(grid_pos), 0.2)
			was_dragged = true
		else:
			var old_location = grid_pos
			grid.tiles.erase(grid_pos)
			grid_pos = new_location
			original_grid_position = grid_pos
			grid.tiles[grid_pos] = self
			z_index = grid_pos.y
			movement_tween = get_tree().create_tween()
			movement_tween.tween_property(self, "position", grid.grid_to_world(grid_pos), 0.2)

			if not was_dragged:
				for neighbour in grid.get_neighbours(old_location):
					if not grid.tiles.has(neighbour):
						continue

					grid.tiles[neighbour].check_preferences()
			
			was_dragged = true

func tick():
	if is_in_roster:
		return

	just_moved = false

	if cooldown > 0:
		cooldown -= 1
		#animated_sprite.play("idle")
		return

	var enemy = grid.get_closest_enemy(self)

	if enemy == null:
		animated_sprite.play("idle")
		return

	if enemy.grid_pos.distance_to(grid_pos) <= max(1, unit.reach) and not enemy.just_moved:
		melee_attack(enemy)
		return

	if enemy.grid_pos.distance_to(grid_pos) <= unit.attack_range and not enemy.just_moved:
		ranged_attack(enemy)
		return

	var path = grid.get_path_to_closest_enemy(self)

	if path.size() > 1:
		move_to(path[1])
		return

	animated_sprite.play("idle")


func move_to(new_grid_pos: Vector2i):
	assert(not grid.tiles.has(new_grid_pos), "New grid position is filled already")

	just_moved = true
	animated_sprite.play("run")
	z_index = grid_pos.y
	cooldown += unit.movement_cooldown

	if new_grid_pos.x < grid_pos.x:
		animated_sprite.flip_h = true
	elif new_grid_pos.x > grid_pos.x:
		animated_sprite.flip_h = false

	grid.tiles.erase(grid_pos)
	grid_pos = new_grid_pos
	grid.tiles[grid_pos] = self

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", grid.grid_to_world(grid_pos), CombatManager.TICK_LENGTH)

func melee_attack(target: UnitController):
	AudioManager.play("arrow")
	print("melee")
	animated_sprite.play("melee")
	cooldown = unit.melee_attack_cooldown

	if target.grid_pos.x < grid_pos.x:
		animated_sprite.flip_h = true
	elif target.grid_pos.x > grid_pos.x:
		animated_sprite.flip_h = false

	await get_tree().create_timer(CombatManager.TICK_LENGTH * 2/3).timeout

	target.take_damage(unit.melee_damage, unit.melee_is_magic)

	# tempish
	await get_tree().create_timer(CombatManager.TICK_LENGTH * 3).timeout


	animated_sprite.play("idle")

func ranged_attack(target: UnitController):
	animated_sprite.play("ranged")
	cooldown = unit.ranged_attack_cooldown

	if target.grid_pos.x < grid_pos.x:
		animated_sprite.flip_h = true
	elif target.grid_pos.x > grid_pos.x:
		animated_sprite.flip_h = false

	await get_tree().create_timer(CombatManager.TICK_LENGTH * 1/3).timeout

	var arrow = arrow_prefab.instantiate() as Arrow
	add_child(arrow)
	arrow.fly_to(unit.ranged_damage, unit.ranged_is_magic, target)

	# settings 1 from 1/3
	await get_tree().create_timer(CombatManager.TICK_LENGTH * 1).timeout

	# tempish
	await get_tree().create_timer(CombatManager.TICK_LENGTH * 3).timeout

	animated_sprite.play("idle")

func take_damage(amount : int, is_magic : bool):
	if is_magic:
		amount = int(amount * (1 - unit.resist / 100.0))
	else:
		amount = int(amount * (1 - unit.armour / 100.0))

	print("Taking damage: ", amount)

	health -= amount
	health = clamp(health, 0, unit.max_health)

	healthbar_red.size.x = (health / float(unit.max_health)) * healthbar.size.x
	get_tree().create_tween().tween_property(healthbar_white, "size:x", (health / float(unit.max_health)) * healthbar.size.x, CombatManager.TICK_LENGTH * 1/3)

	animated_sprite.play("flinch")

	if health == 0:
		get_tree().create_tween().tween_property(self, "modulate:a", 0, CombatManager.TICK_LENGTH * 1/3)

	await get_tree().create_timer(CombatManager.TICK_LENGTH * 1/3).timeout

	if health == 0:
		grid.tiles.erase(grid_pos)
		grid.units.erase(self)
		self.grid_pos = Vector2i(1000, 1000)

	# tempish
	await get_tree().create_timer(CombatManager.TICK_LENGTH * 3).timeout

	animated_sprite.play("idle")

func heal(amount : int):
	health += amount
	health = clamp(health, 0, unit.max_health)

	healthbar_white.size.x = (health / float(unit.max_health)) * healthbar.size.x
	get_tree().create_tween().tween_property(healthbar_red, "size:x", (health / float(unit.max_health)) * healthbar.size.x, CombatManager.TICK_LENGTH * 1/3)

func teleport(new_grid_pos: Vector2i):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.1)

	if grid_pos in grid.tiles and grid.tiles[grid_pos] == self:
		grid.tiles.erase(grid_pos)
	
	self.grid_pos = new_grid_pos
	grid.tiles[grid_pos] = self
	position = grid.grid_to_world(grid_pos)
	z_index = grid_pos.y
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

func appear(new_grid_pos: Vector2i):
	self.modulate = Color(1, 1, 1, )
	self.grid_pos = new_grid_pos
	grid.tiles[grid_pos] = self
	position = grid.grid_to_world(grid_pos)
	z_index = grid_pos.y
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.1)
