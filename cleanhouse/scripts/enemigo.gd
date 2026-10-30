extends CharacterBody2D

@export var velocidad: float = 95.0
@export var vida_maxima: int = 50
@export var dano_ataque: int = 15
@export var tiempo_entre_ataques: float = 1.5
@export var distancia_frenado: float = 40.0

@onready var audio_dano_recibido: AudioStreamPlayer2D = $AudioDanoRecibido
@onready var anim = get_node_or_null("AnimatedSprite2D") if has_node("AnimatedSprite2D") else get_node_or_null("Sprite2D")

var vida_actual: int
var jugador_detectado: CharacterBody2D = null
var jugador_en_rango: CharacterBody2D = null
var puede_atacar: bool = true
var ultima_direccion: String = "sur"

func _ready() -> void:
	vida_actual = vida_maxima

func _physics_process(_delta: float) -> void:
	if jugador_detectado and is_instance_valid(jugador_detectado):
		var distancia = global_position.distance_to(jugador_detectado.global_position)
		
		if distancia > distancia_frenado:
			var direccion = (jugador_detectado.global_position - global_position).normalized()
			velocity = direccion * velocidad
			move_and_slide()
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	actualizar_animacion(velocity)
	
	if jugador_en_rango and puede_atacar:
		ejecutar_ataque()

func ejecutar_ataque() -> void:
	if not puede_atacar or not jugador_en_rango:
		return
		
	puede_atacar = false
	
	if is_instance_valid(jugador_en_rango) and jugador_en_rango.has_method("recibir_dano"):
		jugador_en_rango.recibir_dano(dano_ataque)
		
	var timer = get_tree().create_timer(tiempo_entre_ataques)
	await timer.timeout
	puede_atacar = true

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") or body.is_in_group("jugadores"):
		jugador_detectado = body

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_detectado:
		jugador_detectado = null

func _on_area_dano_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") or body.is_in_group("jugadores"):
		jugador_en_rango = body

func _on_area_dano_body_exited(body: Node2D) -> void:
	if body == jugador_en_rango:
		jugador_en_rango = null

func recibir_dano(cantidad: int) -> void:
	vida_actual -= cantidad
	
	if audio_dano_recibido and audio_dano_recibido.stream:
		audio_dano_recibido.play()
		
	modulate = Color(1, 0.2, 0.2)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	
	if vida_actual <= 0:
		morir()

func morir() -> void:
	set_physics_process(false)
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.call_deferred("set_disabled", true)
		
	if anim:
		anim.visible = false
		
	if audio_dano_recibido and audio_dano_recibido.playing:
		await audio_dano_recibido.finished
		
	call_deferred("queue_free")

func actualizar_animacion(dir: Vector2) -> void:
	if not anim or not anim is AnimatedSprite2D:
		return
		
	if dir.length() > 0:
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				anim.play("walk_este")
				ultima_direccion = "este"
			else:
				anim.play("walk_oeste")
				ultima_direccion = "oeste"
		else:
			if dir.y > 0:
				anim.play("walk_sur")
				ultima_direccion = "sur"
			else:
				anim.play("walk_norte")
				ultima_direccion = "norte"
	else:
		anim.stop()
