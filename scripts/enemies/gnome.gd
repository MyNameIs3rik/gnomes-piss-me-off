extends CharacterBody2D

@export_range(3,15) var random_event_timer: float = 5
@export_range(0,15) var attack_cooldown: float = 4
@export var speed: int = 70
@export var vander_distance: int = 200

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var STAB = preload("res://scenes/enemies/showel_stab.tscn")

var can_attack: bool = true
var desired_pos: int = 0

enum STATE {
	IDLE,
	PANIC,
	ATTACK
}

var current_state = STATE.IDLE

func _ready():
	$RandomEvent.wait_time = random_event_timer
	$AttackCooldown.wait_time = attack_cooldown
	$RandomEvent.start()
	$AnimatedSprite.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	else:
		var dir: int = desired_pos - int(position.x)
		if abs(dir) > 10:
			dir = dir / abs(dir)
			flip(dir)
			if $RayCasts/RayDown.is_colliding() and not $RayCasts/RayUp.is_colliding():
				velocity.y = -260
		else: 
			dir = 0
		
		velocity.x = speed * dir
	move_and_slide()

func flip(dir: int = 0):
	if dir == 1:
		$AnimatedSprite.flip_h = false
		$RayCasts/RayDown.target_position.x = 22
		$RayCasts/RayUp.target_position.x = 22
	else:
		$AnimatedSprite.flip_h = true
		$RayCasts/RayDown.target_position.x = -22
		$RayCasts/RayUp.target_position.x = -22

func _on_random_event_timeout():
	if current_state == STATE.IDLE:
		$RandomEvent.wait_time = randf_range(-1,1) + random_event_timer
		desired_pos = randi_range(-vander_distance,vander_distance)


func _on_attack_cooldown_timeout():
	can_attack = true
