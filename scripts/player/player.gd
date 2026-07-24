extends CharacterBody2D
#stats
var attack_rate = 1
var respawn_rate = 2
var DMG: int = 5
var HP: int = 100
#physics
var MAX_SPEED: int = 120
var ACCELERATION:int = 15
var JUMP:int = 25
var friction: int = 25
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

#mechanics
var is_pissing: bool = false
var depleted: bool = false
var is_respawning: bool = false
var is_attacking: bool = false

#imports
@onready var attack_timer: Timer = $attack_timer
@onready var timer: Timer = $Timer
@onready var animation: AnimatedSprite2D = $animation
@onready var piss: ProgressBar = %Piss
@onready var water: ProgressBar = %Water
@export var piss_amount: float = 1.0
@export var min_to_resume: float = 7.0


func _ready() -> void:
	timer.one_shot = true
	attack_timer.one_shot = true
	
	timer.timeout.connect(_on_respawn_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if HP <= 0 and not is_respawning:
		_start_death()

	if is_respawning:
		velocity.x = 0
		move_and_slide()
		return
		
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	elif Input.is_action_just_pressed("Up") :
		velocity.y = JUMP * -10
	
	var dir:int = int(Input.get_axis("Left","Right"))

	is_pissing = Input.is_action_pressed('Piss')
	if Input.is_action_just_pressed('Attack') and not is_attacking and not is_respawning:
		_start_attack()
		move_and_slide()
		return
	
	
		
		
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
	if depleted and piss.value >= min_to_resume and HP > 0:
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
func _start_death() -> void:
	is_respawning = true
	piss.value = 0
	water.value = 0
	depleted = true
	velocity = Vector2.ZERO
	animation.play("death")
	timer.wait_time = respawn_rate
	timer.start()
	print('hell naw')

func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	animation.play('attack')
	attack_timer.wait_time = attack_rate
	attack_timer.start()
	
	
func _on_attack_timer_timeout() -> void:
	is_attacking = false


func _on_respawn_timer_timeout() -> void:
	print('resp')
	HP = 100
	is_respawning = false
	
