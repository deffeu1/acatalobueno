extends Area2D

@export var velocidad: float = 350.0
@export var dano: int = 25
@export var alcance_tiempo: float = 0.8

func _ready() -> void:
	var timer = get_tree().create_timer(alcance_tiempo)
	timer.timeout.connect(func(): call_deferred("queue_free"))

func _process(delta: float) -> void:
	position += transform.x * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		return
		
	if body.has_method("recibir_dano"):
		body.recibir_dano(dano)
		call_deferred("queue_free")
	elif body is TileMapLayer or body is StaticBody2D:
		call_deferred("queue_free")
