class_name PlacementPreference extends Resource

func evaluate_fulfilled(_unit : UnitController, _grid : Grid, _combatManager : CombatManager) -> bool:
	return true

func get_complaint() -> String:
	return [
		"Grumble", 
		"[i]*sigh*",
	].pick_random()

func get_description() -> String:
	return "This unit has a preference for placement."
