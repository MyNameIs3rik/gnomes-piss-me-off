extends Node2D

@onready var pole = $Items/Pole
@onready var cam = $Player/Camera

func _ready():
	$Helpers/Timer.start()

func _on_timer_timeout():
	cam.start(6,3,0.25)
	pole.play_impale()
