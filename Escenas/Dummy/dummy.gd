extends Area2D

@onready var ani = $Sprite2D/AnimationPlayer

#DETECTA SI UN AREA 2D ENTRÓ AL AREA 2D DE MI ENEMIGO
func _on_area_entered(area):
	if area.is_in_group("P_Punch"): #ESTO ES PARA VERIFICAR EL ORIGEN DEL AREA 2D INTRUSA
		_ani_change() #ESTO EJECUTA LA FUNCIÓN DE CAMBIO DE ANIMACION

func _ani_change(): #REINICIA LA ANIMACIÓN DE LA MARIONETA GOLPEADA
	var ani_current = ani.current_animation
	if ani_current == "Hit":
		ani.play("Idle")
		ani.play("Hit")
	else:
		ani.play("Hit")



func _on_animation_player_animation_finished(anim_name): #SE EJECUTA CADA VEZ QUE UNA ANIMACIÓN TERMINA
	match anim_name:
		"Hit":
			ani.play("Idle")
