extends Node2D

signal contagem_alterada(ativos: int, derrotados: int, pendentes: int)
signal onda_concluida
signal chefe_criado(chefe: Node2D)

const CENA_INIMIGO = preload("res://inimigos/inimigo.tscn")
const CENA_CHEFE = preload("res://inimigos/chefe/chefe.tscn")

@export_range(1, 10) var limite_simultaneo: int = 10
@export var distancia_segura: float = 180.0

var derrotados: int = 0
var vivos: int = 0
var pendentes: int = 0
var ativo: bool = false
var onda_finalizada: bool = false
var criar_chefe: bool = false
var velocidade_onda: float = 55.0
var tempo_spawn: float = 0.0

@onready var inimigos: Node2D = $Inimigos
@onready var pontos_spawn: Node2D = $PontosSpawn


func iniciar_onda(quantidade: int, velocidade: float, chefe: bool = false) -> void:
	pendentes = quantidade
	velocidade_onda = velocidade
	criar_chefe = chefe
	onda_finalizada = false
	ativo = true
	tempo_spawn = 0.0
	_atualizar_contagem()


func _physics_process(delta: float) -> void:
	if not ativo:
		return
	tempo_spawn -= delta
	if pendentes > 0 and vivos < limite_simultaneo and tempo_spawn <= 0.0:
		# Um nascimento por intervalo evita picos e sobreposicoes.
		if _criar_inimigo():
			tempo_spawn = 0.14
		else:
			tempo_spawn = 0.3
	if pendentes == 0 and vivos == 0 and not onda_finalizada:
		onda_finalizada = true
		ativo = false
		onda_concluida.emit()


func _criar_inimigo() -> bool:
	var jogador = get_tree().get_first_node_in_group("jogador")
	if not is_instance_valid(jogador) or jogador.morto:
		return false
	var pontos := pontos_spawn.get_children()
	pontos.shuffle()
	for ponto in pontos:
		if ponto.global_position.distance_to(jogador.global_position) < distancia_segura:
			continue
		if not _ponto_livre(ponto.global_position):
			continue
		var novo = (CENA_CHEFE if criar_chefe else CENA_INIMIGO).instantiate()
		novo.position = inimigos.to_local(ponto.global_position)
		novo.velocidade = velocidade_onda
		novo.morreu.connect(_ao_inimigo_morrer)
		inimigos.add_child(novo)
		vivos += 1
		pendentes -= 1
		if criar_chefe:
			chefe_criado.emit(novo)
		_atualizar_contagem()
		return true
	return false


func _ponto_livre(posicao: Vector2) -> bool:
	for inimigo in inimigos.get_children():
		if not inimigo.morto and posicao.distance_to(inimigo.global_position) < 48.0:
			return false
	var forma := CircleShape2D.new()
	forma.radius = 22.0
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, posicao)
	consulta.collision_mask = 7
	return get_world_2d().direct_space_state.intersect_shape(consulta, 1).is_empty()


func _ao_inimigo_morrer() -> void:
	vivos = maxi(0, vivos - 1)
	derrotados += 1
	_atualizar_contagem()


func _atualizar_contagem() -> void:
	contagem_alterada.emit(vivos, derrotados, pendentes)


func encerrar() -> void:
	ativo = false
	pendentes = 0
