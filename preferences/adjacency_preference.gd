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
	"fae": [
		"I'm not fighting next to no Faerie!",
		"Curse my luck, a treehugger!",
		"Stay back monster, I have iron.",
	],
	"man": [
		"The age of men is over!",
		"Arrogant man! I have no need for such allies.",
		"Do not let your machismo get the better of you, pig!",
	],
	"woman": [
		"Was one woman not bad enough?",
		"Pah! Are we going to braid each other's hair?",
		"This is no place for a woman!",
	],
	"demon": [
		"Begone fiend of hell!",
		"Must I endure this sulphurous villain?",
		"If hell is filled with the likes of you, than perhaps I should consider virtue.",
	],
	"undead": [
		"Get back in the ground you old bones.",
		"Your time is over, why must you haunt us with your loathsome presence.",
		"I'll respect the dead when they stay in the grave.",
	],
	"lilian": [
		"Cease your insufferable moralizing!",
		"Must I listen to this slave of the Queen.",
		"I thought we were here to destroy the church, not fight alongside it's lackeys.",
	], 
	"farisian": [
		"Does your prophetess truly want you to be so prissy and fickle.",
		"How fares your capital? Still rubble?",
		"How can you waste your time on all that grooming?",
	],
	"heathen": [
		"What superstitious prattle must I endure from you, foolish heathen!",
		"Mistress! The heathen is praying to dirt and clouds again!",
		"I will die before you're done praying to all your weakling gods.",
	],
	"heretic": [
		"Your every belief is an insult.",
		"Do you expect me to suffer heresy in my midst?",
		"Everything you say is wrong!",
	],
	"witch": [
		"I will suffer not the witch.",
		"You can't make me tolerate these sorcerer's ways.",
		"Turn me into a frog and I shall slay you where you stand, witch!",
	], 
	"ruin": [
		"Listen you can love the boss too much",
		"Are you comfortable with these zealots, mistress? I may need to rethink this.",
		"I get it, you're edgy!",
	],
	"smelly": [
		"The stench! I can't think.",
		"Please I beg you, bathe for once in your misbegotten life.",
		"I dread to think what I did to deserve this stench.",
	],
	"mercenary": [
		"A classless killer for hire. Despicable.",
		"Have we truly gotten so desperate?",
		"How much is she paying you? I doubt you're worth it.",
	],		
}

var wants_to_be_next_to_complaints : Dictionary = {
	"elf": [
		"I want to be next an elf.",
	],
	"mistress": [
		"Please Mistress, let me closer.",
		"I cannot live so far from my Mistress.",
		"Do you not love me, Mistress?",
	],
}

var descriptions : Dictionary = {
	"elf": "Elfphobe: Does not want to be next to elves.",
	"fae": "Hater of Fae: Does not want to be next to fae.",
	"man": "Disdain of Men: Does not want to be next to men.",
	"woman": "Misognyist: Does not want to be next to women.",
	"demon": "Fear of Hell: Does not want to be next to demons.",
	"undead": "Fear of Death: Does not want to be next to undead.",
	"lilian": "Anti-clerical: Does not want to be next to lilians.",
	"farisian": "Crusader: Does not want to be next to farisians.",
	"heathen": "Nature Hater: Does not want to be next to heathens.",
	"heretic": "Doctrinal: Does not want to be next to heretics.",
	"witch": "Arcanaphobia: Does not want to be next to witches.",
	"mistress": "Obsessive: Wants to be next to the Mistress.",
	"ruin": "Wholesome: Does not want to be next to members of the cult of ruin.",
	"smelly": "Grooming Standard: Does not want to be next to smelly units.",
}

func evaluate_fulfilled(unit : UnitController, grid : Grid, _combatManager : CombatManager) -> bool:
	var neighbours = grid.get_neighbours(unit.grid_pos)

	for neighbour in neighbours:
		if not grid.tiles.has(neighbour):
			continue

		var neighbour_unit : UnitController = grid.tiles[neighbour]
		
		if not is_instance_valid(neighbour_unit):
			continue
		
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
	
