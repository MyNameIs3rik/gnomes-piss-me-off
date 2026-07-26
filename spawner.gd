extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var torch: Node

@onready var spawn_points = $SpawnPoints.get_children()

var active_enemies: Array = []

func _ready() -> void:
	$SpawnTimer.wait_time = spawn_interval

func _on_spawn_timer_timeout() -> void:
	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))
	
	if not torch.ignited:
		return
	if active_enemies.size() >= max_enemies:
		return
	
	_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	var point = spawn_points[randi() % spawn_points.size()]
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = point.global_position
	active_enemies.append(enemy)
