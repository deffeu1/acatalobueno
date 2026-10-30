extends CanvasLayer
@onready var barra_vida: ProgressBar = $ProgressBar
@onready var barra_cooldown_q: ProgressBar = $BarraCooldownQ
@onready var label_lobos: Label = $LabelLobos

var color_vida_normal: Color = Color(0.2, 0.9, 0.3)
var color_destello_dano: Color = Color(2.5, 0.3, 0.3)
var color_listo: Color = Color(0.2, 0.9, 0.3)
var color_recarga: Color = Color(0.9, 0.2, 0.2)
var color_destello: Color = Color(2.0, 2.0, 2.0)

func _ready() -> void:
	add_to_group("hud")
	if barra_vida:
		barra_vida.modulate = color_vida_normal
	if barra_cooldown_q:
		barra_cooldown_q.max_value = 10.0
		barra_cooldown_q.value = 10.0
		barra_cooldown_q.modulate = color_listo

func actualizar_vida(vida_actual: int, vida_maxima: int) -> void:
	if not barra_vida:
		return
		
	var recibio_dano = vida_actual < barra_vida.value
	barra_vida.max_value = vida_maxima
	
	if recibio_dano:
		var tween = create_tween()
		barra_vida.modulate = color_destello_dano
		tween.parallel().tween_property(barra_vida, "value", vida_actual, 0.2)
		tween.parallel().tween_property(barra_vida, "modulate", color_vida_normal, 0.35).set_trans(Tween.TRANS_SINE)
	else:
		barra_vida.value = vida_actual
		barra_vida.modulate = color_vida_normal

func actualizar_contador_lobos(salvados: int, total: int) -> void:
	if label_lobos:
		label_lobos.text = "Lobos: %d/%d" % [salvados, total]

func iniciar_cooldown_q() -> void:
	if barra_cooldown_q:
		barra_cooldown_q.modulate = color_recarga

func actualizar_cooldown_q(tiempo_restante: float, tiempo_total: float) -> void:
	if barra_cooldown_q:
		barra_cooldown_q.max_value = tiempo_total
		barra_cooldown_q.value = tiempo_total - tiempo_restante

func establecer_q_lista() -> void:
	if not barra_cooldown_q:
		return
		
	barra_cooldown_q.value = barra_cooldown_q.max_value
	var tween = create_tween()
	tween.tween_property(barra_cooldown_q, "modulate", color_destello, 0.15)
	tween.tween_property(barra_cooldown_q, "modulate", color_listo, 0.25)
