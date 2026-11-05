extends CanvasLayer

signal reiniciar_solicitado

var tempo_desempenho: float = 0.0
var vida: int = 5
var vida_maxima: int = 5
var provas_restantes: int = 0
var etapa: String = "Preparando"

@onready var texto: Label = $Painel/Texto
@onready var resultado = $Resultado/Centro/Painel/Margem/Coluna


func _ready() -> void:
	resultado.get_node("Reiniciar").pressed.connect(func(): reiniciar_solicitado.emit())
	_atualizar_painel()


func atualizar_vida(atual: int, maxima: int) -> void:
	vida = atual
	vida_maxima = maxima
	_atualizar_painel()


func atualizar_contagem(ativos: int, _derrotados: int, pendentes: int) -> void:
	provas_restantes = ativos + pendentes
	_atualizar_painel()


func atualizar_etapa(titulo: String) -> void:
	etapa = titulo
	_atualizar_painel()


func _atualizar_painel() -> void:
	texto.text = "Vida: %d/%d   |   %s   |   Provas: %d" % [vida, vida_maxima, etapa, provas_restantes]


func atualizar_chefe(atual: int, maxima: int) -> void:
	$Chefe.visible = true
	$Chefe/Coluna/Texto.text = "PROVA FINAL  —  %d / %d" % [atual, maxima]
	$Chefe/Coluna/Barra.max_value = maxima
	$Chefe/Coluna/Barra.value = atual


func mostrar_resultado(venceu: bool, derrotados: int, segundos: float) -> void:
	$Resultado.show()
	$Chefe.hide()
	resultado.get_node("Titulo").text = "APROVADO!" if venceu else "FIM DA PROVA"
	resultado.get_node("Titulo").modulate = Color(0.55, 0.95, 0.72) if venceu else Color(1.0, 0.65, 0.55)
	resultado.get_node("Descricao").text = "Você venceu as três ondas\ne derrotou a Prova Final!" if venceu else "Sua vida acabou.\nTente se movimentar enquanto ataca."
	resultado.get_node("Resumo").text = "Provas derrotadas: %d   •   Tempo: %s" % [derrotados, _formatar_tempo(segundos)]
	resultado.get_node("Reiniciar").grab_focus()


func _formatar_tempo(segundos: float) -> String:
	var total := int(segundos)
	return "%02d:%02d" % [total / 60, total % 60]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		$Desempenho.visible = not $Desempenho.visible


func _process(delta: float) -> void:
	if not $Desempenho.visible:
		return
	tempo_desempenho -= delta
	if tempo_desempenho <= 0.0:
		tempo_desempenho = 0.5
		$Desempenho.text = "FPS: %d  |  Inimigos: %d" % [Engine.get_frames_per_second(), get_tree().get_nodes_in_group("inimigos").size()]
