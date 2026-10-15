extends Area2D

@export var velocidad: float = 350.0
@export var dano: int = 25
@export var alcance_tiempo: float = 0.5 # Tiempo que dura la onda antes de disiparse

func _ready() -> void:
	# El aullido desaparece automáticamente después de un tiempo si no choca con nada
	var timer = get_tree().create_timer(alcance_tiempo)
	timer.timeout.connect(func(): call_deferred("queue_free"))

func _process(delta: float) -> void:
	# La onda de sonido avanza hacia adelante
	position += transform.x * velocidad * delta
	
	# Opcional: Hacer que la onda de sonido crezca un poco a medida que viaja
	scale += Vector2(delta * 1.5, delta * 1.5)

func _on_body_entered(body: Node2D) -> void:
	# Daña a cualquier objeto destruible (barrera, enemigo, etc.)
	if body.has_method("recibir_dano"):
		body.recibir_dano(dano)
		# Nota: Podés decidir si el aullido atraviesa barreras o se destruye al chocar
		call_deferred("queue_free")
