class_name Arrow extends Sprite2D

func fly_to(damage : int, is_magic : bool, target:  UnitController) -> void:
	global_position += Vector2(0, -50);

	var target_pos = target.global_position + Vector2(0, -50)

	var diff = target_pos - global_position

	rotate(diff.angle())

	var tween = get_tree().create_tween().tween_property(self, "global_position", target_pos, CombatManager.TICK_LENGTH)

	await tween.finished

	if not is_instance_valid(target):
		queue_free()
		return

	target.take_damage(damage, is_magic)
	AudioManager.play("arrow", 0.1, 1.0)
	queue_free()
