extends Control

func start():
	self.modulate = Color(1, 1, 1, 0)
	var tween = get_tree().create_tween().set_parallel(false)
	tween.tween_property(self, "modulate:a", 1, 0.25)
	tween.tween_property(self, "position", self.position + Vector2(0, 1000), 0.5)\
		.set_delay(2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)
	await get_tree().create_timer(3.0).timeout
	queue_free()
