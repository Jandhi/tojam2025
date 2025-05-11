class_name ShopPanel extends Sprite2D

@export var combat_manager : CombatManager
@export var unit_sales : Array[UnitSale]

func _ready():
	# Set the initial position of the shop panel off-screen
	position = Vector2(2300.0, 540.0)

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
	AudioManager.play("shop_theme")

	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", Vector2(1555.0, 540.0), 0.5)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)	

func exit_shop():
	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", Vector2(2300.0, 540.0), 0.5)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_IN)


func _on_button_pressed():
	combat_manager.play_combat()
