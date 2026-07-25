extends Area2D

@export_range(0.5,10) var ignition_timer_delay: float = 5
var max_fire_count: int = 15
var fire_count: int = 0
var wet: int = 0
var ignited: bool = false

const FIRE = preload("res://scenes/enemies/fire.tscn")
@onready var fire_container = $FireContainer
@onready var area = $CollisionPolygon2D
@onready var rng = RandomNumberGenerator.new()

func _ready():
	$RandomIgnition.wait_time = ignition_timer_delay

func play_impale() -> void:
	$AnimationPlayer.play("Impale")

func ignite() -> void:
	ignited = true
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
	if fire_count <= 0:
		ignited = false
		fire_count = 0



func _on_random_ignition_timeout() -> void:
	if wet > 0:
		wet -= 1
	elif ignited:
		ignite()


func _on_area_entered(_area):
	wet = 5
