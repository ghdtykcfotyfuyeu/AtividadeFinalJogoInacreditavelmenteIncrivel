extends Node2D
# Origem: vila.gd da aula-10 de Ezefferth Fernandes e ficha Chefe do roteiro; adaptado com ChatGPT/Codex.
# Referencias e diferencas: res://docs/ORIGENS.md.

enum EstadoPartida { PREPARANDO, HORDA, CHEFE, VITORIA, DERROTA }

var estado: EstadoPartida = EstadoPartida.PREPARANDO
var abates: int = 0
var tempo_partida: float = 0.0
var chefe: Node2D

@onready var aluno = $Entidades/Player
@onready var spawner = $Entidades/Spawner
@onready var hud = $HUD
@onready var horda: Timer = $Horda
@onready var relogio: Timer = $Relogio


func _ready() -> void:
	aluno.definir_ativo(false)
	aluno.vida_alterada.connect(hud.atualizar_vida)
	aluno.morreu.connect(perder)
	spawner.inimigo_derrotado.connect(inimigo_morreu)
	hud.reiniciar_solicitado.connect(_reiniciar)
	hud.atualizar_vida(aluno.vida, aluno.vida_maxima)
	# Prepara uma vez; todos os inimigos usam este mapa de navegacao.
	$Navegacao.bake_navigation_polygon(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	estado = EstadoPartida.HORDA
	aluno.definir_ativo(true)
	spawner.ativo = true
	relogio.start()
	horda.start()
	hud.atualizar_placar(abates, relogio.time_left)


func _physics_process(delta: float) -> void:
	if estado not in [EstadoPartida.HORDA, EstadoPartida.CHEFE]:
		return
	tempo_partida += delta
	hud.atualizar_placar(abates, relogio.time_left, estado == EstadoPartida.CHEFE)


func _on_horda_timeout() -> void:
	if estado not in [EstadoPartida.HORDA, EstadoPartida.CHEFE]:
		return
	spawner.criar_inimigo(false, minf(75.0, 55.0 + tempo_partida / 3.0))
	# Mesma progressao do exemplo da aula: intervalo x 0,95, minimo 0,5 s.
	horda.wait_time = maxf(0.5, horda.wait_time * 0.95)


func _on_relogio_timeout() -> void:
	if estado != EstadoPartida.HORDA:
		return
	# Ficha Chefe: o fim dos 60 segundos faz o professor surgir, nao encerra a partida.
	chefe = spawner.criar_inimigo(true, 78.0)
	if not is_instance_valid(chefe):
		# Se todos os pontos estiverem ocupados, tenta outra vez sem atravessar paredes.
		relogio.start(0.2)
		return
	estado = EstadoPartida.CHEFE
	chefe.vida_alterada.connect(hud.atualizar_chefe)
	hud.atualizar_chefe(chefe.vida, chefe.vida_maxima)
	hud.atualizar_placar(abates, 0.0, true)


func inimigo_morreu(inimigo: Node2D) -> void:
	if estado not in [EstadoPartida.HORDA, EstadoPartida.CHEFE]:
		return
	abates += 1
	hud.atualizar_placar(abates, relogio.time_left, estado == EstadoPartida.CHEFE)
	if inimigo == chefe:
		vencer()


func vencer() -> void:
	_finalizar(true)


func perder() -> void:
	_finalizar(false)


func _finalizar(venceu: bool) -> void:
	if estado in [EstadoPartida.VITORIA, EstadoPartida.DERROTA]:
		return
	estado = EstadoPartida.VITORIA if venceu else EstadoPartida.DERROTA
	horda.stop()
	relogio.stop()
	spawner.encerrar()
	aluno.definir_ativo(false)
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		inimigo.desativar()
	$SombraVentilador.set_process(false)
	hud.mostrar_resultado(venceu, abates, tempo_partida)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reiniciar") and estado in [EstadoPartida.VITORIA, EstadoPartida.DERROTA]:
		_reiniciar()


func _reiniciar() -> void:
	# Como no exemplo fim.gd: a partida nova recarrega a cena e zera o estado.
	get_tree().reload_current_scene.call_deferred()
