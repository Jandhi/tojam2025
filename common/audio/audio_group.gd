class_name AudioGroup extends Resource

var name : String
var _cooldown : float = 0.0
var cooldown_time : float = 0.0
var max_players : int = 1
var players : Array[AudioStreamPlayer] = []

static func make(new_name: String, new_cooldown_time: float, new_max_players: int) -> AudioGroup:
	var group = AudioGroup.new()
	group.name = new_name
	group.cooldown_time = new_cooldown_time
	group.max_players = new_max_players
	return group

func add_player(player: AudioStreamPlayer) -> void:
	_cooldown = cooldown_time
	players.append(player)

func is_available() -> bool:
	return _cooldown == 0.0 and players.size() < max_players

func update(delta: float) -> void:
	var players_to_remove = []

	for player in players:
		if not player.is_playing():
			players_to_remove.append(player)

	for player in players_to_remove:
		players.erase(player)

	_cooldown = max(0.0, _cooldown - delta)
