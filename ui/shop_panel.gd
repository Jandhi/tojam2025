class_name ShopPanel extends Sprite2D

@export var combat_manager : CombatManager
@export var unit_sales : Array[UnitSale]
@export var dialogue_picture : Sprite2D
@export var dialogue_text : RichTextLabel
var in_shop : bool = false
var dialogue_tween : Tween = null

var shopkeeper_enter_dialogues = [
	"Welcome to my shop!",
	"Back again, so soon?",
	"Ah, a customer! I hope you have the gold.",
	"Welcome! I have some great deals for you today.",
	"Care to browse my wares?",
	"You look like you could use some new units.",
	"[shake]WELCOME!",
]

var shopkeeper_dialogues = [
	"My ex wife is missing me. But her aim is getting better.",
	"These zombies are to die for.",
	"Ah yes, the sweet smell of capitalism.",
	"Perhaps you would like a troll to go with that?",
	"Don't worry, I won't bite. Unless you ask nicely.",
	"No refunds, no exchanges, no returns.",
	"Don't ask me where I got these elves. It's a trade secret.",
	"These units are guaranteed to be 100% organic.",
	"Don't worry, I won't tell anyone you bought a heathen.",
	"These units are not responsible for any side effects.",
	"I'm fully licensed to raise undead.",
	"Guaranteed to be unethically sourced!",
]

var shopkeeper_exit_dialogues = [
	"Bye!",
	"Don't die on me!",
	"Peace out! Or don't.",
]

func _ready():
	# Set the initial position of the shop panel off-screen
	position = Vector2(2300.0, 540.0)
	dialogue_picture.modulate.a = 0

	for unit_sale in unit_sales:
		unit_sale.combat_manager = combat_manager
		unit_sale.purchase_clicked.connect(func():
			var can_afford = true

			if unit_sale.unit.unit.cost_currency == Unit.Currency.Gold:
				can_afford = combat_manager.gold >= unit_sale.unit.unit.cost
			else:
				can_afford = combat_manager.pacts >= unit_sale.unit.unit.cost

			if not can_afford:
				combat_manager.cannot_afford()
				return

			if unit_sale.unit.unit.cost_currency == Unit.Currency.Gold:
				combat_manager.set_gold(combat_manager.gold - unit_sale.unit.unit.cost)
			else:
				combat_manager.set_pacts(combat_manager.pacts - unit_sale.unit.unit.cost)

			AudioManager.play("buy")

			combat_manager.add_unit_to_player(unit_sale.unit)
			unit_sale.add_unit()
		)
		unit_sale.unit_added.connect(func(unit : UnitController):
			combat_manager.setup_unit(unit)
		)

		combat_manager.setup_unit(unit_sale.unit)
	


func enter_shop():
	in_shop = true
	AudioManager.play("shop_theme")

	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", Vector2(1555.0, 540.0), 0.5)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)	

	await tween.finished
	start_shopkeeper_loop()

func exit_shop():
	in_shop = false
	show_dialogue(shopkeeper_exit_dialogues.pick_random(), 0.5)
	await get_tree().create_timer(0.5).timeout

	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", Vector2(3000.0, 540.0), 1.0)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_IN)

func _on_button_pressed():
	combat_manager.play_combat()


func start_shopkeeper_loop():
	await show_dialogue(shopkeeper_enter_dialogues.pick_random())

	while in_shop:
		await get_tree().create_timer(randf_range(5.0, 10.0)).timeout
		var dialogue = shopkeeper_dialogues.pick_random()
		await show_dialogue(dialogue)

func show_dialogue(text : String, show_time = 3.0) -> void:
	if dialogue_tween:
		dialogue_tween.stop()

	AudioManager.play("shopkeeper")
	dialogue_tween = get_tree().create_tween().set_parallel(false)
	dialogue_text.text = "[center]" + text

	dialogue_tween.tween_property(dialogue_picture, "modulate:a", 1, 0.2)
	dialogue_tween.tween_property(dialogue_picture, "modulate:a", 0, 0.2).set_delay(show_time)
	await dialogue_tween.finished

func refresh():
	if combat_manager.gold < 1:
		combat_manager.cannot_afford()
		return
	
	combat_manager.set_gold(combat_manager.gold - 1)
	AudioManager.play("buy")

	for unit_sale in unit_sales:
		unit_sale.refresh()
