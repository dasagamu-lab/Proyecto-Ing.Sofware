extends CharacterBody2D
class_name Player

#VELOCIDADES
var intVX : int = 10000
var intVY : int = 480
var intVX_Dash : int = 18000

#FISICAS
var Jump_Height : int = 240

#Coyote Time
var max_coyote_time = 0.2
var coyote_time = 0.0

#ESTADOS
var intMove : int = 0

@onready var ani = $Sprite2D/Graficos
@onready var mirror = $Sprite2D

var estado = "Normal"

#ATAQUES
var counter_hit : int = 0

#Limitadores
var Can_Dash : int = 1

#EFECTOS
var Time_Actual_Dupli : float = 0
var Time_Dupli : float = 0.05
var Time_Life_Dupli : float = 0.2


func _ready():
	$"Col_Daño/Ataque_1".disabled = true
	$"Col_Daño/Ataque_2".disabled = true
	$"Col_Daño/Especial".disabled = true


func _input(event):
	if Input.is_action_just_pressed("Atacar"):
		if estado == "Dash":
			return
		
		if is_on_floor():
			counter_hit += 1
			estado = "Atacando"
			_animaciones()
	
	# 🔥 ESPECIAL CON X
	if event is InputEventKey and event.pressed and event.keycode == KEY_X:
		if estado == "Dash":
			return
		
		if is_on_floor():
			estado = "Especial"
			_animaciones()


func _physics_process(delta):
	
	if is_on_floor():
		Can_Dash = 1
	
	if Input.is_action_pressed("Abajo") and is_on_floor() and estado == "Normal":
		estado = "Agachado"
	elif Input.is_action_just_released("Abajo") and is_on_floor() and estado == "Agachado":
		estado = "Normal"
	
	if Input.is_action_pressed("Derecha"):
		intMove = 1
	elif Input.is_action_pressed("Izquierda"):
		intMove = -1
	else:
		intMove = 0
	
	if Input.is_action_just_pressed("Dash"):
		if Can_Dash > 0:
			estado = "Dash"
			Can_Dash -= 1
	
	
	# -------- NORMAL --------
	if estado == "Normal":
		
		if is_on_floor():
			coyote_time = max_coyote_time
		else:
			coyote_time -= delta
		
		if intMove != 0:
			velocity.x = (intVX * intMove) * delta
		else:
			velocity.x = 0
		
		if is_on_floor():
			velocity.y = 0
		else:
			velocity.y += intVY * delta
		
		if Input.is_action_just_pressed("Saltar"):
			if is_on_floor() or (coyote_time > 0 and velocity.y > 0.01):
				velocity.y = -Jump_Height
		
		if Input.is_action_just_released("Saltar") and velocity.y < 0:
			velocity.y *= 0.5
		
		_animaciones()
		move_and_slide()
	
	# -------- AGACHADO --------
	if estado == "Agachado":
		velocity.x = 0
		velocity.y = 0
		_animaciones()
		move_and_slide()
	
	# -------- DASH --------
	if estado == "Dash":
		
		Time_Actual_Dupli += delta
		
		velocity.y = 0
		
		if mirror.flip_h == false:
			velocity.x = intVX_Dash * delta
		else:
			velocity.x = -intVX_Dash * delta
		
		_animaciones()
		
		if Time_Actual_Dupli >= Time_Dupli:
			Time_Actual_Dupli = 0
			crear_duplicado()
		
		move_and_slide()
	
	# -------- ESPECIAL --------
	if estado == "Especial":
		velocity.x = 0
		velocity.y = 0
		
		_animaciones()
		move_and_slide()


func _animaciones():
	var idle : float = 0.8
	var dash : float = 2.5
	var air : float = 1.0
	var walk : float = 1.1
	var atacar : float = 1.8
	var especial : float = 1.5
	
	if estado == "Normal":
		
		if intMove == 1:
			mirror.flip_h = false
			$Colision.position.x = -5
			$"Col_Daño/Ataque_1".position.x = 24.25
			$"Col_Daño/Ataque_2".position.x = 18
			$"Col_Daño/Especial".position.x = 26
		
		if intMove == -1:
			mirror.flip_h = true
			$Colision.position.x = 5
			$"Col_Daño/Ataque_1".position.x = -24.25
			$"Col_Daño/Ataque_2".position.x = -18
			$"Col_Daño/Especial".position.x = -26
		
		if velocity.x == 0 and is_on_floor() and not Input.is_action_pressed("Abajo"):
			ani.speed_scale = idle
			ani.play("Idle")
		elif velocity.x != 0 and is_on_floor():
			ani.speed_scale = walk
			ani.play("Run")
		
		if not is_on_floor():
			ani.speed_scale = air
			if velocity.y < 0:
				ani.play("Jump")
			else:
				ani.play("Fall")

	if estado == "Dash":
		ani.speed_scale = dash
		
		if is_on_floor():
			ani.play("Dash_Smoke_Ground")
	
	if estado == "Atacando":
		ani.speed_scale = atacar
		if ani.current_animation != "Ataque_1":
			ani.play("Ataque_1")
	
	# 🔥 ESPECIAL
	if estado == "Especial":
		ani.speed_scale = especial
		if ani.current_animation != "Especial":
			ani.play("Especial")
		
		$"Col_Daño/Especial".disabled = false
	
	if estado != "Atacando":
		$"Col_Daño/Ataque_1".disabled = true
		$"Col_Daño/Ataque_2".disabled = true
	
	if estado != "Especial":
		$"Col_Daño/Especial".disabled = true


func _on_graficos_animation_finished(anim_name):
	match anim_name:
		"Dash_Smoke_Ground":
			estado = "Normal"
		"Dash_Air":
			estado = "Normal"
		
		"Ataque_1":
			if counter_hit == 1:
				counter_hit = 0
				estado = "Normal"
			if counter_hit > 1:
				ani.play("Ataque_2")
		
		"Ataque_2":
			counter_hit = 0
			estado = "Normal"
		
		# 🔥 FIN ESPECIAL
		"Especial":
			estado = "Normal"


func crear_duplicado():
	var duplicado = $Sprite2D.duplicate(true)
	duplicado.material = $Sprite2D.material.duplicate(true)
	duplicado.material.set_shader_parameter("opacity", 0.3)
	duplicado.material.set_shader_parameter("r", 0.0)
	duplicado.material.set_shader_parameter("g", 0.0)
	duplicado.material.set_shader_parameter("b", 0.8)
	duplicado.material.set_shader_parameter("mix_color", 0.7)
	duplicado.position.y += position.y
	
	if $Sprite2D.scale.x == -1:
		duplicado.position.x = position.x - duplicado.position.x
	else:
		duplicado.position.x += position.x
