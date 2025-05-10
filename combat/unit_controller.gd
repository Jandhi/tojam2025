class_name UnitController extends Node2D

signal hovered
signal unhovered
signal attempted_to_move_commander_to_roster

@export var unit_name : String
@export var unit : Unit
@export var grid_pos : Vector2i
@export var is_player_unit : bool = true
@export var is_player_commander : bool = false
@export var grid : Grid
@export var roster : Grid
@export var animated_sprite : AnimatedSprite2D
@export var hover_box : Control

@export_group("Healthbar")
@export var healthbar : Control
@export var healthbar_white : ColorRect
@export var healthbar_red : ColorRect

var cooldown : int = 0
var health : int = 0
var just_moved : bool = false
var is_hovered : bool = false
var is_clicked : bool = false
var is_moveable : bool = true
var is_in_roster : bool = false
var movement_tween : Tween = null

func _ready():
	hover_box.mouse_entered.connect(func():
		is_hovered = true
		hovered.emit()
	)
	hover_box.mouse_exited.connect(func():
		if is_clicked:
			return

		is_hovered = false
		unhovered.emit()
	)

	grid_pos = grid.world_to_grid(self.position)
	grid.tiles[grid_pos] = self
	grid.units.append(self)
	position = grid.grid_to_world(grid_pos)
	health = unit.max_health
	z_index = grid_pos.y

	if not is_player_unit:
		animated_sprite.flip_h = true
		animated_sprite.self_modulate = Color(1, 0.5, 0.5)
		is_moveable = false

func _input(event: InputEvent) -> void:
	if not is_moveable:
		return

	# If the mouse is down, drag
	if event is InputEventMouseButton:
		if event.is_pressed() and is_hovered:
			is_clicked = true
		if event.is_released():
			is_clicked = false
	
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
				roster.tiles[grid_pos] = self
				z_index = grid_pos.y
				movement_tween = get_tree().create_tween()
				movement_tween.tween_property(self, "position", roster.grid_to_world(grid_pos), 0.2)
			else:
				grid.tiles.erase(grid_pos)
				grid_pos = new_location
				roster.tiles[grid_pos] = self
				reparent(roster, true)
				z_index = grid_pos.y
				movement_tween = get_tree().create_tween()
				movement_tween.tween_property(self, "position", roster.grid_to_world(grid_pos), 0.2)
				is_in_roster = true

			
			return

		if new_location == grid_pos:
			return

		if grid.tiles.has(new_location):
			return

		if movement_tween != null:
			movement_tween.stop()
		
		if is_in_roster:
			roster.tiles.erase(grid_pos)
			grid_pos = new_location
			grid.tiles[grid_pos] = self
			reparent(grid)
			is_in_roster = false
			z_index = grid_pos.y
			movement_tween = get_tree().create_tween()
			movement_tween.tween_property(self, "position", grid.grid_to_world(grid_pos), 0.2)
		else:
			grid.tiles.erase(grid_pos)
			grid_pos = new_location
			grid.tiles[grid_pos] = self
			z_index = grid_pos.y
			movement_tween = get_tree().create_tween()
			movement_tween.tween_property(self, "position", grid.grid_to_world(grid_pos), 0.2)
	

func set_unit(new_unit: Unit):
	self.unit = new_unit
	health = new_unit.max_health

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

	if enemy.grid_pos.distance_to(grid_pos) <= unit.reach and not enemy.just_moved:
		melee_attack(enemy)
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
	animated_sprite.play("melee")
	cooldown = unit.melee_attack_cooldown

	if target.grid_pos.x < grid_pos.x:
		animated_sprite.flip_h = true
	elif target.grid_pos.x > grid_pos.x:
		animated_sprite.flip_h = false

	await get_tree().create_timer(CombatManager.TICK_LENGTH * 2/3).timeout

	target.take_damage(unit.melee_damage, unit.melee_is_magic)

	animated_sprite.play("idle")

func take_damage(amount : int, is_magic : bool):
	if is_magic:
		amount = int(amount * (1 - unit.resist))
	else:
		amount = int(amount * (1 - unit.armour))

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
		self.grid_pos = Vector2i(1000, 1000)
