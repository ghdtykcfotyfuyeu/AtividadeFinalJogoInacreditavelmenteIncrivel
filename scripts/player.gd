extends CharacterBody2D

signal vida_alterada(atual: int, maxima: int)
signal morreu

@export var velocidade: float = 140.0
@export var intervalo_ataque: float = 0.4
@export var vida_maxima: int = 5
@export var duracao_invulneravel: float = 1.0

var vida: int = 5
var morto: bool = false
var ativo: bool = true
var invulneravel: float = 0.0
var recuo: Vector2 = Vector2.ZERO
var ultima_direcao: Vector2 = Vector2.DOWN
var tempo_recarga: float = 0.0
var atacando: bool = false
var golpe_pendente: bool = false
var golpe_aplicado: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ataque_lapis: Node2D = $AtaqueLapis
@onready var forma_ataque: CollisionShape2D = $AtaqueLapis/Area2D/CollisionShape2D


func _ready() -> void:
	vida = vida_maxima
	sprite.play("idle_baixo")
	vida_alterada.emit(vida, vida_maxima)


func _physics_process(delta: float) -> void:
	if not ativo or morto:
		return
	invulneravel = maxf(0.0, invulneravel - delta)
	if invulneravel > 0.0:
		sprite.modulate = Color(1.0, 0.55, 0.55)
		sprite.modulate.a = 0.5 if fmod(invulneravel, 0.16) < 0.08 else 1.0
	else:
		sprite.modulate = Color.WHITE
	# O sinal da animacao agenda o golpe; a consulta ocorre no passo de fisica.
	if golpe_pendente:
		_aplicar_dano()
	if not ativo:
		return

	var direcao = Input.get_vector(
		"mover_esquerda", "mover_direita", "mover_cima", "mover_baixo"
	)
	velocity = direcao * velocidade + recuo
	recuo = recuo.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()

	tempo_recarga = maxf(0.0, tempo_recarga - delta)
	if not atacando:
		if direcao != Vector2.ZERO:
			ultima_direcao = _direcao_cardinal(direcao)
		if Input.is_action_pressed("atacar") and tempo_recarga <= 0.0:
			atacar()
		else:
			_atualizar_animacao(direcao)


func _direcao_cardinal(direcao: Vector2) -> Vector2:
	# A caminhada pode ser diagonal; o desenho e o golpe usam quatro direcoes.
	if absf(direcao.x) > absf(direcao.y):
		return Vector2.RIGHT if direcao.x > 0.0 else Vector2.LEFT
	return Vector2.DOWN if direcao.y >= 0.0 else Vector2.UP


func _nome_direcao() -> String:
	if ultima_direcao.x > 0.0:
		return "direita"
	if ultima_direcao.x < 0.0:
		return "esquerda"
	return "cima" if ultima_direcao.y < 0.0 else "baixo"


func _atualizar_animacao(direcao: Vector2) -> void:
	if direcao != Vector2.ZERO:
		ultima_direcao = _direcao_cardinal(direcao)
	var acao = "andar_" if direcao != Vector2.ZERO else "idle_"
	var animacao = acao + _nome_direcao()
	# Nao reinicia a sequencia a cada quadro de movimento.
	if sprite.animation != animacao:
		sprite.play(animacao)


func atacar() -> void:
	if not ativo or morto or atacando or tempo_recarga > 0.0:
		return
	atacando = true
	golpe_aplicado = false
	golpe_pendente = false
	tempo_recarga = intervalo_ataque
	ultima_direcao = _direcao_cardinal(ultima_direcao)
	ataque_lapis.rotation = ultima_direcao.angle()
	sprite.play("atacar_" + _nome_direcao())
	sprite.set_frame_and_progress(0, 0.0)


func _on_frame_changed() -> void:
	# O terceiro quadro mostra o lapis estendido. Um golpe causa dano uma vez.
	if ativo and atacando and sprite.frame >= 2 and not golpe_aplicado:
		golpe_pendente = true


func _on_animation_finished() -> void:
	if not ativo or not atacando:
		return
	atacando = false
	_atualizar_animacao(Input.get_vector(
		"mover_esquerda", "mover_direita", "mover_cima", "mover_baixo"
	))


func _aplicar_dano() -> void:
	golpe_pendente = false
	if golpe_aplicado:
		return
	golpe_aplicado = true

	var consulta = PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma_ataque.shape
	consulta.transform = forma_ataque.global_transform
	consulta.collision_mask = 2
	var espaco = get_world_2d().direct_space_state
	for resultado in espaco.intersect_shape(consulta, 32):
		var inimigo = resultado.collider
		if not is_instance_valid(inimigo) or not inimigo.has_method("receber_dano"):
			continue
		# O lapis nao acerta provas do outro lado de uma carteira.
		var linha = PhysicsRayQueryParameters2D.create(
			global_position, inimigo.global_position, 1
		)
		if espaco.intersect_ray(linha).is_empty():
			inimigo.receber_dano(1)


func receber_dano(quantidade: int, origem: Vector2) -> bool:
	if not ativo or morto or invulneravel > 0.0 or quantidade <= 0:
		return false
	vida = maxi(0, vida - quantidade)
	invulneravel = duracao_invulneravel
	recuo = origem.direction_to(global_position) * 180.0
	vida_alterada.emit(vida, vida_maxima)
	if vida == 0:
		morto = true
		definir_ativo(false)
		sprite.modulate = Color(0.55, 0.55, 0.55)
		morreu.emit()
	return true


func recuperar_vida(quantidade: int) -> void:
	if morto:
		return
	vida = mini(vida_maxima, vida + quantidade)
	vida_alterada.emit(vida, vida_maxima)


func definir_ativo(valor: bool) -> void:
	ativo = valor and not morto
	if not ativo:
		velocity = Vector2.ZERO
		recuo = Vector2.ZERO
		golpe_pendente = false
		atacando = false
		sprite.pause()
	else:
		sprite.play("idle_" + _nome_direcao())
