extends Area2D

var speed = 300
var direction = 1

func _ready():
	# Volteamos el proyectil hacia donde mira el jugador
	scale.x = direction

func _physics_process(delta):
	# Movimiento constante del proyectil
	position.x += speed * direction * delta


# Al chocar contra un cuerpo (suelo, pared, etc.)
func _on_body_entered(body):
	var rastro = $Rastro
	if rastro:
		# Apagamos la emisión para que no sigan saliendo partículas nuevas
		rastro.emitting = false
		# Desacoplamos el rastro para que los puntos que ya están en el mapa se desvanezcan solos
		rastro.reparent(get_parent())
	
	# Destruimos el proyectil de inmediato
	queue_free()
