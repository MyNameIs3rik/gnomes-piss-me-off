extends Area2D

@export_range(0.5,10) var ignition_timer_delay: float = 5
var max_fire_count: int = 3
var fire_count: int = 0
var wet: int = 0
var ignited: bool = false

const FIRE = preload("res://scenes/enemies/fire.tscn")
@onready var fire_container = $FireContainer
@onready var area: CollisionShape2D = $CollisionShape2D
@onready var rng = RandomNumberGenerator.new()

func _ready():
	$RandomIgnition.wait_time = ignition_timer_delay
	ignite()

func ignite() -> void:
	ignited = true
	if fire_count >= max_fire_count:
		return
	var fire = FIRE.instantiate()
	fire.fire_place = self
	fire.position = get_random_pos()
	fire_container.add_child(fire)
	fire.ignite()
	fire_count += 1

func get_random_pos() -> Vector2:
	var shape: RectangleShape2D = area.shape
	var half_size = shape.size / 2.0
	var local_point = Vector2(
		rng.randf_range(-half_size.x, half_size.x),
		rng.randf_range(-half_size.y, half_size.y)
	)
	return area.position + local_point

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
