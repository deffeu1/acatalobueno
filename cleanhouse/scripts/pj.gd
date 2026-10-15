extends CharacterBody2D

@export var velocidad: float = 150.0
@export var vida_maxima: int = 100
var vida_actual: int

@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra_vida: ProgressBar = $ProgressBar

func _ready() -> void:
	vida_actual = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual

func _physics_process(_delta: float) -> void:
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * velocidad
	move_and_slide()
	
	# 2. Control de animaciones según dirección
	actualizar_animacion(direccion)

func actualizar_animacion(dir: Vector2) -> void:
	if dir.length() > 0:
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				anim.play("walk_este")
				ajustar_colision_perfil()
			else:
				anim.play("walk_oeste")
				ajustar_colision_perfil()
		else:
			if dir.y > 0:
				anim.play("walk_sur")
				ajustar_colision_frente()
			else:
				anim.play("walk_norte")
				ajustar_colision_frente()
	else:
		var anim_actual = anim.animation
		if "este" in anim_actual:
			anim.play("idle_este")
		elif "oeste" in anim_actual:
			anim.play("idle_oeste")
		elif "norte" in anim_actual:
			anim.play("idle_norte")
		else:
			anim.play("idle_sur")
func ajustar_colision_perfil() -> void:
	if colision.shape is RectangleShape2D or colision.shape is CapsuleShape2D:
		colision.shape.size = Vector2(32, 25) # Ancho: 32px, Alto: 25px
		colision.position = Vector2(0, 4)

func ajustar_colision_frente() -> void:
	if colision.shape is RectangleShape2D or colision.shape is CapsuleShape2D:
		colision.shape.size = Vector2(18, 26) # Ancho: 18px, Alto: 26px
		colision.position = Vector2(0, 2)

func recibir_dano(cantidad: int) -> void:
	vida_actual -= cantidad
	if barra_vida:
		barra_vida.value = vida_actual
		
	if vida_actual <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://escenas/perdiste.tscn")

func curar(cantidad: int) -> bool:
	if vida_actual >= vida_maxima:
		return false
		
	vida_actual = min(vida_actual + cantidad, vida_maxima)
	if barra_vida:
		barra_vida.value = vida_actual
	return true
