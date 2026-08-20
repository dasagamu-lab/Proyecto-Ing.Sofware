extends CharacterBody2D
class_name Jugador

# VELOCIDADES Y FÍSICAS (Compartidas)
var intVX : int = 10000
var intVY : int = 480
var intVX_Dash : int = 18000
var Jump_Height : int = 240

var max_coyote_time : float = 0.2
var coyote_time : float = 0.0

# ESTADÍSTICAS GLOBALES
var vida : int = 100
var fuerza_golpe : int = 120

# ESTADOS GLOBALES
var estado : String = "Normal"
var intMove : int = 0
var Can_Dash : int = 2

# NODOS VISUALES
@onready var ani = $AnimatedSprite2D
@onready var mirror = $AnimatedSprite2D


func Hit(posicion_atacante = null):
	if estado == "Muerto" or estado == "Hit":
		return

	estado = "Hit"

	if posicion_atacante != null:
		if posicion_atacante.x < global_position.x:
			velocity.x = fuerza_golpe
		else:
			velocity.x = -fuerza_golpe
	else:
		var dir = -1 if mirror.flip_h else 1
		velocity.x = -dir * fuerza_golpe

	ani.play("Hit")

func _on_hurtbox_area_entered(area: Area2D):
	print(name + " RECIBIO GOLPE")
	
	if estado == "Muerto":
		return

	if area.is_in_group("P_Punch"):
		vida -= 10
		if vida <= 0:
			vida = 0
			estado = "Muerto"
			ani.play("Caida")
		else:
			Hit(area.global_position)

func _ani_change():
	if estado == "Muerto":
		return
	if ani.current_animation == "Hit":
		ani.play("Idle")
	ani.play("Hit")
