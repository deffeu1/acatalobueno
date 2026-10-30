extends Area2D

@export var cantidad_curacion: int = 25
@export var tiempo_entre_brillos: float = 2.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	iniciar_efecto_brillo()

func iniciar_efecto_brillo() -> void:
	while is_instance_valid(self):
		await get_tree().create_timer(tiempo_entre_brillos).timeout
		if not is_instance_valid(self):
			break
			
		if sprite:
			sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
			await get_tree().create_timer(0.15).timeout
			if sprite:
				sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body.has_method("curar"):
		var se_curo: bool = body.curar(cantidad_curacion)
		if se_curo:
			call_deferred("queue_free")
