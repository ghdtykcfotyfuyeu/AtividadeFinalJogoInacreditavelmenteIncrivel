extends Node2D

enum EstadoPartida { PREPARANDO, INTERVALO, ONDA, CHEFE, VITORIA, DERROTA }

# Altere estes valores para ajustar a dificuldade sem mudar o restante do jogo.
const ONDAS = [
	{"quantidade": 6, "velocidade": 55.0},
	{"quantidade": 8, "velocidade": 62.0},
	{"quantidade": 10, "velocidade": 70.0}
]
@export var intervalo_ondas: float = 3.0

var estado: EstadoPartida = EstadoPartida.PREPARANDO
var onda_atual: int = 0
var tempo_intervalo: float = 0.0
var tempo_partida: float = 0.0

@onready var aluno = $Entidades/Player
@onready var spawner = $Entidades/Spawner
@onready var hud = $HUD


func _ready() -> void:
	aluno.definir_ativo(false)
	aluno.vida_alterada.connect(hud.atualizar_vida)
	aluno.morreu.connect(_derrota)
	spawner.contagem_alterada.connect(hud.atualizar_contagem)
	spawner.onda_concluida.connect(_ao_concluir_onda)
	spawner.chefe_criado.connect(_ao_criar_chefe)
	hud.reiniciar_solicitado.connect(_reiniciar)
	hud.atualizar_vida(aluno.vida, aluno.vida_maxima)
	hud.atualizar_etapa("Preparando")
	# Uma unica preparacao; as provas reutilizam o mapa de navegacao.
	$Navegacao.bake_navigation_polygon(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	aluno.definir_ativo(true)
	_iniciar_intervalo()


func _physics_process(delta: float) -> void:
	if estado in [EstadoPartida.VITORIA, EstadoPartida.DERROTA, EstadoPartida.PREPARANDO]:
		return
	tempo_partida += delta
	if estado == EstadoPartida.INTERVALO:
		tempo_intervalo -= delta
		var proxima := "Onda %d/3" % (onda_atual + 1) if onda_atual < ONDAS.size() else "Chefe"
		hud.atualizar_etapa(proxima)
		if tempo_intervalo <= 0.0:
			_iniciar_proxima_etapa()


func _iniciar_intervalo() -> void:
	estado = EstadoPartida.INTERVALO
	tempo_intervalo = intervalo_ondas


func _iniciar_proxima_etapa() -> void:
	if onda_atual < ONDAS.size():
		var configuracao: Dictionary = ONDAS[onda_atual]
		onda_atual += 1
		estado = EstadoPartida.ONDA
		hud.atualizar_etapa("Onda %d/3" % onda_atual)
		spawner.iniciar_onda(configuracao.quantidade, configuracao.velocidade)
	else:
		estado = EstadoPartida.CHEFE
		hud.atualizar_etapa("Chefe")
		spawner.iniciar_onda(1, 78.0, true)


func _ao_concluir_onda() -> void:
	if estado == EstadoPartida.ONDA:
		aluno.recuperar_vida(1)
		_iniciar_intervalo()
	elif estado == EstadoPartida.CHEFE and not aluno.morto:
		_finalizar(true)


func _ao_criar_chefe(chefe: Node2D) -> void:
	chefe.vida_alterada.connect(hud.atualizar_chefe)
	hud.atualizar_chefe(chefe.vida, chefe.vida_maxima)


func _derrota() -> void:
	_finalizar(false)


func _finalizar(venceu: bool) -> void:
	if estado in [EstadoPartida.VITORIA, EstadoPartida.DERROTA]:
		return
	estado = EstadoPartida.VITORIA if venceu else EstadoPartida.DERROTA
	spawner.encerrar()
	aluno.definir_ativo(false)
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		inimigo.desativar()
	hud.mostrar_resultado(venceu, spawner.derrotados, tempo_partida)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reiniciar") and estado in [EstadoPartida.VITORIA, EstadoPartida.DERROTA]:
		_reiniciar()


func _reiniciar() -> void:
	get_tree().reload_current_scene()
