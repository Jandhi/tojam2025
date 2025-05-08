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
    }

    sounds = {
    }

    multi_sounds = {
    }

    group_by_sound = {
    }

func _process(delta):
    for group_name in groups:
        groups[group_name].update(delta)

func play(sound_name : String, pitch_randomness : float = 0.0, volume : float = 1.0):
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
            if not group.is_available():
                return

    var player = get_next_free_player()

    if group != null:
        group.add_player(player)
    
    if player == null:
        print("No free player found")
        return

    player.stream = sound
    player.pitch_scale = 1.0 + randf_range(-pitch_randomness, pitch_randomness)
    player.volume_db = volume
    player.play()

    
func get_next_free_player():
    for player in players:
        if not player.is_playing():
            return player