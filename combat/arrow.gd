class_name Arrow extends Sprite2D

func fly_to(damage : int, is_magic : bool, target:  UnitController) -> void:
	global_position += Vector2(0, -50);

	var target_pos = target.global_position + Vector2(0, -50)

	var diff = target_pos - global_position

	rotate(diff.angle())

	var tween = get_tree().create_tween().tween_property(self, "global_position", target_pos, CombatManager.TICK_LENGTH * 1/3)

	await tween.finished

	target.take_damage(damage, is_magic)
	queue_free()
