class_name AdjacencyPreference extends PlacementPreference

@export var tag : String
@export var wants_to_be_next_to : bool = false

var wants_not_to_be_next_to_complaints : Dictionary = {
	"elf": [
		"I don't like elves.",
		"Elves are not my kind of people.",
		"Elves are too pointy for my taste.",
		"Elves are too tall for my taste.",
		"Elves are too skinny for my taste.",
	],
}

var wants_to_be_next_to_complaints : Dictionary = {
	"elf": [
		"I want to be next an elf.",
	],
}

var descriptions : Dictionary = {
	"elf": "Elfphobe: Does not want to be next to elves.",
}

func evaluate_fulfilled(unit : UnitController, grid : Grid, _combatManager : CombatManager) -> bool:
	var neighbours = grid.get_neighbours(unit.grid_pos)

	for neighbour in neighbours:
		if not grid.tiles.has(neighbour):
			continue

		var neighbour_unit : UnitController = grid.tiles[neighbour]
		if neighbour_unit.tags.has(tag):
			return wants_to_be_next_to

	return not wants_to_be_next_to

func get_complaint() -> String:
	if tag in wants_to_be_next_to_complaints and wants_to_be_next_to:
		return wants_to_be_next_to_complaints[tag].pick_random()
	if tag in wants_not_to_be_next_to_complaints and not wants_to_be_next_to:
		return wants_not_to_be_next_to_complaints[tag].pick_random()

	return super.get_complaint()

func get_description() -> String:
	if tag in descriptions:
		return descriptions[tag]

	return super.get_description()
	