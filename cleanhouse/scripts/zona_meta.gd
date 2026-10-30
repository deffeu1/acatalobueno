extends Area2D

var lobos_a_salvo: Array[Node2D] = []
var total_lobos_en_mapa: int = 0

func _ready() -> void:
	monitoring = true
	await get_tree().process_frame
	
	total_lobos_en_mapa = get_tree().get_nodes_in_group("lobo_rescatado").size()
	
	actualizar_hud()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lobo_rescatado"):
		if not lobos_a_salvo.has(body):
			lobos_a_salvo.append(body)
			
			if body.has_method("llegar_al_refugio"):
				body.llegar_al_refugio()
				
			actualizar_hud()
			verificar_victoria()

func actualizar_hud() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		hud = get_parent().get_node_or_null("HUD")
	
	if hud and hud.has_method("actualizar_contador_lobos"):
		hud.actualizar_contador_lobos(lobos_a_salvo.size(), total_lobos_en_mapa)

func verificar_victoria() -> void:
	if total_lobos_en_mapa > 0 and lobos_a_salvo.size() >= total_lobos_en_mapa:
		get_tree().call_deferred("change_scene_to_file", "res://escenas/win.tscn")
