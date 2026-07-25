extends Area2D

func _ready() -> void:
	$AnimationPlayer.play("stab")

func _on_body_entered(body) -> void:
	body.take_damage()

func die() -> void:
	queue_free()
