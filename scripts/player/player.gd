extends CharacterBody2D

#stats
@export var pee_delay: float = 0.08
var max_water: int = 100
var water: float = 0.0
var max_piss: int = 100
var piss: float = 0.0
var max_health: int = 10
var health: int = max_health
var can_attack: bool = true

var can_pee: bool = true

#physics
var MAX_SPEED: int = 120
var ACCELERATION:int = 15
var JUMP:int = 25
var friction: int = 25
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

#imports
var Showel = preload("res://scenes/player/showel.tscn")
@onready var animation: AnimatedSprite2D = $animation
@onready var Aplayer = $AnimationPlayer
@onready var water_bar = $CanvasLayer/WaterBar
@onready var piss_bar = $CanvasLayer/PissBar

const PEE = preload("res://scenes/player/pee.tscn")

enum STATE {
	DEFAULT,
	ATTACKING,
	ZIPPING,
	PISSING,
	DEAD,
	JUMPING
}

@export var current_state = STATE.DEFAULT

func _ready() -> void:
	$PeeDelay.wait_time = pee_delay
	water_bar.value = water
	piss_bar.value = piss

func _physics_process(delta):
	#temp
	if is_on_floor() and current_state == STATE.DEFAULT and Input.is_action_pressed("Piss"):
		water = 50
	
	if Input.is_action_just_pressed("Attack"):
		if can_attack:
			var shovel = Showel.instantiate()
			if $animation.flip_h == true:
				shovel.scale.x = -1
			add_child(shovel)
			can_attack = false
			$AttackDelay.start()
	
	if current_state == STATE.PISSING and not Input.is_action_pressed("RightClick"):
		current_state = STATE.ZIPPING
		Aplayer.play("zip_up")
	elif current_state == STATE.PISSING and piss < 0.5:
		piss = 0
		current_state = STATE.ZIPPING
		Aplayer.play("zip_up")
	elif current_state == STATE.PISSING and Input.is_action_pressed("RightClick"):
		piss -= delta * 8
		if can_pee:
			can_pee = false
			$PeeDelay.start()
			var piss_dir: Vector2 = get_global_mouse_position() - global_position
			var piss_intensity: int = clamp(piss_dir.length(),20,60) 
			piss_dir = piss_dir.normalized()
			var pee = PEE.instantiate()
			pee.position = position
			pee.velocity = Vector2(0.6 * piss_dir.x * piss_intensity,-50 -0.8 * piss_intensity)
			get_parent().add_child(pee)
	
	if is_on_floor() and current_state == STATE.DEFAULT and Input.is_action_pressed("RightClick") and piss > 10:
		current_state = STATE.ZIPPING
		Aplayer.play("zip_down")
	
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
		current_state = STATE.JUMPING
	elif current_state == STATE.JUMPING:
		current_state = STATE.DEFAULT
	elif Input.is_action_just_pressed("Up") and current_state == STATE.DEFAULT:
		velocity.y = JUMP * -10
	
	var dir:int = int(Input.get_axis("Left","Right"))
	if current_state != STATE.DEFAULT and current_state != STATE.JUMPING:
		dir = 0
	
	if dir == 1:
		var helper = 1
		animation.flip_h = false
		if velocity.x < 0:
			helper = 2
		velocity.x += ACCELERATION * helper
		if velocity.x >= MAX_SPEED:
			velocity.x = MAX_SPEED
	elif dir == -1:
		animation.flip_h = true
		var helper = 1
		if velocity.x > 0:
			helper = 2
		velocity.x -= ACCELERATION * helper
		if velocity.x <= -MAX_SPEED:
			velocity.x = -MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
		
	if dir == 0 and current_state == STATE.DEFAULT:
		animation.play("idle")
	elif current_state == STATE.JUMPING:
		animation.play('jump')
	elif dir == 1 or dir == -1:
		animation.play("walk")
	
	end_process(delta)

func end_process(delta) -> void:
	convert_fluids(delta)
	update_bars()
	move_and_slide()

func update_bars() -> void:
	water_bar.value = water
	piss_bar.value = piss

func convert_fluids(delta) -> void:
	if water > 0:
		water -= delta * 6
		piss += delta * 3
		if water < 0:
			water = 0
		if piss > 100:
			piss = 100


func _on_pee_delay_timeout():
	can_pee = true

func take_damage():
	print("damage_taken")


func _on_attack_delay_timeout():
	can_attack = true
