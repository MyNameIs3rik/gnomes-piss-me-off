extends Camera2D

@export var duration:float = 4
@export_range(0,0.5) var easing:float = 0.3
@export var strength:float = 4
var timer = duration

var shaking:bool = false

func _physics_process(delta):
	if shaking:
		if timer < 0:
			shaking = false
			offset = Vector2(0,0)
		else:
			timer -= delta
			if timer > duration - duration * easing :
				var EASE: float = ((timer - duration + duration * easing) / (easing * duration * -1)) + 1
				offset = get_random_offset(strength * EASE)
			elif timer < duration * easing :
				var EASE: float = timer / (easing * duration)
				offset = get_random_offset(strength * EASE)
			else:
				offset = get_random_offset(strength)

func start(dur: float = 4, STR: float = 3, EASE: float = 0.2):
	duration = dur
	timer = dur
	strength = STR
	easing = EASE
	shaking = true

func get_random_offset(STR) -> Vector2:
	var offs = Vector2(randf_range(-STR,STR),randf_range(-STR,STR))
	return offs
