extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.is_near_water = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.is_near_water = false
