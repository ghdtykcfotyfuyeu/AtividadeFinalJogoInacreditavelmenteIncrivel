extends "res://scripts/inimigo.gd"
# Origem: Criado com ChatGPT/Codex sobre inimigo.gd; animacoes do sprite fornecido para o professor.

# Reutiliza vida, contato e navegacao das provas; acrescenta as animacoes.
var direcao: String = "baixo"
@onready var animacao: AnimatedSprite2D = $Visual


func _ready() -> void:
	super._ready()
	estado_alterado.connect(_ao_mudar_estado)
	_atualizar_movimento()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if ativo and not morto and estado in [Estado.NASCENDO, Estado.PERSEGUINDO]:
		_atualizar_movimento()


func _atualizar_movimento() -> void:
	if velocity.length_squared() > 4.0 and estado == Estado.PERSEGUINDO:
		direcao = _direcao_do_vetor(velocity)
		_tocar("andar_" + direcao)
	else:
		_tocar("idle_" + direcao)


func _direcao_do_vetor(vetor: Vector2) -> String:
	if vetor.is_zero_approx():
		return direcao
	if absf(vetor.x) > absf(vetor.y):
		return "direita" if vetor.x > 0.0 else "esquerda"
	return "baixo" if vetor.y > 0.0 else "cima"


func _tocar(nome: String) -> void:
	# Nao reinicia o quadro a cada atualizacao de movimento.
	if animacao.animation != StringName(nome) or not animacao.is_playing():
		animacao.play(nome)


func _ao_mudar_estado(_anterior: int, atual: int) -> void:
	match atual:
		Estado.PERSEGUINDO:
			_atualizar_movimento()
		Estado.ATACANDO:
			direcao = _direcao_do_vetor(jogador.global_position - global_position)
			animacao.modulate = cor_original
			animacao.play("atacar_" + direcao)
		Estado.FERIDO:
			animacao.play("dano_" + direcao)
			animacao.set_frame_and_progress(0, 0.0)


func _ao_morrer() -> void:
	# O professor fica visivel caindo, mas nao bloqueia nem machuca o aluno.
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	$CollisionShape2D.set_deferred("disabled", true)
	contato.set_deferred("monitoring", false)
	animacao.modulate = cor_original
	animacao.play("derrota")
	await animacao.animation_finished
	# A contagem e a vitoria so avancam quando a queda termina.
	morreu.emit()
	queue_free()


func desativar() -> void:
	super.desativar()
	animacao.pause()
