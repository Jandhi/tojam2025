extends Node

var sounds : Dictionary[String, AudioStream] = {}
var group_by_sound : Dictionary[String, String] = {}
var multi_sounds : Dictionary[String, Array] = {}

var players : Array[AudioStreamPlayer] = []
var groups : Dictionary[String, AudioGroup] = {}

func _ready():
	load_audio()

func load_audio():
	groups = {
		"music" : AudioGroup.make("music", 0.0, 1, true).with_volume_scaling(0.1),
	}

	sounds = {
		"battle_theme" : load("res://audio/music/BattleTheme.mp3"),
		"menu_theme" : load("res://audio/music/MenuTheme.mp3"),
		"shop_theme" : load("res://audio/music/ShopTheme.mp3"),
		"loss" : load("res://audio/music/Loss.mp3"),
		"victory" : load("res://audio/music/Victory.mp3"),

		"grunt1" : load("res://audio/grunt/grunt1.mp3"),
		"grunt2" : load("res://audio/grunt/grunt2.mp3"),
		"grunt3" : load("res://audio/grunt/grunt3.mp3"),
		"grunt4" : load("res://audio/grunt/grunt4.mp3"),
		"grunt5" : load("res://audio/grunt/grunt5.mp3"),

		"mumble1" : load("res://audio/mumble/mumble1.mp3"),
		"mumble2" : load("res://audio/mumble/mumble2.mp3"),
		"mumble3" : load("res://audio/mumble/mumble3.mp3"),
		"mumble4" : load("res://audio/mumble/mumble4.mp3"),
		"mumble5" : load("res://audio/mumble/mumble5.mp3"),

		"buy" : load("res://audio/Cash register 2.wav"),
		"loot" : load("res://audio/Cash register 3.wav"),
	}

	multi_sounds = {
		"grunt" : ["grunt1", "grunt2", "grunt3", "grunt4", "grunt5"],
		"mumble" : ["mumble1", "mumble2", "mumble3", "mumble4", "mumble5"],
	}

	group_by_sound = {
		"battle_theme" : "music",
		"menu_theme" : "music",
		"shop_theme" : "music",
		"loss" : "music",
		"victory" : "music",
	}

func _process(delta):
	for group_name in groups:
		groups[group_name].update(delta)

func play(sound_name : String, pitch_randomness : float = 0.0, volume : float = 1.0, skip_fade : bool = false, pitch_shift : float = 0.0):
	var sound = null

	if sounds.has(sound_name):
		sound = sounds[sound_name]
	elif multi_sounds.has(sound_name):
		var sounds_array = multi_sounds[sound_name]
		sound = sounds[sounds_array[randi() % sounds_array.size()]]
	else:
		print("Sound not found: " + sound_name)
		return

	var group = null

	if group_by_sound.has(sound_name):
		var group_name = group_by_sound[sound_name]
		if groups.has(group_name):
			group = groups[group_name]


			if group.fade_on_new_sound:
				await group.fade_out(skip_fade)

			if not group.is_available():
				print("Group is not available: " + group_name)
				return
			
			volume *= group.volume_scaling
			print("volue scaling: " + str(group.volume_scaling))

	var player = get_next_free_player()

	if group != null:
		group.add_player(player)
	
	if player == null:
		print("No free player found")
		return

	player.stream = sound
	player.pitch_scale = 1.0 + pitch_shift + randf_range(-pitch_randomness, pitch_randomness)
	player.volume_db = linear_to_db(volume)
	player.play()

	
func get_next_free_player():
	for player in players:
		if not player.is_playing():
			return player
