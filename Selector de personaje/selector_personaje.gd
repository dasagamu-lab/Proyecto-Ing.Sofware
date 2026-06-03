extends Control

@onready var spr = $Sprite2D

var personajes = [
	preload("res://Assets/Personajes/Lum/Lum.png"),

	preload("res://Assets/Personajes/Sierv/Sierv.png")
]

var cont := 0


func _ready():
	spr.texture = personajes[0]
	
func sig():

	if cont < personajes.size() - 1:

		cont += 1

		spr.texture = personajes[cont]

func ant():

	if cont > 0:

		cont -= 1

		spr.texture = personajes[cont]
		
		
func _on_seleccionar_pressed():

	Global.personaje_seleccionado = cont

	get_tree().change_scene_to_file("res://Assets/Escenas/level.tscn")
