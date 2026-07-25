extends Area2D

func _ready() -> void:
	$AnimationPlayer.play("attack")

func _on_body_entered(body) -> void:
	body.die()
	$CollisionShape2D.set_deferred("disabled",true)

func delete() -> void:
	queue_free()
