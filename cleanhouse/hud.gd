extends CanvasLayer

@onready var barra_vida: ProgressBar = $ProgressBar

func actualizar_vida(vida_actual: int, vida_maxima: int) -> void:
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
