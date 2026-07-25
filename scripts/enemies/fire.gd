extends Area2D

@export var max_health: int = 5
var health: int = max_health

func _ready():
	$AnimatedSprite2D.play()

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		queue_free()
	display_damage(health)

func display_damage(health: int) -> void:
	var size: float = (float(health) / float(max_health)) / 2 + 0.5
	$AnimatedSprite2D.scale = Vector2(size,size)
	$CPUParticles2D.scale = Vector2(size,size)
