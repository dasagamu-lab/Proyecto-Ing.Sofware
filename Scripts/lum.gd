extends CharacterBody2D

# --- VARIABLES ---
var salud := 100
var esta_muriendo := false
var atacando := false
var recibiendo_dano := false  # 🚨 Flag para controlar animación de daño

# --- REFERENCIAS ---
@onready var sprite = $Sprite2D
@onready var anim_player = $Sprite2D/AnimationPlayer
@onready var hitbox1 = $Ataque1
@onready var hitbox2 = $Ataque2 

# --- CONSTANTES ---
const SPEED := 300.0
const JUMP_VELOCITY := -300.0

# --- READY ---
func _ready():
	_desactivar_hitboxes()
	anim_player.animation_finished.connect(_on_animation_finished)

# --- PHYSICS PROCESS ---
func _physics_process(delta: float) -> void:
	if esta_muriendo:
		return

	_aplicar_gravedad(delta)

	if atacando or recibiendo_dano:
		velocity.x = 0
	else:
		_procesar_movimiento()

	move_and_slide()
	_controlar_animaciones()

# --- MOVIMIENTO ---
func _aplicar_gravedad(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func _procesar_movimiento():
	var dir = Input.get_axis("ui_left", "ui_right")

	# SALTO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# MOVIMIENTO HORIZONTAL
	velocity.x = dir * SPEED

	# GIRAR PERSONAJE Y HITBOXES
	if dir != 0:
		sprite.flip_h = dir < 0
		var direccion = -1 if dir < 0 else 1
		if hitbox1:
			hitbox1.position.x = abs(hitbox1.position.x) * direccion
		if hitbox2:
			hitbox2.position.x = abs(hitbox2.position.x) * direccion

# --- ANIMACIONES ---
func _controlar_animaciones():
	if esta_muriendo or atacando or recibiendo_dano:
		return

	var dir = Input.get_axis("ui_left", "ui_right")

	# Ataques
	if Input.is_action_just_pressed("Ataque1") and is_on_floor():
		_ejecutar_ataque("Ataque1", hitbox1)
		return
	if Input.is_action_just_pressed("Ataque2") and is_on_floor():
		_ejecutar_ataque("Ataque2", hitbox2)
		return

	# Locomoción
	if not is_on_floor():
		anim_player.play("Salto")
	elif dir != 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

# --- ATAQUES ---
func _ejecutar_ataque(nombre_animacion: String, hitbox: Area2D):
	atacando = true
	anim_player.play(nombre_animacion)
	if hitbox:
		hitbox.set_deferred("monitoring", true)

func _on_animation_finished(nombre_anim: String):
	print("Anim terminó:", nombre_anim)
	# Reset ataques
	if nombre_anim == "Ataque1" or nombre_anim == "Ataque2":
		atacando = false
		_desactivar_hitboxes()
	# Reset daño
	if nombre_anim == "Daño":
		recibiendo_dano = false

func _desactivar_hitboxes():
	if hitbox1:
		hitbox1.set_deferred("monitoring", false)
	if hitbox2:
		hitbox2.set_deferred("monitoring", false)

# --- RECIBIR DAÑO ---
func recibir_golpe(dano: int):
	if esta_muriendo:
		return

	salud -= dano
	print("Lum recibió golpe. Vida restante: ", salud)

	# Reproducir animación de daño si no está muriendo ni atacando
	if not recibiendo_dano and not atacando:
		recibiendo_dano = true
		anim_player.play("Daño")

	if salud <= 0:
		morir()

func morir():
	print("Lum ha muerto")
	esta_muriendo = true
	_desactivar_hitboxes()
	# anim_player.play("Muerte")  # Descomenta si tienes animación de muerte

# --- DAÑO DE HITBOXES ---
func _on_ataque_1_area_entered(area: Area2D):
	_procesar_dano(area, 20)

func _on_ataque_2_area_entered(area: Area2D):
	_procesar_dano(area, 35)

func _procesar_dano(area: Area2D, cantidad: int):
	var victima = area.get_parent()
	if victima.has_method("recibir_golpe"):
		victima.recibir_golpe(cantidad)
