extends Area2D

@onready var ani = $Sprite2D/AnimationPlayer

func _on_area_entered(area):
	print(area.name)

	if area.is_in_group("P_Punch"):
		print("GOLPE RECIBIDO")
		_ani_change()

func _ani_change():
	var ani_current = ani.current_animation

	if ani_current == "Hit":
		ani.play("Idle")
		ani.play("Hit")
	else:
		ani.play("Hit")

func _on_animation_player_animation_finished(anim_name):
	print("Terminó:", anim_name)

	match anim_name:
		"Hit":
			ani.play("Idle")
