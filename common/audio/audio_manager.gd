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
        "collisions" : AudioGroup.make("collisions", 0.1, 1),
    }

    sounds = {
        "die1" : load("res://assets/audio/dice/die1.wav"),
        "die2" : load("res://assets/audio/dice/die2.wav"),
        "die3" : load("res://assets/audio/dice/die3.wav"),

        "hit_1" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_001_90382.wav"),
        "hit_2" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_002_90383.wav"),
        "hit_3" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_003_90384.wav"),
        "hit_4" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_004_90385.wav"),
        "hit_5" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_005_90386.wav"),
        "hit_6" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_006_90387.wav"),
        "hit_7" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_007_90388.wav"),
        "hit_8" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_008_90389.wav"),
        "hit_9" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_009_90390.wav"),
        "hit_10" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_010_90391.wav"),
        "hit_11" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_011_90392.wav"),
        "hit_12" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_012_90393.wav"),
        "hit_13" : load("res://assets/audio/hit/impact/zapsplat_impacts_body_hit_punch_or_kick_013_90394.wav"),

        "hit_whoosh_1" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_001_90395.wav"),
        "hit_whoosh_2" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_002_90396.wav"),
        "hit_whoosh_3" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_003_90397.wav"),
        "hit_whoosh_4" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_004_90398.wav"),
        "hit_whoosh_5" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_005_90399.wav"),
        "hit_whoosh_6" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_006_90400.wav"),
        "hit_whoosh_7" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_007_90401.wav"),
        "hit_whoosh_8" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_008_90402.wav"),
        "hit_whoosh_9" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_009_90403.wav"),
        "hit_whoosh_10" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_010_90404.wav"),
        "hit_whoosh_11" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_011_90405.wav"),
        "hit_whoosh_12" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_012_90406.wav"),
        "hit_whoosh_13" : load("res://assets/audio/hit/whoosh/zapsplat_impacts_body_hit_punch_or_kick_whoosh_013_90407.wav"),

        "footstep_dirt_1" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_001_23148.wav"),
        "footstep_dirt_2" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_002_23149.wav"),
        "footstep_dirt_3" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_003_23150.wav"),
        "footstep_dirt_4" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_004_23151.wav"),
        "footstep_dirt_5" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_005_23152.wav"),
        "footstep_dirt_6" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_006_23153.wav"),
        "footstep_dirt_7" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_007_23154.wav"),
        "footstep_dirt_8" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_008_23155.wav"),
        "footstep_dirt_9" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_009_23156.wav"),
        "footstep_dirt_10" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_010_23157.wav"),
        "footstep_dirt_11" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_011_23158.wav"),
        "footstep_dirt_12" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_012_23159.wav"),
        "footstep_dirt_13" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_013_23160.wav"),
        "footstep_dirt_14" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_014_23161.wav"),
        "footstep_dirt_15" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_015_23162.wav"),
        "footstep_dirt_16" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_016_23163.wav"),
        "footstep_dirt_17" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_017_23164.wav"),
        "footstep_dirt_18" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_018_23165.wav"),
        "footstep_dirt_19" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_019_23166.wav"),
        "footstep_dirt_20" : load("res://assets/audio/footsteps/dirt/zapsplat_foley_footstep_single_dirt_road_sneaker_020_23167.wav"),
    }

    multi_sounds = {
        "die" : ["die1", "die2", "die3"],
        "hit" : [
            "hit_1", "hit_2", "hit_3", "hit_4", "hit_5", "hit_6", "hit_7", "hit_8",
            "hit_9", "hit_10", "hit_11", "hit_12", "hit_13"
        ],
        "hit_whoosh" : [
            "hit_whoosh_1", "hit_whoosh_2", "hit_whoosh_3", "hit_whoosh_4",
            "hit_whoosh_5", "hit_whoosh_6", "hit_whoosh_7", "hit_whoosh_8",
            "hit_whoosh_9", "hit_whoosh_10", "hit_whoosh_11", "hit_whoosh_12",
            "hit_whoosh_13"
        ],
        "footstep_dirt" : [
            "footstep_dirt_1", "footstep_dirt_2", "footstep_dirt_3", "footstep_dirt_4",
            "footstep_dirt_5", "footstep_dirt_6", "footstep_dirt_7", "footstep_dirt_8",
            "footstep_dirt_9", "footstep_dirt_10", "footstep_dirt_11", "footstep_dirt_12",
            "footstep_dirt_13", "footstep_dirt_14", "footstep_dirt_15", "footstep_dirt_16",
            "footstep_dirt_17", "footstep_dirt_18", "footstep_dirt_19", "footstep_dirt_20"
        ]
    }

    group_by_sound = {
        "die" : "collisions"
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