extends Jugador
class_name Lum

# ATAQUES Y HABILIDADES EXCLUSIVAS DEL JUGADOR
var Especial = preload("res://Assets/Escenas/Lum/especial.tscn")
var counter_hit : int = 0
var ataque_actual : String = ""

# EFECTOS DASH (Visuales propios de Lum)
var Time_Actual_Dupli : float = 0
var Time_Dupli : float = 0.05
var Time_Life_Dupli : float = 0.2

var sprite_pos_atacando = Vector2.ZERO

# ---------------------------------------------------------
# CONTROLES Y FÍSICAS EXCLUSIVAS
# ---------------------------------------------------------
func _input(event):
	if Input.is_action_just_pressed("Atacar"):
		if is_on_floor() and estado != "Bloqueando" and estado != "Atacando":
			estado = "Atacando"
			ataque_actual = "Ataque_1"
			ani.play(ataque_actual, 1.8)
			$AnimationPlayer.play(ataque_actual)

	if Input.is_action_just_pressed("Ataque_2"):
		if is_on_floor() and estado != "Bloqueando" and estado != "Atacando":
			estado = "Atacando"
			ataque_actual = "Ataque_2"
			ani.play(ataque_actual, 1.8)
			$AnimationPlayer.play(ataque_actual)

	if Input.is_action_pressed("Bloqueo"):
		if is_on_floor() and (estado == "Normal" or estado == "Agachado"):
			estado = "Bloqueando"

	if Input.is_action_just_released("Bloqueo") and estado == "Bloqueando":
		estado = "Normal"

func _physics_process(delta):
	if estado == "Muerto":
		return

	if Input.is_action_just_pressed("Especial"):
		if estado != "Atacando" and estado != "Dash":
			estado = "Especial"

	if is_on_floor():
		Can_Dash = 1

	if Input.is_action_pressed("Abajo") and is_on_floor() and estado == "Normal":
		estado = "Agachado"
	elif Input.is_action_just_released("Abajo") and is_on_floor() and estado == "Agachado":
		estado = "Normal"

	if estado != "Bloqueando" and estado != "Atacando" and estado != "Especial" and estado != "Hit":
		if Input.is_action_pressed("Derecha"):
			intMove = 1
		elif Input.is_action_pressed("Izquierda"):
			intMove = -1
		else:
			intMove = 0
	else:
		intMove = 0

	if Input.is_action_just_pressed("Dash") and Can_Dash > 0 and estado != "Bloqueando":
		estado = "Dash"
		Can_Dash -= 1

	match estado:
		"Normal":
			if is_on_floor():
				coyote_time = max_coyote_time
				velocity.y = 0
			else:
				coyote_time -= delta
				velocity.y += intVY * delta

			velocity.x = (intVX * intMove) * delta if intMove != 0 else 0

			if Input.is_action_just_pressed("Saltar"):
				if is_on_floor() or (coyote_time > 0 and velocity.y > 0.01):
					velocity.y = -Jump_Height

			if Input.is_action_just_released("Saltar") and velocity.y < 0:
				velocity.y *= 0.5

		"Agachado", "Bloqueando", "Atacando", "Especial":
			velocity.x = 0
			velocity.y = 0

		"Dash":
			Time_Actual_Dupli += delta
			velocity.y = 0
			var dir = sign(mirror.scale.x)
			velocity.x = (intVX_Dash * dir) * delta

			if Time_Actual_Dupli >= Time_Dupli:
				Time_Actual_Dupli = 0
				crear_duplicado()
				
		"Hit":
			if not is_on_floor():
				velocity.y += intVY * delta
			else:
				velocity.y = 0

	_animaciones()
	move_and_slide()

# ---------------------------------------------------------
# ANIMACIONES Y EFECTOS
# ---------------------------------------------------------
func _animaciones():
	if intMove == -1:
		mirror.scale.x = -1
	elif intMove == 1:
		mirror.scale.x = 1

	match estado:
		"Normal":
			if is_on_floor():
				if velocity.x == 0:
					ani.play("Idle", 0.8)
				else:
					ani.play("Run", 1.1)
			else:
				ani.play("Jump" if velocity.y < 0 else "Fall")
		"Agachado":
			if ani.current_animation != "Fase2_Agacharse":
				ani.play("Fase1_Agacharse")
		"Dash":
			if is_on_floor():
				if Input.is_action_pressed("Abajo"):
					ani.play("Slide", 1.8)
				else:
					ani.play("Dash", 2.5)
			else:
				ani.play("Dash_Aire")
		"Atacando":
			sprite_pos_atacando = mirror.position
			# Solo reproduce la animación si no es la que está activa actualmente
			if ani.animation != ataque_actual:
				ani.play(ataque_actual,  1.8)
			mirror.position = sprite_pos_atacando
		"Bloqueando":
			ani.play("Bloqueo")
		"Especial":
			ani.play("Especial")
		"Hit":
			if ani.current_animation != "Hit":
				ani.play("Hit")



func crear_especial():
	var proyectil = Especial.instantiate()
	proyectil.global_position = global_position
	if mirror.flip_h:
		proyectil.direction = -1
	else:
		proyectil.direction = 1
	get_parent().add_child(proyectil)

func crear_duplicado():
	var duplicado = $AnimatedSprite2D.duplicate(true)
	duplicado.material = $AnimatedSprite2D.material.duplicate(true)
	duplicado.material.set_shader_parameter("opacity", 0.3)
	duplicado.material.set_shader_parameter("b", 0.8)
	duplicado.material.set_shader_parameter("mix_color", 0.7)
	duplicado.global_position = $AnimatedSprite2D.global_position
	duplicado.global_scale = $AnimatedSprite2D.global_scale
	duplicado.z_index -= 1
	get_parent().add_child(duplicado)
	await get_tree().create_timer(Time_Life_Dupli).timeout
	duplicado.queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	match ani.animation:
		"Dash", "Dash_Aire":
			estado = "Normal"
			
		"Slide":
			if Input.is_action_pressed("Abajo"):
				estado = "Agachado"
			else:
				estado = "Normal"
			Can_Dash = 1
			
		"Ataque_1":
			if counter_hit > 1:
				counter_hit = 0
				ani.play("Ataque_1")
			else:
				counter_hit = 0
				estado = "Normal"
				
		"Ataque_2":
			counter_hit = 0
			estado = "Normal"
			
		"Especial":
			estado = "Normal"
			
		"Hit":
			estado = "Normal"
	pass # Replace with function body.
