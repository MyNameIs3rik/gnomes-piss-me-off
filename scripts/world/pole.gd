extends Area2D

const FIRE = preload("res://scenes/enemies/fire.tscn")
@onready var fire_container = $FireContainer
@onready var area = $CollisionPolygon2D
@onready var rng = RandomNumberGenerator.new()

func play_impale() -> void:
	$AnimationPlayer.play("Impale")

func ignite():
	var fire = FIRE.instantiate()
	fire.position = get_random_pos(area.polygon)
	fire.ignite()
	fire_container.add_child(fire)

func get_random_pos(points: PackedVector2Array) -> Vector2:
	var rect = Rect2(points[0], Vector2.ZERO)
	
	for point in points:
		rect = rect.expand(point)
	
	while true:
		var point = Vector2(
		rng.randf_range(rect.position.x, rect.end.x),
		rng.randf_range(rect.position.y, rect.end.y))
		
		if Geometry2D.is_point_in_polygon(point, points):
			return point

	return Vector2.ZERO
