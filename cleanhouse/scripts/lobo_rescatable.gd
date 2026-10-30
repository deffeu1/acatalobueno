extends CharacterBody2D

@export var velocidad: float = 140.0
@export var distancia_seguimiento: float = 60.0
@onready var audio_rescate: AudioStreamPlayer2D = $AudioRescate
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D

var rescatado: bool = false
var en_refugio: bool = false
var objetivo_seguimiento: Node2D = null
var ultima_direccion: String = "sur"
var direccion_patrulla: Vector2 = Vector2.ZERO
var timer_patrulla: float = 0.0

func _ready() -> void:
	add_to_group("lobo_rescatado") 

func _physics_process(delta: float) -> void:
	if en_refugio:
		patrullar_en_refugio(delta)
		return

	if rescatado and objetivo_seguimiento and is_instance_valid(objetivo_seguimiento):
		var distancia = global_position.distance_to(objetivo_seguimiento.global_position)
		
		if distancia > distancia_seguimiento:
			var direccion = (objetivo_seguimiento.global_position - global_position).normalized()
			velocity = direccion * velocidad
			move_and_slide()
			actualizar_animacion(direccion)
		else:
			velocity = Vector2.ZERO
			actualizar_animacion(Vector2.ZERO)

func patrullar_en_refugio(delta: float) -> void:
	timer_patrulla -= delta
	if timer_patrulla <= 0.0:
		timer_patrulla = randf_range(1.5, 3.0)
		if randf() > 0.3:
			direccion_patrulla = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			direccion_patrulla = Vector2.ZERO 

	velocity = direccion_patrulla * (velocidad * 0.4) 
	move_and_slide()
	actualizar_animacion(direccion_patrulla)

func llegar_al_refugio() -> void:
	en_refugio = true
	rescatado = false
	objetivo_seguimiento = null
	if audio_rescate and audio_rescate.stream:
		audio_rescate.play()

func actualizar_animacion(dir: Vector2) -> void:
	if not anim:
		return
		
	if dir.length() > 0:
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				anim.play("walk_este")
				ultima_direccion = "este"
				ajustar_colision_perfil(true)
			else:
				anim.play("walk_oeste")
				ultima_direccion = "oeste"
				ajustar_colision_perfil(false)
		else:
			if dir.y > 0:
				anim.play("walk_sur")
				ultima_direccion = "sur"
				ajustar_colision_frente()
			else:
				anim.play("walk_norte")
				ultima_direccion = "norte"
				ajustar_colision_frente()
	else:
		match ultima_direccion:
			"este":
				anim.play("idle_este")
				ajustar_colision_perfil(true)
			"oeste":
				anim.play("idle_oeste")
				ajustar_colision_perfil(false)
			"norte":
				anim.play("idle_norte")
				ajustar_colision_frente()
			"sur":
				anim.play("idle_sur")
				ajustar_colision_frente()

func ajustar_colision_perfil(mirando_este: bool) -> void:
	if colision and (colision.shape is RectangleShape2D or colision.shape is CapsuleShape2D):
		colision.shape.size = Vector2(32, 16)
		if mirando_este:
			colision.position = Vector2(6, 4)
		else:
			colision.position = Vector2(-6, 4)

func ajustar_colision_frente() -> void:
	if colision and (colision.shape is RectangleShape2D or colision.shape is CapsuleShape2D):
		colision.shape.size = Vector2(18, 20)
		colision.position = Vector2(0, 2)

func _on_area_rescate_body_entered(body: Node2D) -> void:
	if not rescatado and not en_refugio and body.is_in_group("jugador"):
		if jugador_ya_tiene_companero():
			return
		rescatado = true
		objetivo_seguimiento = body
		if audio_rescate and audio_rescate.stream:
			audio_rescate.play()

func jugador_ya_tiene_companero() -> bool:
	var lobos = get_tree().get_nodes_in_group("lobo_rescatado")
	for lobo in lobos:
		if lobo != self and lobo.rescatado and not lobo.en_refugio:
			return true
	return false
