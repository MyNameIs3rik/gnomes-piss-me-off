extends CharacterBody2D

var MAX_SPEED: int = 120
var ACCELERATION:int = 15
var JUMP:int = 25

var friction: int = 25
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	elif Input.is_action_just_pressed("Up") :
		velocity.y = JUMP * -10
	
	var dir:int = int(Input.get_axis("Left","Right"))
	
	if dir == 1:
		var helper = 1
		if velocity.x < 0:
			helper = 2
		velocity.x += ACCELERATION * helper
		if velocity.x >= MAX_SPEED:
			velocity.x = MAX_SPEED
	elif dir == -1:
		var helper = 1
		if velocity.x > 0:
			helper = 2
		velocity.x -= ACCELERATION * helper
		if velocity.x <= -MAX_SPEED:
			velocity.x = -MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	
	move_and_slide()
