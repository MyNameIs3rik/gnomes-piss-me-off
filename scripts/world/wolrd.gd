extends Node2D

func _ready():
	$Helpers/Timer.start()

func _on_timer_timeout():
	$Player/Camera.start(6,3,0.25)
	$Items/Pole.play_impale()
