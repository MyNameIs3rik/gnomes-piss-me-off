extends Area2D
@export var max_health: int = 5
var health: int = max_health
var fire_place: Area2D

@export var damage_per_tick: int = 1
@export var damage_interval: float = 1.0

func _ready():
	$AnimatedSprite2D.play()

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		$DamageTimer.stop()
		fire_place.decrement()
		queue_free()
	display_damage()

func display_damage() -> void:
	var size: float = (float(health) / float(max_health)) / 1.5 + 1.0 / 3.0
	$AnimatedSprite2D.scale = Vector2(size,size)
	$CPUParticles2D.scale = Vector2(size,size)

func ignite() -> void:
	$AnimationPlayer.play("ignite")
	$DamageTimer.wait_time = damage_interval
	$DamageTimer.start()

func _on_damage_timer_timeout() -> void:
	if fire_place and is_instance_valid(fire_place) and fire_place.has_method("take_fire_damage"):
		fire_place.take_fire_damage(damage_per_tick)
	else:
		$DamageTimer.stop()
