extends Area2D

var max_fire_count: int = 15
var fire_count: int = 0

const FIRE = preload("res://scenes/enemies/fire.tscn")
@onready var fire_container = $FireContainer
@onready var area = $CollisionPolygon2D
@onready var rng = RandomNumberGenerator.new()

func play_impale() -> void:
	$AnimationPlayer.play("Impale")

func ignite():
	if fire_count >= max_fire_count:
		return
	var fire = FIRE.instantiate()
	fire.fire_place = self
	fire.position = get_random_pos(area.polygon)
	fire.ignite()
	fire_container.add_child(fire)
	fire_count += 1

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

func decrement() -> void:
	fire_count -= 1
	print("decrement")
