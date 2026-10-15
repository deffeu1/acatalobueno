extends Control

func _on_boton_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/main_2.tscn") #CAMBIAR A MAIN

func _on_boton_salir_pressed() -> void:
	get_tree().quit()
