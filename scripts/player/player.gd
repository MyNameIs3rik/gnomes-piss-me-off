extends CharacterBody2D

#stats
var max_water: int = 100
var water: float = 0.0
var max_piss: int = 100
var piss: float = 0.0
var max_health: int = 10
var health: int = max_health

#physics
var MAX_SPEED: int = 120
var ACCELERATION:int = 15
var JUMP:int = 25
var friction: int = 25
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

#imports
@onready var animation: AnimatedSprite2D = $animation

@onready var water_bar = $CanvasLayer/WaterBar
@onready var piss_bar = $CanvasLayer/PissBar

enum STATE {
	DEFAULT,
	PISSING
}

var current_state = STATE.DEFAULT

func _ready() -> void:
	water_bar.value = water
	piss_bar.value = piss

func _physics_process(delta):
	if is_on_floor() and current_state == STATE.DEFAULT and Input.is_action_pressed("Piss"):
		water = 50
		
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	elif Input.is_action_just_pressed("Up") :
		velocity.y = JUMP * -10
	
	var dir:int = int(Input.get_axis("Left","Right"))
	
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
		
	if dir == 0:
		animation.play("idle")
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
