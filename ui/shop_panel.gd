class_name ShopPanel extends Sprite2D

func _ready():
	# Set the initial position of the shop panel off-screen
	position = Vector2(2300.0, 540.0)

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