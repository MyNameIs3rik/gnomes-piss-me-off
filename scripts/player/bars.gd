extends Control

@onready var piss: ProgressBar = $Piss
@onready var water: ProgressBar = $Water
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = %Player

@export var conversion_amount: float = 1.0
@export var conversion_interval: float = 0.1





func _ready() -> void:
	timer.wait_time = conversion_interval
	timer.timeout.connect(_on_convert_timer_timeout)
	timer.start()

func _on_convert_timer_timeout() -> void:
	if player.is_pissing and piss.value > piss.min_value and not player.depleted:
		return
	if piss.value >= piss.max_value:
		return
	if water.value <= 0:
		return
	if player.HP <= 0:
		return

	var amount = min(conversion_amount, water.value)
	amount = min(amount, piss.max_value - piss.value)

	water.value -= amount
	piss.value += amount
