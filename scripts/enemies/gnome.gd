extends CharacterBody2D

@export_range(3,15) var random_event_timer: float = 5
@export_range(0,15) var attack_cooldown: float = 4
@export var speed: int = 70
@export var vander_distance: int = 200

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var STAB = preload("res://scenes/enemies/showel_stab.tscn")

@onready var player = %Player

var can_attack: bool = true
var desired_pos: int = 0

enum STATE {
	IDLE,
	PANIC,
	ATTACK
}

var current_state = STATE.IDLE

func _ready() -> void:
	$RandomEvent.wait_time = random_event_timer
	$AttackCooldown.wait_time = attack_cooldown
	$RandomEvent.start()
	$AnimatedSprite.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	elif current_state == STATE.IDLE:
		var dir: int = desired_pos - int(position.x)
		if abs(dir) > 10:
			dir = dir / abs(dir)
			rot(dir)
		else: 
			dir = 0
		velocity.x = speed * dir
	elif current_state == STATE.ATTACK:
		var dist: Vector2 = player.global_position - global_position
		var dir: int
		if can_attack:
			dir = dist.x / abs(dist.x)
			if dist.length() < 30:
				can_attack = false
				$AttackCooldown.start()
				var stab = STAB.instantiate()
				$AttackSpawner.add_child(stab)
				desired_pos = dist.x + position.x + randi_range(-80,80)
		else:
			if abs(desired_pos - position.x) < 10:
				desired_pos = dist.x + position.x + randi_range(-80,80)
			dir = desired_pos - int(position.x)
			if dir != 0:
				dir = dir / abs(dir)
		rot(dir)
		velocity.x = speed * dir * 1.7
	
	if $RayCasts/PlayerDetect.is_colliding():
		current_state = STATE.ATTACK
	move_and_slide()

func rot(dir:int) -> void:
	flip(dir)
	if $RayCasts/RayDown.is_colliding() and not $RayCasts/RayUp.is_colliding():
		velocity.y = -260

func flip(dir: int = 0) -> void:
	if dir == 1:
		$AnimatedSprite.flip_h = false
		$RayCasts/RayDown.target_position.x = 22
		$RayCasts/RayUp.target_position.x = 22
		$AttackSpawner.position.x = 4
		$AttackSpawner.rotation = 0
	else:
		$AnimatedSprite.flip_h = true
		$RayCasts/RayDown.target_position.x = -22
		$RayCasts/RayUp.target_position.x = -22
		$AttackSpawner.position.x = -4
		$AttackSpawner.rotation_degrees = 180

func _on_random_event_timeout() -> void:
	if current_state == STATE.IDLE:
		$RandomEvent.wait_time = randf_range(-1,1) + random_event_timer
		desired_pos = randi_range(-vander_distance,vander_distance)
	elif current_state == STATE.ATTACK:
		if not $RayCasts/PlayerDetect.is_colliding():
			current_state = STATE.IDLE


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
