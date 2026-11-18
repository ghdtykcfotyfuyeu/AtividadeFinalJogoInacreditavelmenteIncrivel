extends CanvasLayer
# Origem: placar de vida/abates/tempo de vila.gd (aula-10); interface e resultado adaptados com ChatGPT/Codex.

signal reiniciar_solicitado

var tempo_desempenho: float = 0.0
var vida: int = 5
var vida_maxima: int = 5
var abates: int = 0
var segundos: int = 60
var chefe_presente: bool = false

@onready var texto: Label = $Painel/Texto
@onready var resultado = $Resultado/Centro/Painel/Margem/Coluna


func _ready() -> void:
	resultado.get_node("Reiniciar").pressed.connect(func(): reiniciar_solicitado.emit())
	_atualizar_painel()


func atualizar_vida(atual: int, maxima: int) -> void:
	vida = atual
	vida_maxima = maxima
	_atualizar_painel()


func atualizar_placar(total_abates: int, tempo_restante: float, chegou: bool = false) -> void:
	var restante := ceili(tempo_restante)
	if abates == total_abates and segundos == restante and chefe_presente == chegou:
		return
	abates = total_abates
	segundos = restante
	chefe_presente = chegou
	_atualizar_painel()


func _atualizar_painel() -> void:
	var objetivo := "Derrote o professor" if chefe_presente else "Chefe em: %ds" % segundos
	texto.text = "Vida: %d/%d   |   Abates: %d   |   %s" % [vida, vida_maxima, abates, objetivo]


func atualizar_chefe(atual: int, maxima: int) -> void:
	$Chefe.show()
	$Chefe/Coluna/Texto.text = "PROFESSOR  —  %d / %d" % [atual, maxima]
	$Chefe/Coluna/Barra.max_value = maxima
	$Chefe/Coluna/Barra.value = atual


func mostrar_resultado(venceu: bool, derrotados: int, tempo: float) -> void:
	$Resultado.show()
	$Chefe.hide()
	resultado.get_node("Titulo").text = "APROVADO!" if venceu else "FIM DA PROVA"
	resultado.get_node("Titulo").modulate = Color(0.55, 0.95, 0.72) if venceu else Color(1.0, 0.65, 0.55)
	resultado.get_node("Descricao").text = "Você resistiu à horda\ne derrotou o professor!" if venceu else "Sua vida acabou.\nTente se movimentar enquanto ataca."
	resultado.get_node("Resumo").text = "Abates: %d   •   Tempo: %02d:%02d" % [derrotados, int(tempo) / 60, int(tempo) % 60]
	resultado.get_node("Reiniciar").grab_focus()


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
