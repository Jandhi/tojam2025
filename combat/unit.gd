class_name Unit extends Resource

@export var unit_type : String
@export var portrait : Texture2D
@export var tags : Array[String] = []

@export_group("Stats")
@export var max_health : int
@export var armour : float
@export var resist : float
@export var movement_cooldown : int

@export_group("Melee")
@export var melee_damage : int
@export var melee_is_magic : bool
@export var melee_attack_cooldown : int
@export var reach : int

@export_group("Ranged")
@export var ranged_damage : int
@export var ranged_is_magic : bool
@export var ranged_attack_cooldown : int
@export var attack_range : int