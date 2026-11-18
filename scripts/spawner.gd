extends Node2D
# Origem: nascimento da horda em vila.gd, aula-10 de Ezefferth Fernandes; limites e pontos seguros adaptados com ChatGPT/Codex.

signal inimigo_derrotado(inimigo: Node2D)

const CENA_INIMIGO = preload("res://entities/inimigo.tscn")
const CENA_CHEFE = preload("res://entities/chefe.tscn")

@export_range(1, 10) var limite_provas: int = 10
@export var distancia_segura: float = 180.0

var provas_vivas: int = 0
var chefe_criado: bool = false
var ativo: bool = false

@onready var inimigos: Node2D = $Inimigos
@onready var pontos_spawn: Node2D = $PontosSpawn


func criar_inimigo(eh_chefe: bool = false, velocidade: float = 55.0) -> Node2D:
	if not ativo or (eh_chefe and chefe_criado):
		return null
	if not eh_chefe and provas_vivas >= limite_provas:
		return null
	var jogador = get_tree().get_first_node_in_group("jogador")
	if not is_instance_valid(jogador) or jogador.morto:
		return null
	var pontos := pontos_spawn.get_children()
	pontos.shuffle()
	for ponto in pontos:
		if ponto.global_position.distance_to(jogador.global_position) < distancia_segura:
			continue
		if not _ponto_livre(ponto.global_position):
			continue
		var novo = (CENA_CHEFE if eh_chefe else CENA_INIMIGO).instantiate()
		novo.position = inimigos.to_local(ponto.global_position)
		novo.velocidade = velocidade
		novo.morreu.connect(_ao_inimigo_morrer.bind(novo))
		inimigos.add_child(novo)
		if eh_chefe:
			chefe_criado = true
		else:
			provas_vivas += 1
		return novo
	return null


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


func _ao_inimigo_morrer(inimigo: Node2D) -> void:
	if not inimigo.eh_chefe:
		provas_vivas = maxi(0, provas_vivas - 1)
	inimigo_derrotado.emit(inimigo)


func encerrar() -> void:
	ativo = false
