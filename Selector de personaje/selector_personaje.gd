extends Control

@export var Personajes: Array[characterdata]

@onready var spr = $Sprite2D

var cont: int =0

func sig() -> void:
	if cont < Personajes.size() -1:
		cont +=1
		spr.texture = Personajes[cont].Imagen
func ant() -> void:
	if cont >= 0:
		cont -=1
		spr.texture = Personajes[cont].Imagen


func _on_siguiente_pressed() -> void:
	sig()


func _on_anterior_pressed() -> void:
	ant()


func _on_seleccionar_pressed() -> void:
	pass # Replace with function body.
