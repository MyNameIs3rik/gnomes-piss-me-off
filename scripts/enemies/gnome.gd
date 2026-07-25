extends CharacterBody2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * 0.9
		if velocity.y > 400:
			velocity.y = 400
	move_and_slide()
