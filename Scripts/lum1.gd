extends CharacterBody2D

# --- VARIABLES DE ESTADO ---
var salud = 100
var esta_muriendo = false

# --- REFERENCIAS CORREGIDAS ---
@onready var sprite = $Sprite2D
# Ajustado: En tu foto el AnimationPlayer es hijo directo de Lum, no del Sprite
@onready var anim_player = $AnimationPlayer 
@onready var hitbox = %Ataque1 
# Ajustado a "HurtBox" con B mayúscula como en tu árbol de nodos
@onready var hurtbox_col = $HurtBox/CollisionShape2D 

# --- CONSTANTES ---
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta):
	if esta_muriendo: return 

	# 1. GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. SALTO (Usamos "ui_accept" o la tecla que tengas para saltar)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. MOVIMIENTO
	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * SPEED
	
	# 4. GIRO (FLIP)
	if dir != 0:
		sprite.flip_h = (dir < 0)
		hitbox.scale.x = sign(dir)
		# Usamos $HurtBox con B mayúscula
		if has_node("HurtBox"):
			$HurtBox.scale.x = sign(dir)

	move_and_slide()
	controlar_animaciones(dir)

# --- SISTEMA DE DAÑO ---

func recibir_golpe(daño_recibido):
	if esta_muriendo: return
	
	salud -= daño_recibido
	print("Vida restante de Lum: ", salud)

	if anim_player.has_animation("Hurt"):
		anim_player.play("Hurt")
	
	# Empujón (Knockback)
	velocity.x = -200 if sprite.flip_h == false else 200
	move_and_slide()

	activar_invencibilidad()

	if salud <= 0:
		morir()

func activar_invencibilidad():
	if hurtbox_col:
		hurtbox_col.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	await get_tree().create_timer(0.5).timeout 
	
	if hurtbox_col:
		hurtbox_col.set_deferred("disabled", false)

func morir():
	esta_muriendo = true
	if anim_player.has_animation("Death"):
		anim_player.play("Death")
	else:
		print("Lum ha muerto")
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()

# --- CONTROL DE ANIMACIONES ---

func controlar_animaciones(dir):
	if anim_player == null: return 
	if esta_muriendo: return
	
	# No interrumpir si está recibiendo daño o atacando
	if (anim_player.current_animation == "Hurt" or anim_player.current_animation == "Ataque") and anim_player.is_playing():
		return

	if Input.is_key_pressed(KEY_F):
		anim_player.play("Ataque")
		return

	if not is_on_floor():
		anim_player.play("Salto")
	elif dir != 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

# --- SEÑALES ---

# Asegúrate de conectar el Area2D llamado HurtBox a esta función
func _on_hurt_box_area_entered(area: Area2D) -> void:
	# Evitamos que Lum se golpee a sí mismo con su propia espada
	if area.is_in_group("ataque_enemigo"):
		recibir_golpe(10)

# Asegúrate de conectar el Area2D llamado Ataque1 a esta función
func _on_ataque_1_area_entered(area: Area2D) -> void:
	var victima = area.get_parent()
	if victima.has_method("recibir_golpe"):
		victima.recibir_golpe(20)
