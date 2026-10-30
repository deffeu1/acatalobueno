extends CharacterBody2D

@export var velocidad: float = 80.0
@export var vida_maxima: int = 50
@export var dano_ataque: int = 20
@export var tiempo_entre_ataques: float = 1.0

var vida_actual: int
var jugador_detectado: CharacterBody2D = null
var jugador_en_rango: CharacterBody2D = null
var puede_atacar: bool = true

func _ready() -> void:
	vida_actual = vida_maxima

func _physics_process(_delta: float) -> void:
	if jugador_detectado and is_instance_valid(jugador_detectado):
		var direccion = (jugador_detectado.global_position - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	if jugador_en_rango and puede_atacar:
		ejecutar_ataque()

func ejecutar_ataque() -> void:
	if jugador_en_rango and jugador_en_rango.has_method("recibir_dano"):
		jugador_en_rango.recibir_dano(dano_ataque)
		puede_atacar = false
		var timer = get_tree().create_timer(tiempo_entre_ataques)
		timer.timeout.connect(func(): puede_atacar = true)

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugador_detectado = body

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_detectado:
		jugador_detectado = null

func _on_area_dano_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugador_en_rango = body

func _on_area_dano_body_exited(body: Node2D) -> void:
	if body == jugador_en_rango:
		jugador_en_rango = null

func recibir_dano(cantidad: int) -> void:
	vida_actual -= cantidad
	modulate = Color(1, 0.2, 0.2)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	if vida_actual <= 0:
		call_deferred("queue_free")
