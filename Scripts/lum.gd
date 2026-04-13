extends CharacterBody2D

# --- VARIABLES DE ESTADO ---
var salud := 100
var esta_muriendo := false
var atacando := false
var recibiendo_dano := false

# --- REFERENCIAS ---
@onready var sprite = $Sprite2D
@onready var anim_player = get_node_or_null("AnimationPlayer")
@onready var hitbox1 = $Ataque1
@onready var hitbox2 = $Ataque2

# --- CONSTANTES ---
const SPEED := 300.0
const JUMP_VELOCITY := -300.0

func _ready():
	_desactivar_hitboxes()
	# Conectamos la señal por código para que Lum sepa cuándo dejar de atacar
	if anim_player:
		if not anim_player.animation_finished.is_connected(_on_animation_finished):
			anim_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if esta_muriendo:
		return

	# GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

	# BLOQUEO DE MOVIMIENTO: Si ataca o recibe daño, se queda quieto
	if atacando or recibiendo_dano:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		_procesar_movimiento()

	move_and_slide()
	_controlar_animaciones()

func _procesar_movimiento():
	var dir = Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.x = dir * SPEED

	# VOLTEO DE HITBOXES (Lum mira hacia donde camina)
	if dir != 0:
		sprite.flip_h = (dir < 0)
		var orientacion = sign(dir)
		
		if hitbox1:
			hitbox1.scale.x = orientacion
		if hitbox2:
			hitbox2.scale.x = orientacion
		if has_node("HurtBox"):
			$HurtBox.scale.x = orientacion

func _controlar_animaciones():
	if anim_player == null or esta_muriendo or atacando or recibiendo_dano:
		return

	var dir = Input.get_axis("ui_left", "ui_right")

	# ATAQUES
	if Input.is_action_just_pressed("Ataque1"):
		_ejecutar_ataque("Ataque1", hitbox1)
		return

	if Input.is_action_just_pressed("Ataque2"):
		_ejecutar_ataque("Ataque2", hitbox2)
		return

	# MOVIMIENTO BÁSICO
	if not is_on_floor():
		anim_player.play("Salto")
	elif dir != 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

func _ejecutar_ataque(nombre_anim: String, hitbox_activa: Area2D):
	if anim_player.has_animation(nombre_anim):
		atacando = true
		anim_player.play(nombre_anim)
		if hitbox_activa:
			hitbox_activa.set_deferred("monitoring", true)

func _on_animation_finished(nombre_anim: String):
	# CUANDO TERMINA EL ATAQUE: Lum vuelve a estar libre
	if nombre_anim == "Ataque1" or nombre_anim == "Ataque2":
		atacando = false
		_desactivar_hitboxes()
		print("Lum terminó de atacar, ahora puede moverse.")
	
	if nombre_anim == "Hurt" or nombre_anim == "Daño":
		recibiendo_dano = false

func _desactivar_hitboxes():
	if hitbox1:
		hitbox1.set_deferred("monitoring", false)
	if hitbox2:
		hitbox2.set_deferred("monitoring", false)

func recibir_golpe(dano: int):
	if esta_muriendo:
		return
	
	salud -= dano
	recibiendo_dano = true
	
	if anim_player.has_animation("Hurt"):
		anim_player.play("Hurt")
	
	if salud <= 0:
		_morir()

func _morir():
	esta_muriendo = true
	_desactivar_hitboxes()
	if anim_player.has_animation("Death"):
		anim_player.play("Death")
	else:
		queue_free()

func _on_ataque_1_area_entered(area: Area2D) -> void:
	# Detección de daño a enemigos
	var victima = area.get_parent()
	if victima.has_method("recibir_golpe"):
		victima.recibir_golpe(20)
