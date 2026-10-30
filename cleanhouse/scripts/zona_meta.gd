extends Area2D

var lobos_a_salvo: Array[Node2D] = []

func _ready() -> void:
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lobo_rescatado"):
		if not lobos_a_salvo.has(body):
			lobos_a_salvo.append(body)
			
			if body.has_method("llegar_al_refugio"):
				body.llegar_al_refugio()
				
			verificar_condicion_victoria()

func verificar_condicion_victoria() -> void:
	var total_rescatables = get_tree().get_nodes_in_group("lobo_rescatado").size()
	
	if lobos_a_salvo.size() >= total_rescatables and total_rescatables > 0:
		get_tree().call_deferred("change_scene_to_file", "res://escenas/win.tscn")
