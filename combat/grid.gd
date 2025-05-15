class_name Grid extends Node2D

var units : Array[UnitController] = []
var tiles : Dictionary[Vector2i, UnitController] = {}
var placeable_tile_prefab : PackedScene = preload("res://ui/placeable_tile.tscn")
var placeable_tiles : Array = []
@export var grid_size : Vector2i = Vector2i(10, 10)
@export var cell_size : Vector2 = Vector2(64, 64)
@export var combat_manager : CombatManager

func add_units():
	for unit in units:
		if unit.is_player_unit:
			combat_manager.player_units.append(unit)
		else:
			combat_manager.enemy_units.append(unit)
		combat_manager.all_units.append(unit)

func get_random_enemy_tile() -> Vector2i:
	var grid_pos = Vector2i(randi() % grid_size.x / 2 + grid_size.x / 2, randi() % grid_size.y)
	while tiles.has(grid_pos):
		grid_pos = Vector2i(randi() % grid_size.x / 2 + grid_size.x / 2, randi() % grid_size.y)
	return grid_pos

func get_random_player_tile() -> Vector2i:
	var grid_pos = Vector2i(randi() % (grid_size.x / 2), randi() % grid_size.y)
	while tiles.has(grid_pos):
		grid_pos = Vector2i(randi() % (grid_size.x / 2), randi() % grid_size.y)
	return grid_pos

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * cell_size.x, grid_pos.y * cell_size.y)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var grid_x = int((world_pos.x) / cell_size.x)
	var grid_y = int((world_pos.y) / cell_size.y)
	return Vector2i(grid_x, grid_y)

func distance_to_commander(location : Vector2i) -> int:
	return abs(location.x - combat_manager.player_leader.grid_pos.x) + abs(location.y - combat_manager.player_leader.grid_pos.y)

func is_in_bounds(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y

func get_neighbours(grid_pos: Vector2i) -> Array[Vector2i]:
	var neighbour_positions : Array[Vector2i] = []
	for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var neighbour_pos = grid_pos + d
		if is_in_bounds(neighbour_pos):
			neighbour_positions.append(neighbour_pos)
	return neighbour_positions

func get_closest_enemy(unit: UnitController) -> UnitController:
	var closest_enemy : UnitController = null
	var closest_distance = INF
	for enemy in units:
		if not is_instance_valid(enemy):
			continue

		if enemy.is_player_unit == unit.is_player_unit:
			continue
		
		var distance = unit.grid_pos.distance_to(enemy.grid_pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy

func get_path_to_closest_enemy(unit_a : UnitController) -> Array[Vector2i]:
	var queue : Array[Array] = []
	var visited : Dictionary[Vector2i, bool] = {}

	var starting_array : Array[Vector2i] = [unit_a.grid_pos]
	queue.append(starting_array)

	while queue.size() > 0:
		var path = queue.pop_front()
		var current_pos = path[-1]

		for neighbour in get_neighbours(current_pos):
			if tiles.has(neighbour) and is_instance_valid(tiles[neighbour]) and tiles[neighbour].is_player_unit != unit_a.is_player_unit:
				return path

			if not visited.has(neighbour) and not tiles.has(neighbour):
				visited[neighbour] = true
				var new_path = path.duplicate()
				new_path.append(neighbour)
				queue.append(new_path)

	return [unit_a.grid_pos]

func get_first_empty_tile_on_left_side() -> Vector2i:
	for x in range(int(grid_size.x / 2.0)):
		for y in range(grid_size.y):
			var grid_pos = Vector2i(x, y)
			if not tiles.has(grid_pos):
				return grid_pos
	return Vector2i(-1, -1) # return an invalid position if no empty tile is found

func set_placeable_tiles():
	for tile in placeable_tiles:
		tile.queue_free()
	placeable_tiles.clear()

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var grid_pos = Vector2i(x, y)
			
			if distance_to_commander(grid_pos) <= combat_manager.allowed_distance_from_leader:
				var placeable_tile = placeable_tile_prefab.instantiate()
				placeable_tile.size = cell_size
				placeable_tile.global_position = grid_to_world(grid_pos) - Vector2(cell_size.x / 2, cell_size.y / 2)
				placeable_tiles.append(placeable_tile)
				add_child(placeable_tile)

func hide_placeable_tiles():
	for tile in placeable_tiles:
		tile.queue_free()
	placeable_tiles.clear()
