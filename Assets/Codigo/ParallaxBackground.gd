extends ParallaxBackground


@onready var Blue_Sky = $"Cielo Azul"
@onready var Clouds = $Cielo
@onready var Montain = $"Montañas"
@onready var Grass = $Cesped

func _process(delta):
	Blue_Sky.motion_offset.x -= 0.01
	Clouds.motion_offset.x -= 0.25
	
