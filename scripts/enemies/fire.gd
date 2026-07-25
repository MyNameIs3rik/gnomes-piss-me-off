extends Area2D

@export var max_health: int = 5
var health: int = max_health

var fire_place: Area2D

func _ready():
	$AnimatedSprite2D.play()

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		fire_place.decrement()
		queue_free()
	display_damage()

func display_damage() -> void:
	var size: float = (float(health) / float(max_health)) / 1.5 + 1.0 / 3.0
	$AnimatedSprite2D.scale = Vector2(size,size)
	$CPUParticles2D.scale = Vector2(size,size)

func ignite() -> void:
	$AnimationPlayer.play("ignite")
