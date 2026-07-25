extends Area2D

var velocity: Vector2

func _ready():
	monitoring = false
	var size = randf_range(0.7,1.5)
	$Piss.scale = Vector2(size,size)
	$Piss.rotation = randi_range(0,90)

func _process(delta):
	if velocity.y > 10:
		monitoring = true
	velocity.y += 100 * delta
	position += velocity * delta

func _on_area_entered(area):
	area.take_damage(1)
	queue_free()

func _on_body_entered(_body):
	queue_free()
