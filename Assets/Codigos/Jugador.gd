extends CharacterBody2D
class_name Jugador

@export var player_id : int = 1

# Diccionario de controles: qué acción de Input usa este jugador
# según sea P1 o P2. Se arma al entrar a la escena — por eso
# player_id debe estar puesto ANTES de add_child().
var inputs := {}

func _ready():
	if player_id == 1:
		inputs = {
			"ataque_debil": "Ataque_1",
			"ataque_medio": "Ataque_2",
			"bloqueo": "Bloqueo",
			"especial": "Especial",
			"abajo": "Abajo",
			"derecha": "Derecha",
			"izquierda": "Izquierda",
			"dash": "Dash",
			"salto": "Saltar"
		}
	else:
		inputs = {
			"ataque_debil": "ataque_debil_P2",
			"ataque_medio": "ataque_medio_P2",
			"bloqueo": "Bloqueo_P2",
			"especial": "Especial_P2",
			"abajo": "Abajo_P2",
			"derecha": "Derecha_P2",
			"izquierda": "Izquierda_P2",
			"dash": "Dash_P2",
			"salto": "Salto_P2"
		}


# VELOCIDADES Y FÍSICAS (Compartidas)
var intVX : int = 10000
var intVY : int = 480
var intVX_Dash : int = 18000
var Jump_Height : int = 240

var max_coyote_time : float = 0.2
var coyote_time : float = 0.0

var Time_Actual_Dupli : float = 0
var Time_Dupli : float = 0.05
var Time_Life_Dupli : float = 0.2

var sprite_pos_atacando = Vector2.ZERO


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
	
func _animaciones():
	if intMove == -1:
		mirror.scale.x = -1
		$Col_Daño.scale.x = -1
	elif intMove == 1:
		mirror.scale.x = 1
		$Col_Daño.scale.x = 1
		
		
func mirar_hacia(dir: int):
	mirror.scale.x = dir
	$Col_Daño.scale.x = dir
