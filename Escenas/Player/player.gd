extends CharacterBody2D
class_name Player

# VELOCIDADES
var intVX : int = 10000 
var intVY : int = 480 
var intVX_Dash : int = 18000 

# FISICAS
var Jump_Height : int = 240 

# Coyote Time
var max_coyote_time = 0.2 
var coyote_time = 0.0 

# ESTADOS
var intMove : int = 0 
var estado = "Normal" # (Normal, Agachado, Dash, Atacando, Bloqueando)

# NODO DE ANIMACIÓN
@onready var ani = $Sprite2D/Graficos 
@onready var mirror = $Sprite2D 

# ATAQUES
var counter_hit : int = 0

# Limitadores
var Can_Dash : int = 1

# EFECTOS DASH
var Time_Actual_Dupli : float = 0
var Time_Dupli : float = 0.05
var Time_Life_Dupli : float = 0.2

func _ready():
	$"Col_Daño/Ataque_1".disabled = true
	$"Col_Daño/Ataque_2".disabled = true
	$"Col_Daño/Ataque_Especial".disabled = true

func _input(event): 
	# Lógica de Ataque
	if Input.is_action_just_pressed("Atacar"):
		# Solo atacamos si no estamos bloqueando ni en dash
		if is_on_floor() and estado != "Bloqueando": 
			counter_hit += 1 
			estado = "Atacando" 
			_animaciones() 

	# NUEVA LÓGICA DE BLOQUEO
	if Input.is_action_pressed("Bloqueo"):
		if is_on_floor() and (estado == "Normal" or estado == "Agachado"):
			estado = "Bloqueando"
	
	if Input.is_action_just_released("Bloqueo") and estado == "Bloqueando":
		estado = "Normal"

func _physics_process(delta): 
	if is_on_floor(): 
		Can_Dash = 1 
	
	# Lógica de Agacharse (Solo si no estamos bloqueando)
	if Input.is_action_pressed("Abajo") and is_on_floor() and estado == "Normal":
		estado = "Agachado"
	elif Input.is_action_just_released("Abajo") and is_on_floor() and estado == "Agachado":
		estado = "Normal" 
	
	# Movimiento Lateral (Solo se registra si no estamos bloqueando o atacando)
	if estado != "Bloqueando" and estado != "Atacando":
		if Input.is_action_pressed("Derecha"):
			intMove = 1 
		elif Input.is_action_pressed("Izquierda"):
			intMove = -1 
		else: 
			intMove = 0 
	else:
		intMove = 0 # Forzamos que se quede quieto
	
	# Lógica de Dash
	if Input.is_action_just_pressed("Dash") and Can_Dash > 0 and estado != "Bloqueando": 
		estado = "Dash" 
		Can_Dash -= 1 
	
	# MÁQUINA DE ESTADOS (FÍSICAS)
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
				velocity.y = velocity.y * 0.5 
		
		"Agachado", "Bloqueando", "Atacando":
			velocity.x = 0 
			velocity.y = 0 
		
		"Dash": 
			Time_Actual_Dupli += delta
			velocity.y = 0 
			var dir = -1 if mirror.flip_h else 1
			velocity.x = (intVX_Dash * dir) * delta
			if Time_Actual_Dupli >= Time_Dupli:
				Time_Actual_Dupli = 0
				crear_duplicado()
	
	_animaciones() 
	move_and_slide() 

func _animaciones():
	# Ajuste de dirección del sprite (Solo si se está moviendo)
	if intMove != 0:
		mirror.flip_h = (intMove == -1)
		# Ajustar posición de colisiones según dirección
		var side = intMove
		$Colision.position.x = 5 * side
		$"Col_Daño/Ataque_1".position.x = 24.25 * side
		$"Col_Daño/Ataque_2".position.x = 18 * side
		$"Col_Daño/Ataque_Especial".position.x = 9 * side

	# Control de colisión de Slide
	if ani.current_animation != "Slide":
		$"Col_Daño/Ataque_Especial".disabled = true 

	# Reproducción de animaciones por estado
	match estado:
		"Normal":
			if is_on_floor():
				if velocity.x == 0:
					ani.play("Idle", -1, 0.8)
				else:
					ani.play("Run", -1, 1.1)
			else:
				ani.play("Jump" if velocity.y < 0 else "Fall")
		
		"Agachado":
			if ani.current_animation != "Fase2_Agacharse":
				ani.play("Fase1_Agacharse")
		
		"Dash":
			if is_on_floor():
				if Input.is_action_pressed("Abajo"):
					ani.play("Slide", -1, 1.8)
				else:
					ani.play("Dash_Smoke_Ground", -1, 2.5)
			else:
				ani.play("Dash_Air")
		
		"Atacando":
			ani.play("Ataque_1", -1, 1.8)
			
		"Bloqueando":
			ani.play("Bloqueo") # <--- AQUÍ SE ACTIVA TU ANIMACIÓN

	# Limpieza de seguridad
	if estado != "Atacando":
		$"Col_Daño/Ataque_1".disabled = true
		$"Col_Daño/Ataque_2".disabled = true

func _on_graficos_animation_finished(anim_name): 
	match anim_name:
		"Dash_Smoke_Ground", "Dash_Air":
			estado = "Normal"
		"Slide":
			estado = "Agachado" if Input.is_action_pressed("Abajo") else "Normal"
			Can_Dash = 1
		"Ataque_1":
			if counter_hit > 1:
				ani.play("Ataque_1")
				
				
				#ya vuelvo muchachos 
			else:
				counter_hit = 0
				estado = "Normal"
		"Ataque_2":
			counter_hit = 0
			estado = "Normal"

func crear_duplicado():
	var duplicado = $Sprite2D.duplicate(true)
	duplicado.material = $Sprite2D.material.duplicate(true)
	duplicado.material.set_shader_parameter("opacity", 0.3)
	duplicado.material.set_shader_parameter("b", 0.8)
	duplicado.material.set_shader_parameter("mix_color", 0.7)
	duplicado.global_position = $Sprite2D.global_position
	duplicado.global_scale = $Sprite2D.global_scale
	duplicado.z_index -= 1
	get_parent().add_child(duplicado)
	await get_tree().create_timer(Time_Life_Dupli).timeout
	duplicado.queue_free()
