extends CharacterBody2D

# --- VARIABLES ---
var salud = 100
var esta_muerto = false

# --- REFERENCIAS ---
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	# Empieza en Idle
	if anim.has_animation("idle"):
		anim.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

# --- RECIBIR DAÑO ---
func recibir_golpe(cantidad):
	if esta_muerto:
		return
	
	salud -= cantidad
	print("Dummy golpeado! Vida:", salud)

	# Flash rojo
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	# Animación de daño
	if anim.has_animation("dano"):
		anim.stop()
		anim.play("dano")
		await anim.animation_finished
		
		if not esta_muerto:
			anim.play("idle")

	if salud <= 0:
		morir()

func morir():
	esta_muerto = true
	print("Dummy destruido")

	if anim.has_animation("dead"):
		anim.play("dead")
		await anim.animation_finished

	queue_free()
