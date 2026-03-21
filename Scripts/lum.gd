extends CharacterBody2D

# --- VARIABLES ---
var salud = 100
var esta_muriendo = false

# --- REFERENCIAS ---
@onready var sprite = $Sprite2D
@onready var anim_player = $Sprite2D/AnimationPlayer
@onready var hitbox = $Ataque1
@onready var hurtbox_col = $HurtBox/CollisionShape2D

# --- CONSTANTES ---
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	hitbox.monitoring = false # 🔴 MUY IMPORTANTE

func _physics_process(delta):
	if esta_muriendo:
		return

	# GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

	# SALTO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# MOVIMIENTO
	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * SPEED

	# GIRAR PERSONAJE
	if dir != 0:
		sprite.flip_h = (dir < 0)

	move_and_slide()
	controlar_animaciones(dir)

# --- ATAQUE ---
func atacar():
	anim_player.play("Ataque1")
	hitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false

# --- RECIBIR DAÑO ---
func recibir_golpe(daño):
	if esta_muriendo:
		return

	salud -= daño
	print("Vida restante de Lum: ", salud)
	anim_player.play("Hurt")

	if salud <= 0:
		morir()

func morir():
	esta_muriendo = true
	anim_player.play("Death")

# --- ANIMACIONES ---
# --- ANIMACIONES ---
func controlar_animaciones(dir):
	if esta_muriendo:
		return

	# 1. NO interrumpir si ya está haciendo algo importante
	if anim_player.is_playing():
		if anim_player.current_animation == "Ataque1" or anim_player.current_animation == "Hurt":
			return

	# 2. ATAQUE (Si presionas F, ataca y se sale de la función)
	if Input.is_key_pressed(KEY_F):
		atacar()
		return # <--- Este return DEBE tener dos pestañas (Tabs) para estar dentro del IF

	# 3. MOVIMIENTO (Solo llega aquí si NO se ejecutó el return de arriba)
	if not is_on_floor():
		anim_player.play("Salto")
	elif dir != 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

	if not is_on_floor():
		anim_player.play("Salto")
	elif dir != 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

# --- CUANDO GOLPEA AL DUMMY ---
func _on_ataque_1_area_entered(area: Area2D) -> void:
	var victima = area.get_parent()
	if victima.has_method("recibir_golpe"):
		victima.recibir_golpe(20)
