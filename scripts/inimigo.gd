extends CharacterBody2D

signal morreu
signal vida_alterada(atual: int, maxima: int)
signal estado_alterado(anterior: int, atual: int)

# A mesma maquina controla as provas e o chefe, com parametros diferentes.
enum Estado { NASCENDO, PERSEGUINDO, ATACANDO, FERIDO, MORTO }

@export var velocidade: float = 55.0
@export var vida_maxima: int = 1
@export var dano: int = 1
@export var preparacao_ataque: float = 0.12
@export var duracao_ataque: float = 0.65
@export var eh_chefe: bool = false

var vida: int = 1
var morto: bool = false
var ativo: bool = true
var estado: Estado = Estado.NASCENDO
var tempo_estado: float = 0.0
var tempo_busca: float = 0.0
var golpe_aplicado: bool = false
var jogador: Node2D
var cor_original: Color

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var contato: Area2D = $Contato
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	vida = vida_maxima
	jogador = get_tree().get_first_node_in_group("jogador")
	agente.max_speed = velocidade
	# Distribui as consultas de caminho entre os inimigos.
	tempo_busca = randf_range(0.0, 0.2)
	cor_original = sprite.modulate
	sprite.modulate.a = 0.4
	vida_alterada.emit(vida, vida_maxima)


func _physics_process(delta: float) -> void:
	if not ativo or morto or not is_instance_valid(jogador):
		return
	if jogador.morto or not jogador.ativo:
		_parar()
		return
	tempo_estado += delta
	match estado:
		Estado.NASCENDO:
			if tempo_estado >= 0.35:
				mudar_estado(Estado.PERSEGUINDO)
		Estado.PERSEGUINDO:
			if _tocando_jogador():
				mudar_estado(Estado.ATACANDO)
			else:
				_perseguir(delta)
		Estado.ATACANDO:
			if tempo_estado >= preparacao_ataque and not golpe_aplicado:
				golpe_aplicado = true
				if _tocando_jogador():
					jogador.receber_dano(dano, global_position)
			if tempo_estado >= duracao_ataque:
				mudar_estado(Estado.PERSEGUINDO)
		Estado.FERIDO:
			if tempo_estado >= 0.16:
				mudar_estado(Estado.PERSEGUINDO)
		Estado.MORTO:
			pass


func mudar_estado(novo: Estado) -> void:
	if estado == novo or morto:
		return
	var anterior := estado
	estado = novo
	tempo_estado = 0.0
	sprite.modulate = cor_original
	match estado:
		Estado.PERSEGUINDO:
			tempo_busca = 0.0
		Estado.ATACANDO:
			_parar()
			golpe_aplicado = false
			sprite.modulate = Color(1.0, 0.65, 0.45)
		Estado.FERIDO:
			_parar()
			sprite.modulate = Color(1.0, 0.35, 0.35)
		Estado.MORTO:
			morto = true
			ativo = false
			_parar()
			agente.avoidance_enabled = false
			remove_from_group("inimigos")
			hide()
	estado_alterado.emit(anterior, estado)


func _perseguir(delta: float) -> void:
	tempo_busca -= delta
	if tempo_busca <= 0.0:
		agente.target_position = jogador.global_position
		tempo_busca = 0.22
	if agente.is_navigation_finished():
		_parar()
		return
	var proximo_ponto := agente.get_next_path_position()
	agente.velocity = global_position.direction_to(proximo_ponto) * velocidade


func _on_velocity_computed(velocidade_segura: Vector2) -> void:
	if not ativo or morto or estado != Estado.PERSEGUINDO:
		return
	velocity = velocidade_segura
	move_and_slide()


func _tocando_jogador() -> bool:
	if not contato.overlaps_body(jogador):
		return false
	# A area de contato nao causa dano atraves do canto de uma mesa.
	var linha := PhysicsRayQueryParameters2D.create(global_position, jogador.global_position, 1)
	return get_world_2d().direct_space_state.intersect_ray(linha).is_empty()


func _parar() -> void:
	velocity = Vector2.ZERO
	agente.velocity = Vector2.ZERO


func receber_dano(quantidade: int = 1) -> void:
	if not ativo or morto or quantidade <= 0:
		return
	vida = maxi(0, vida - quantidade)
	vida_alterada.emit(vida, vida_maxima)
	if vida == 0:
		mudar_estado(Estado.MORTO)
		morreu.emit()
		queue_free()
	else:
		mudar_estado(Estado.FERIDO)


func desativar() -> void:
	ativo = false
	_parar()
	agente.avoidance_enabled = false
	set_physics_process(false)
