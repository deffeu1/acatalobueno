extends CharacterBody2D

@onready var camara: Camera2D = $Camera2D
@export var zoom_normal: Vector2 = Vector2(1.0, 1.0)
@export var zoom_ampliado: Vector2 = Vector2(0.6, 0.6)
@export var tiempo_vista_ampliada: float = 5.0
@export var tiempo_cooldown: float = 10.0
@export var velocidad: float = 160.0
@export var vida_maxima: int = 150
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var hud: CanvasLayer = null
@export var escena_aullido: PackedScene
@onready var audio_aullido: AudioStreamPlayer2D = $AudioAullido
@onready var audio_dano: AudioStreamPlayer2D = $AudioDano
@onready var audio_curacion: AudioStreamPlayer2D = $AudioCuracion

var vida_actual: int
var ultima_direccion: String = "sur"
var en_vista_ampliada: bool = false
var puede_usar_vista: bool = true
var es_invulnerable: bool = false

func _ready() -> void:
	vida_actual = vida_maxima
	call_deferred("obtener_hud")

func obtener_hud() -> void:
	hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("actualizar_vida"):
		hud.actualizar_vida(vida_actual, vida_maxima)

func _physics_process(_delta: float) -> void:
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * velocidad
	move_and_slide()
	
	actualizar_animacion(direccion)
	if Input.is_action_just_pressed("vista_ampliada"):
		activar_vista_ampliada()

func actualizar_animacion(dir: Vector2) -> void:
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
		colision.shape.size = Vector2(62, 45) 
		if mirando_este:
			colision.position = Vector2(15, 20)
		else:
			colision.position = Vector2(23, 20)

func ajustar_colision_frente() -> void:
	if colision and (colision.shape is RectangleShape2D or colision.shape is CapsuleShape2D):
		colision.shape.size = Vector2(18, 50)
		colision.position = Vector2(20, 20)

func recibir_dano(cantidad: int) -> void:
	if es_invulnerable or vida_actual <= 0:
		return
		
	es_invulnerable = true
	vida_actual -= cantidad
	
	if audio_dano and audio_dano.stream:
		audio_dano.play()
		
	if not hud:
		hud = get_tree().get_first_node_in_group("hud")
		
	if hud and hud.has_method("actualizar_vida"):
		hud.actualizar_vida(vida_actual, vida_maxima)
		
	if vida_actual <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://escenas/perdiste.tscn")
		return

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.3, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	var timer = get_tree().create_timer(0.8)
	await timer.timeout
	es_invulnerable = false

func curar(cantidad: int) -> bool:
	if vida_actual >= vida_maxima:
		return false
	vida_actual = min(vida_actual + cantidad, vida_maxima)
	if audio_curacion and audio_curacion.stream:
		audio_curacion.play()
		
	if not hud:
		hud = get_tree().get_first_node_in_group("hud")
		
	if hud and hud.has_method("actualizar_vida"):
		hud.actualizar_vida(vida_actual, vida_maxima)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("disparar"):
		aullar()

func aullar() -> void:
	if audio_aullido and audio_aullido.stream:
		audio_aullido.play()
	if escena_aullido:
		var nuevo_aullido = escena_aullido.instantiate()
		nuevo_aullido.global_position = global_position
		
		var direccion_mouse = (get_global_mouse_position() - global_position).angle()
		nuevo_aullido.rotation = direccion_mouse
		
		get_parent().add_child(nuevo_aullido)

func activar_vista_ampliada() -> void:
	if not puede_usar_vista or en_vista_ampliada or not camara:
		return
		
	if not hud:
		hud = get_tree().get_first_node_in_group("hud")
		
	en_vista_ampliada = true
	puede_usar_vista = false
	
	var tween = create_tween()
	tween.tween_property(camara, "zoom", zoom_ampliado, 0.4).set_trans(Tween.TRANS_SINE)

	var timer_duracion = get_tree().create_timer(tiempo_vista_ampliada)
	await timer_duracion.timeout
	
	desactivar_vista_ampliada()
	
	if hud and hud.has_method("iniciar_cooldown_q"):
		hud.iniciar_cooldown_q()
	
	var tiempo_restante: float = tiempo_cooldown
	while tiempo_restante > 0.0:
		await get_tree().process_frame
		tiempo_restante -= get_process_delta_time()
		if hud and hud.has_method("actualizar_cooldown_q"):
			hud.actualizar_cooldown_q(tiempo_restante, tiempo_cooldown)
			
	puede_usar_vista = true
	if hud and hud.has_method("establecer_q_lista"):
		hud.establecer_q_lista()

func desactivar_vista_ampliada() -> void:
	if not camara:
		return
		
	en_vista_ampliada = false
	var tween = create_tween()
	tween.tween_property(camara, "zoom", zoom_normal, 0.4).set_trans(Tween.TRANS_SINE)
