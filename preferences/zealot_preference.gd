class_name ZealotPreference extends PlacementPreference

var religious_tags : Array[String] = [
	"zealot",
	"fanatic",
]

func evaluate_fulfilled(unit : UnitController, grid : Grid, _combatManager : CombatManager) -> bool:
	for neighbour in grid.get_neighbours(unit.grid_pos):
		if not grid.tiles.has(neighbour):
			continue

		var neighbour_unit : UnitController = grid.tiles[neighbour]
		
		for tag in religious_tags:
			if neighbour_unit.tags.has(tag) and not unit.tags.has(tag):
				return false

	return true

func get_complaint() -> String:
	return [
		"HEATHEN!",
	].pick_random()

func get_description() -> String:
	return "This unit hates others of different faiths."