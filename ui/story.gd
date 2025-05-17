extends Control

var frame_count : int = 0

@export var frame : TextureRect
@export var text : RichTextLabel
@export var color_rect : ColorRect
@export var audio_player : AudioStreamPlayer
@export var combat_manager : CombatManager
@export var click_to_continue : RichTextLabel

@export var frame1 : Texture2D
@export var frame2 : Texture2D
@export var frame3 : Texture2D
@export var frame4 : Texture2D

@export var audio1a : AudioStream
@export var audio1b : AudioStream
@export var audio2 : AudioStream
@export var audio3 : AudioStream
@export var audio4 : AudioStream

var clickable : bool = false

var main_menu : PackedScene = preload("res://ui/main_menu.tscn")
static var has_seen_story : bool = false

var copy1a = "The dungeons have always been with us. A godless place, the cyclopean labyrinths snake deep into the earth to the very depths of hell. None dared tread, for death in the dungeon is to suffer eternal damnation."
var copy1b = "One day, a woman of no particular station ventured into the accursed place. She was gone for months. What few people knew her simply assumed she died. "
var copy2 = "When she re-emerged. She wore a magnificent crown and wielded a dreadful staff. Strange artifacts taken from deeper in the dungeon than anyone had ever gone before."
var copy3 = "With her staff she ensorcelled daemons and undead to her purposes. With her crown she manipulated man and fae alike into an alliance under her authority. She styles herself the Mistress of Ruin, and bitter, petty vengeance upon the world of man is her cause."
var copy4 = "…that is, if she can get her army to cooperate."
var is_finishing : bool = false
var my_tween : Tween = null

func _ready():
	if has_seen_story:
		await load_menu()
		combat_manager.enter_game(true)
		queue_free()
		return

	has_seen_story = true
	show_frame1a()

func next_frame():
	if my_tween != null:
		my_tween.stop()
		my_tween = null

	frame_count += 1

	if frame_count == 1:
		show_frame1b()
	elif frame_count == 2:
		show_frame2()
	elif frame_count == 3:
		show_frame3()
	elif frame_count == 4:
		show_frame4()
	elif not is_finishing:
		is_finishing = true	
		load_menu()

		await get_tree().create_tween().tween_property(self, "modulate:a", 0, 0.5).finished
		queue_free()

func show_frame1a():
	click_to_continue.modulate.a = 0
	frame.modulate.a = 0
	text.text = "[center]" + copy1a
	audio_player.stream = audio1a

	await get_tree().create_tween().tween_property(color_rect, "modulate:a", 0.0, 0.5).finished
	audio_player.play()
	clickable = true

	await get_tree().create_timer(16.0).timeout
	my_tween = get_tree().create_tween()
	my_tween.tween_property(click_to_continue, "modulate:a", 1, 0.5)


func show_frame1b():
	click_to_continue.modulate.a = 0
	text.text = "[center]" + copy1b
	frame.texture = frame1
	audio_player.stream = audio1b
	audio_player.play()

	frame.position = Vector2(39, -23)
	frame.scale = Vector2(0.88, 0.88)
	frame.pivot_offset = Vector2(922, 443)

	my_tween = get_tree().create_tween().set_parallel(true)
	my_tween.tween_property(frame, "modulate:a", 1, 2.0)
	await my_tween.finished

	var length = 8.0
	my_tween = get_tree().create_tween().set_parallel(true)
	my_tween.tween_property(frame, "scale", Vector2(1.0, 1.0), length)
	my_tween.tween_property(frame, "position", Vector2(39, -70), length)

	await get_tree().create_timer(10.0).timeout
	my_tween = get_tree().create_tween()
	my_tween.tween_property(click_to_continue, "modulate:a", 1, 0.5)


func show_frame2():
	click_to_continue.modulate.a = 0
	text.text = "[center]" + copy2
	frame.texture = frame2
	audio_player.stream = audio2
	audio_player.play()

	frame.modulate.a = 1
	frame.pivot_offset = Vector2(0, 0)
	frame.position = Vector2(150, -761)
	frame.scale = Vector2(1.0, 1.0)

	var length = 10.0
	my_tween = get_tree().create_tween().set_parallel(true)
	my_tween.tween_property(frame, "position", Vector2(150, -20), length)

	await get_tree().create_timer(10.0).timeout
	my_tween = get_tree().create_tween()
	my_tween.tween_property(click_to_continue, "modulate:a", 1, 0.5)


func show_frame3():
	click_to_continue.modulate.a = 0
	text.text = "[center]" + copy3
	frame.texture = frame3
	audio_player.stream = audio3
	audio_player.play()

	frame.pivot_offset = Vector2(0, 0)
	frame.position = Vector2(150, 30)
	frame.scale = Vector2(1.0, 1.0)

	var length = 20.0
	my_tween = get_tree().create_tween().set_parallel(true)
	my_tween.tween_property(frame, "position", Vector2(-30, 30), length)

	await get_tree().create_timer(10.0).timeout
	my_tween = get_tree().create_tween()
	my_tween.tween_property(click_to_continue, "modulate:a", 1, 0.5)

func show_frame4():
	click_to_continue.modulate.a = 0
	text.text = "[center]" + copy4
	frame.texture = frame4
	audio_player.stream = audio4
	audio_player.play()

	frame.pivot_offset = Vector2(0, 0)
	frame.position = Vector2(140, 22)
	frame.scale = Vector2(1.0, 1.0)

	await get_tree().create_timer(5.0).timeout
	my_tween = get_tree().create_tween()
	my_tween.tween_property(click_to_continue, "modulate:a", 1, 0.5)


func _on_gui_input(event):
	if not clickable:
		return

	if event is InputEventMouseButton:
		if event.is_pressed():
			next_frame()

func load_menu():
	var menu = main_menu.instantiate()
	combat_manager.main_menu = menu
	get_parent().add_child(menu)
	menu.enter_game.connect(combat_manager.enter_game)
