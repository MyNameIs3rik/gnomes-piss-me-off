extends Area2D

@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = %Player


#tie na gnomoch mozu mat tie gnome hitboxy len sa mi s tym nechcelo zatial nic ak ich potom este pouzijes
func _on_body_entered(body: Node2D) -> void:
	if not player.is_respawning:
		player.HP -= 100 #100 pre testing zmen potom 
		print('dmg')
	
	
