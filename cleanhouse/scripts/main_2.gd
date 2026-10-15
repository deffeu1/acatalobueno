extends Node2D

func _process(_delta: float) -> void:
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	
	if enemigos.size() == 0:
		get_tree().call_deferred("change_scene_to_file", "res://escenas/win.tscn")
