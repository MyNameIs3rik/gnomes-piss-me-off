extends CharacterBody2D

@export_range(3,15) var random_event_timer: float = 5
@export_range(0,15) var attack_cooldown: float = 4
@export var speed: int = 70
@export var vander_distance: int = 200

const ATTACK_RANGE := 30.0
const ATTACK_SPEED_MULTIPLIER := 1.8
const CIRCLE_DISTANCE := 80.0
const ARRIVAL_DISTANCE := 5.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var STAB = preload("res://scenes/enemies/showel_stab.tscn")

@onready var player = %Player

var can_attack: bool = true
var desired_pos: int = 0

enum STATE {
	IDLE,
	PANIC,
	ATTACK,
	DEAD
}

var current_state = STATE.IDLE

func _ready() -> void:
	$RandomEvent.wait_time = random_event_timer
	$AttackCooldown.wait_time = attack_cooldown
	$RandomEvent.start()
	$AnimatedSprite.play("Idle")

	choose_idle_position()


func _physics_process(delta: float) -> void:

	# --------------------------------
	# GRAVITY
	# --------------------------------

	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		velocity.y = min(velocity.y, 400.0)
	
	if current_state == STATE.DEAD:
		if $AnimatedSprite.flip_h == true:
			rotation += 7*delta
		else:
			rotation -= 7*delta
		move_and_slide()
		return


	# --------------------------------
	# PLAYER DETECTION
	# --------------------------------

	if $RayCasts/PlayerDetect.is_colliding():
		current_state = STATE.ATTACK
	elif current_state == STATE.ATTACK:
		current_state = STATE.IDLE


	# --------------------------------
	# STATE LOGIC
	# --------------------------------

	match current_state:

		STATE.IDLE:
			handle_idle()

		STATE.ATTACK:
			handle_attack()


	# --------------------------------
	# MOVEMENT
	# --------------------------------

	move_towards_target()


	move_and_slide()


# ============================================================
# IDLE
# ============================================================

func handle_idle() -> void:

	# If we reached our wandering destination,
	# stop until the next random event.
	if abs(global_position.x - desired_pos) <= ARRIVAL_DISTANCE:
		velocity.x = move_toward(velocity.x, 0.0, speed * 0.2)


# ============================================================
# ATTACK
# ============================================================

func handle_attack() -> void:

	var distance_to_player := global_position.distance_to(player.global_position)

	# --------------------------------
	# CLOSE ENOUGH TO ATTACK
	# --------------------------------

	if distance_to_player <= ATTACK_RANGE:

		if can_attack:
			attack()

		# Regardless of whether attack is ready,
		# choose somewhere around the player to run toward.
		if abs(global_position.x - desired_pos) <= ARRIVAL_DISTANCE:
			choose_attack_position()

	else:

		# Player is too far away → chase them.
		desired_pos = player.global_position.x


# ============================================================
# MOVEMENT
# ============================================================

func move_towards_target() -> void:

	var difference := desired_pos - global_position.x

	if abs(difference) <= ARRIVAL_DISTANCE:
		velocity.x = move_toward(velocity.x, 0.0, 20.0)
		return

	@warning_ignore("narrowing_conversion")
	var direction := signi(difference)

	# Faster while attacking
	var current_speed := speed

	if current_state == STATE.ATTACK:
		@warning_ignore("narrowing_conversion")
		current_speed *= ATTACK_SPEED_MULTIPLIER

	velocity.x = move_toward(
		velocity.x,
		direction * current_speed,
		20.0
	)

	rot(direction)


# ============================================================
# ATTACK
# ============================================================

func attack() -> void:

	can_attack = false
	$AttackCooldown.start()

	var stab = STAB.instantiate()
	$AttackSpawner.add_child(stab)

	# Immediately choose where to run after attacking.
	choose_attack_position()


# ============================================================
# CHOOSE ATTACK POSITION
# ============================================================

func choose_attack_position() -> void:

	var offset := randf_range(-CIRCLE_DISTANCE, CIRCLE_DISTANCE)

	desired_pos = player.global_position.x + offset


# ============================================================
# CHOOSE IDLE POSITION
# ============================================================

func choose_idle_position() -> void:

	@warning_ignore("narrowing_conversion")
	desired_pos = global_position.x + randf_range(
		-vander_distance,
		vander_distance
	)


# ============================================================
# ROTATION / JUMPING
# ============================================================

func rot(dir: float) -> void:

	if dir == 0:
		return

	flip(dir)

	# Jump over an obstacle when moving toward it.
	if is_on_floor():
		if $RayCasts/RayDown.is_colliding() \
		and not $RayCasts/RayUp.is_colliding():
			velocity.y = -260


# ============================================================
# FLIP
# ============================================================

func flip(dir: float = 0) -> void:

	if dir >= 0:

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


# ============================================================
# RANDOM EVENT
# ============================================================

func _on_random_event_timeout() -> void:
	if current_state == STATE.IDLE:
		$RandomEvent.wait_time = (
			random_event_timer + randf_range(-1.0, 1.0)
		)
		choose_idle_position()


# ============================================================
# ATTACK COOLDOWN
# ============================================================

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func die() -> void:
	current_state = STATE.DEAD
	$CollisionShape2D.set_deferred("disabled",true)
	velocity = Vector2(randf_range(-150,150),randf_range(-150,-300))
	$DeathTimer.start()


func _on_death_timer_timeout() -> void:
	queue_free()
