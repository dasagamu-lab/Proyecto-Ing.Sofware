extends Area2D

var speed = 500
var direction = 1

func _physics_process(delta):

	position.x += speed * direction * delta
