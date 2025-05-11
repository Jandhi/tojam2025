class_name UnitSale extends Control

signal purchase_clicked
signal unit_added(unit : UnitController)

var gold_currency = preload("res://textures/gold_icon.png")
var pact_currency = preload("res://textures/pact_icon.png")

@export var unit_anchor : Control
@export var cost : RichTextLabel
@export var currency_display : TextureRect
@export var unit_name : RichTextLabel
var combat_manager : CombatManager
var unit : UnitController


func _ready():
	add_unit()

func add_unit():
	unit = UnitManager.spawn_unit()
	unit.is_player_unit = true
	unit.grid_pos = Vector2i(0, 0)
	unit.is_moveable = false
	unit_anchor.add_child(unit)
	unit.is_in_store = true

	unit_name.text = "[center]" + unit.unit_name
	cost.text = str(unit.unit.cost)

	if unit.unit.cost_currency == Unit.Currency.Gold:
		currency_display.texture = gold_currency
	else:
		currency_display.texture = pact_currency

	unit_added.emit(unit)


func _on_button_pressed():
	purchase_clicked.emit()
