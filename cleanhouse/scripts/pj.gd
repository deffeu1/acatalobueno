extends CharacterBody2D

@export var velocidad: float = 150.0
@export var vida_maxima: int = 150
var vida_actual: int
var ultima_direccion: String = "sur"

@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud: CanvasLayer = $HUD
@export var escena_aullido: PackedScene

func _ready() -> void:
	vida_actual = vida_maxima
	if hud:
		hud.actualizar_vida(vida_actual, vida_maxima)

func _physics_process(_delta: float) -> void:
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * velocidad
	move_and_slide()
	
	actualizar_animacion(direccion)

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
	vida_actual -= cantidad
	if hud:
		hud.actualizar_vida(vida_actual, vida_maxima)
		
	if vida_actual <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://escenas/perdiste.tscn")

func curar(cantidad: int) -> bool:
	if vida_actual >= vida_maxima:
		return false 
		
	vida_actual = min(vida_actual + cantidad, vida_maxima)
	if hud:
		hud.actualizar_vida(vida_actual, vida_maxima)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("disparar"):
		aullar()

func aullar() -> void:
	if escena_aullido:
		var nuevo_aullido = escena_aullido.instantiate()
		nuevo_aullido.global_position = global_position
		
		var direccion_mouse = (get_global_mouse_position() - global_position).angle()
		nuevo_aullido.rotation = direccion_mouse
		
		get_parent().add_child(nuevo_aullido)
