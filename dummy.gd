extends CharacterBody2D

# --- VARIABLES ---
var salud = 60
var esta_muerto = false

# --- REFERENCIAS ---
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	# Al aparecer, que siempre empiece con su animación de Idle
	if anim.has_animation("Idle"):
		anim.play("Idle")

func _physics_process(delta):
	# Solo le aplicamos gravedad por si lo pones en el aire, para que caiga al suelo
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# No le ponemos controles de movimiento porque es un Dummy
	move_and_slide()

# --- ESTA FUNCIÓN LA LLAMARÁ LUM CUANDO LO GOLPEE ---
func recibir_golpe(cantidad):
	if esta_muerto: return
	
	salud -= cantidad
	print("Dummy golpeado! Vida: ", salud)

	# 1. Efecto visual de "Flash" (se pone rojo y vuelve a la normalidad)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	# 2. Ejecutar su animación de daño (la que llamaste "dano")
	if anim.has_animation("dano"):
		anim.play("dano")
		# Esperamos a que termine la animación de daño para volver a Idle
		await anim.animation_finished
		if not esta_muerto:
			anim.play("Idle")

	# 3. Revisar si ya no tiene vida
	if salud <= 0:
		morir()

func morir():
	esta_muerto = true
	print("Dummy destruido")
	
	# Si tienes animación de muerte, úsala. Si no, que desaparezca.
	if anim.has_animation("Dead"):
		anim.play("Dead")
		await anim.animation_finished
	
	queue_free() # Elimina al dummy del juego
