extends CharacterBody2D

var salud = 100

const SPEED = 300.0
const JUMP_VELOCITY = -300.0

@onready var sprite = $Sprite2D
@onready var anim_player = $Sprite2D/AnimationPlayer
@onready var hitbox1 = $Ataque1
@onready var hitbox2 = $Ataque2

func _ready():
	if hitbox1: hitbox1.monitoring = false
	if hitbox2: hitbox2.monitoring = false

func _physics_process(delta):
	# GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

	# MOVIMIENTO (IJKL)
	var dir = 0
	
	if Input.is_key_pressed(KEY_J):
		dir -= 1
	if Input.is_key_pressed(KEY_L):
		dir += 1

	velocity.x = dir * SPEED

	# SALTO (I)
	if Input.is_key_pressed(KEY_I) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

	controlar_animaciones(dir)

func controlar_animaciones(dir):

	# GIRAR PERSONAJE + HITBOXES
	if dir != 0:
		sprite.flip_h = (dir < 0)

		var escala_x = -1 if dir < 0 else 1
		
		if hitbox1:
			hitbox1.scale.x = escala_x
		if hitbox2:
			hitbox2.scale.x = escala_x

	# ATAQUE
	if Input.is_key_pressed(KEY_H):
		anim_player.play("Ataque1")
		hitbox1.monitoring = true
		await get_tree().create_timer(0.2).timeout
		hitbox1.monitoring = false
		return

	# MOVIMIENTO
	if not is_on_floor():
		anim_player.play("Salto")
	elif dir != 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

# 🔥 RECIBIR DAÑO
func recibir_golpe(cantidad):
	salud -= cantidad
	print(name, " recibió daño, vida restante: ", salud)

	# DISPARAR ANIMACIÓN DE DAÑO
	if salud > 0:
		anim_player.play("Hurt") # Cambia "Hurt" por el nombre exacto de tu animación
	
	if salud <= 0:
		morir()

	if salud <= 0:
		morir()

func morir():
	print("Cerve murió 💀")


func _on_ataque_1_body_entered(body):
	# Si lo que tocamos tiene la función recibir_golpe y no soy yo mismo...
	if body.has_method("recibir_golpe") and body != self:
		body.recibir_golpe(10) # El daño que quieras
		
