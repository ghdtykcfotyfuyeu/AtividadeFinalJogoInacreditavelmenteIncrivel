extends SceneTree

var falhas: Array[String] = []
var verificacoes := 0
var cena
var aluno
var spawner
var estados: Array[int] = []

func _init() -> void:
	validar.call_deferred()

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas.append(mensagem)
		push_warning(mensagem)

func passos(n: int) -> void:
	for i in range(n):
		await physics_frame

func novo_jogo(onda_inicial: int = 0) -> void:
	for acao in ["atacar", "mover_cima", "mover_baixo", "mover_direita", "mover_esquerda", "reiniciar"]:
		Input.action_release(acao)
	if is_instance_valid(cena):
		cena.queue_free()
		await passos(3)
	seed(12345)
	cena = load("res://mapa/sala.tscn").instantiate()
	cena.intervalo_ondas = 0.1
	cena.onda_atual = onda_inicial
	root.add_child(cena)
	current_scene = cena
	aluno = cena.get_node("Entidades/Player")
	spawner = cena.get_node("Entidades/Spawner")
	await passos(125)

func pausar(prova) -> void:
	prova.set_physics_process(false)
	prova.agente.avoidance_enabled = false
	prova.velocity = Vector2.ZERO
	prova.collision_layer = 0
	prova.collision_mask = 0

func atacar_uma_vez() -> void:
	Input.action_press("atacar")
	await passos(3)
	Input.action_release("atacar")
	await passos(30)

func registrar_estado(_anterior: int, atual: int) -> void:
	estados.append(atual)

func validar() -> void:
	await novo_jogo()
	conferir(spawner.vivos == 6 and spawner.pendentes == 0, "Primeira onda com seis provas")
	conferir(aluno.vida == 5 and cena.estado == cena.EstadoPartida.ONDA, "Inicio com vida completa")
	for prova in get_nodes_in_group("inimigos"):
		pausar(prova)
	var sprite: AnimatedSprite2D = aluno.sprite
	conferir(sprite.sprite_frames.get_animation_names().size() == 12, "Doze animacoes preservadas")
	for nome in ["baixo", "direita", "cima", "esquerda"]:
		aluno.position = Vector2(836, 520)
		Input.action_press("mover_" + nome)
		await passos(17)
		conferir(sprite.animation == StringName("andar_" + nome) and sprite.frame > 0, "Andar " + nome)
		Input.action_release("mover_" + nome)
		await passos(3)
		conferir(sprite.animation == StringName("idle_" + nome), "Idle " + nome)
		await atacar_uma_vez()
		conferir(not aluno.atacando and sprite.animation == StringName("idle_" + nome), "Fim do ataque " + nome)

	# Invulnerabilidade global impede dez danos no mesmo instante.
	conferir(aluno.receber_dano(1, aluno.position + Vector2.LEFT * 10), "Primeiro dano aceito")
	for i in range(10):
		aluno.receber_dano(1, aluno.position)
	conferir(aluno.vida == 4, "Contato simultaneo desconta apenas uma vida")
	conferir(cena.get_node("HUD/Painel/Texto").text.begins_with("Vida: 4/5"), "HUD acompanha vida")
	await passos(65)
	conferir(aluno.receber_dano(1, aluno.position), "Protecao termina")
	aluno.recuperar_vida(100)
	conferir(aluno.vida == 5, "Cura limitada ao maximo")
	await passos(65)

	var alvo = get_nodes_in_group("inimigos")[0]
	aluno.position = Vector2(836, 520)
	aluno.ultima_direcao = Vector2.RIGHT
	alvo.position = aluno.position + Vector2(36, 0)
	alvo.vida = 3
	alvo.collision_layer = 2
	await passos(3)
	Input.action_press("atacar")
	await passos(3)
	Input.action_release("atacar")
	conferir(alvo.vida == 3, "Sem dano antes do terceiro quadro")
	await passos(12)
	conferir(alvo.vida == 2, "Dano sincronizado com o lapis")
	await passos(25)
	conferir(alvo.vida == 2, "Um dano por golpe")

	# Alvo no alcance da area, mas protegido pelo canto de uma carteira.
	aluno.position = Vector2(264, 249)
	aluno.ultima_direcao = Vector2.UP
	alvo.position = Vector2(295, 205)
	await passos(3)
	Input.action_press("atacar")
	await passos(3)
	Input.action_release("atacar")
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = aluno.forma_ataque.shape
	consulta.transform = aluno.forma_ataque.global_transform
	consulta.collision_mask = 2
	conferir(not aluno.get_world_2d().direct_space_state.intersect_shape(consulta).is_empty(), "Alvo protegido esta no alcance geometrico")
	await passos(30)
	conferir(alvo.vida == 2, "Lapis nao atravessa carteira")

	# Maquina de estados, contato real e retorno apos ferimento.
	aluno.position = Vector2(836, 520)
	alvo.position = Vector2(795, 520)
	alvo.collision_mask = 5
	alvo.estado_alterado.connect(registrar_estado)
	alvo.mudar_estado(alvo.Estado.PERSEGUINDO)
	alvo.agente.avoidance_enabled = true
	alvo.set_physics_process(true)
	await passos(100)
	conferir(estados.has(alvo.Estado.ATACANDO) and aluno.vida < 5, "Inimigo ataca e causa dano por contato")
	aluno.position = Vector2(1000, 520)
	alvo.receber_dano(1)
	conferir(alvo.estado == alvo.Estado.FERIDO, "Estado ferido")
	await passos(15)
	conferir(alvo.estado == alvo.Estado.PERSEGUINDO, "Ferido retorna a perseguicao")

	# Navegacao continua desviando da carteira, mesmo com a nova maquina.
	aluno.position = Vector2(420, 266)
	aluno.invulneravel = 20.0
	alvo.position = Vector2(200, 266)
	alvo.tempo_busca = 0.0
	alvo.agente.set_velocity_forced(Vector2.ZERO)
	var desvio := 0.0
	for i in range(600):
		await physics_frame
		desvio = maxf(desvio, absf(alvo.position.y - 266.0))
	conferir(desvio > 50.0 and alvo.position.distance_to(aluno.position) < 35.0, "Contorna a carteira")
	alvo.receber_dano(1)
	conferir(alvo.estado == alvo.Estado.MORTO and alvo.morto, "Estado morto")
	await passos(3)

	# Partida completa: eliminacoes feitas pelo ataque do aluno.
	await novo_jogo()
	for numero in range(1, 4):
		await passos(125)
		conferir(cena.onda_atual == numero and cena.estado == cena.EstadoPartida.ONDA, "Inicia onda " + str(numero))
		conferir(spawner.vivos == [6, 8, 10][numero - 1], "Quantidade da onda " + str(numero))
		for prova in get_nodes_in_group("inimigos"):
			pausar(prova)
		aluno.vida = 4
		for prova in get_nodes_in_group("inimigos"):
			aluno.position = Vector2(836, 520)
			aluno.ultima_direcao = Vector2.RIGHT
			prova.position = Vector2(872, 520)
			prova.collision_layer = 2
			await passos(3)
			await atacar_uma_vez()
			conferir(not is_instance_valid(prova), "Ataque elimina prova da onda " + str(numero))
		conferir(aluno.vida == 5, "Recupera uma vida ao concluir onda " + str(numero))
	await passos(90)
	conferir(cena.estado == cena.EstadoPartida.CHEFE and spawner.vivos == 1, "Chefe surge depois da terceira onda")
	var chefe = get_nodes_in_group("inimigos")[0]
	conferir(chefe.eh_chefe and chefe.vida == 12 and chefe.dano == 2, "Configuracao do chefe")
	conferir(cena.get_node("HUD/Chefe").visible, "Barra de vida do chefe")
	# O corpo maior do chefe tambem deve conseguir contornar a carteira.
	aluno.position = Vector2(420, 266)
	aluno.invulneravel = 20.0
	chefe.position = Vector2(200, 266)
	chefe.tempo_busca = 0.0
	chefe.agente.set_velocity_forced(Vector2.ZERO)
	var desvio_chefe := 0.0
	for i in range(600):
		await physics_frame
		desvio_chefe = maxf(desvio_chefe, absf(chefe.position.y - 266.0))
	conferir(desvio_chefe > 50.0 and chefe.position.distance_to(aluno.position) < 40.0, "Chefe contorna a carteira")
	# Primeiro confirma o ataque do chefe em movimento real.
	aluno.position = Vector2(836, 520)
	aluno.invulneravel = 0.0
	chefe.position = Vector2(790, 520)
	chefe.mudar_estado(chefe.Estado.PERSEGUINDO)
	chefe.tempo_busca = 0.0
	chefe.agente.set_velocity_forced(Vector2.ZERO)
	for i in range(180):
		await physics_frame
		if aluno.vida < 5:
			break
	conferir(aluno.vida == 3, "Chefe desconta duas vidas por contato")
	pausar(chefe)
	chefe.collision_layer = 2
	for i in range(12):
		aluno.position = Vector2(836, 520)
		aluno.ultima_direcao = Vector2.RIGHT
		chefe.position = Vector2(872, 520)
		await passos(3)
		await atacar_uma_vez()
		if i == 0:
			conferir(cena.get_node("HUD/Chefe/Coluna/Barra").value == 11, "Vida do chefe atualiza ao receber dano")
	conferir(cena.estado == cena.EstadoPartida.VITORIA, "Vitoria ao derrotar chefe")
	conferir(spawner.derrotados == 25 and spawner.vivos == 0 and not spawner.ativo, "Contagem final e spawner encerrado")
	conferir(cena.get_node("HUD/Resultado").visible and not aluno.ativo, "Tela de vitoria e controles bloqueados")
	var tempo_final: float = cena.tempo_partida
	await passos(90)
	conferir(cena.tempo_partida == tempo_final and get_nodes_in_group("inimigos").is_empty(), "Nada continua apos vitoria")
	cena.get_node("HUD/Resultado/Centro/Painel/Margem/Coluna/Reiniciar").pressed.emit()
	await passos(300)
	cena = current_scene
	aluno = cena.get_node("Entidades/Player")
	spawner = cena.get_node("Entidades/Spawner")
	conferir(aluno.vida == 5 and cena.onda_atual == 1 and spawner.derrotados == 0, "Botao reinicia a partida")

	# Sem comandos: os inimigos conseguem encostar e causar derrota real.
	for i in range(3600):
		await physics_frame
		if cena.estado == cena.EstadoPartida.DERROTA:
			break
	conferir(cena.estado == cena.EstadoPartida.DERROTA and aluno.vida == 0, "Derrota por ataques dos inimigos")
	conferir(cena.get_node("HUD/Resultado").visible and not spawner.ativo, "Tela de derrota e fim dos nascimentos")
	var posicao_final: Vector2 = aluno.position
	tempo_final = cena.tempo_partida
	Input.action_press("mover_direita")
	Input.action_press("atacar")
	await passos(90)
	Input.action_release("mover_direita")
	Input.action_release("atacar")
	conferir(aluno.position == posicao_final and cena.tempo_partida == tempo_final, "Partida congelada na derrota")
	var evento := InputEventAction.new()
	evento.action = "reiniciar"
	evento.pressed = true
	Input.parse_input_event(evento)
	await passos(300)
	cena = current_scene
	aluno = cena.get_node("Entidades/Player")
	conferir(not aluno.morto and aluno.vida == 5 and cena.onda_atual == 1, "Tecla R reinicia")
	print(JSON.stringify({"falhas": falhas, "verificacoes": verificacoes, "ondas": [6, 8, 10], "vida_chefe": 12, "desvio_carteira": desvio, "desvio_chefe": desvio_chefe}))
	quit(0 if falhas.is_empty() else 1)
