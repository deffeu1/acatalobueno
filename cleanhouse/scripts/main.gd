extends Node2D

@onready var jugador: CharacterBody2D = $pj
@onready var mapa: TileMapLayer = $"cosas del mapa/piso"   

func _ready() -> void:
	configurar_limites_camara()

func configurar_limites_camara() -> void:
	if mapa and jugador and jugador.has_node("Camera2D"):
		var camara: Camera2D = jugador.get_node("Camera2D")
		var rect_usado: Rect2i = mapa.get_used_rect()
		var tamano_celda: Vector2i = mapa.tile_set.tile_size
		
		camara.limit_left = rect_usado.position.x * tamano_celda.x
		camara.limit_top = rect_usado.position.y * tamano_celda.y
		camara.limit_right = (rect_usado.position.x + rect_usado.size.x) * tamano_celda.x
		camara.limit_bottom = (rect_usado.position.y + rect_usado.size.y) * tamano_celda.y
