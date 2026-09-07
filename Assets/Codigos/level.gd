extends Node2D


func _ready():
	# Modo de prueba: si no hay selección (ej. probando el nivel directo),
	# usa Lum y Sierv por defecto en vez de fallar.
	if AdministradorPartida.personaje_p1 == null:
		AdministradorPartida.personaje_p1 = AdministradorPartida.personajes_disponibles["Lum"]
	if AdministradorPartida.personaje_p2 == null:
		AdministradorPartida.personaje_p2 = AdministradorPartida.personajes_disponibles["Sierv"]

	spawnear_jugador(AdministradorPartida.personaje_p1, 1, $Spawn1)
	spawnear_jugador(AdministradorPartida.personaje_p2, 2, $Spawn2)

func spawnear_jugador(escena: PackedScene, id: int, punto_spawn: Node2D):
	var jugador = escena.instantiate()
	jugador.player_id = id
	jugador.name = "Player" if id == 1 else "Player2"
	jugador.global_position = punto_spawn.global_position
	add_child(jugador)
