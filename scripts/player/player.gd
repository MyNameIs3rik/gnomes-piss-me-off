extends CharacterBody2D

var MAX_SPEED: int = 120
var ACCELERATION:int = 15
var JUMP:int = 25
var friction: int = 25
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_pissing: bool = false
var depleted: bool = false

@onready var animation: AnimatedSprite2D = $animation
@onready var piss: ProgressBar = %Piss
@export var piss_amount: float = 1.0
@export var min_to_resume: float = 7.0







func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	elif Input.is_action_just_pressed("Up") :
		velocity.y = JUMP * -10
	
	var dir:int = int(Input.get_axis("Left","Right"))

	is_pissing = Input.is_action_pressed('Piss')
	
	
	
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
	#jump mozno neskor
	if depleted and piss.value >= min_to_resume:
		depleted = false
		
	if is_pissing and not depleted:
		animation.play("pee")
		piss.value -= piss_amount
		if piss.value <= piss.min_value:
				depleted = true
	
		 
	elif dir == 0:
		animation.play("idle")
	elif dir == 1 or dir == -1:
		animation.play("walk")
	
	move_and_slide()
