extends StaticBody2D

@export var vida_maxima: int = 50
var vida_actual: int

func _ready() -> void:
	vida_actual = vida_maxima

func recibir_dano(cantidad: int) -> void:
	vida_actual -= cantidad
	
	modulate = Color(1, 0.4, 0.4)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	if vida_actual <= 0:
		call_deferred("queue_free")
