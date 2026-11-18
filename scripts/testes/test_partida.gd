extends SceneTree
# Origem: verificacoes desenvolvidas com ChatGPT/Codex; exercitam as regras do roteiro e as regressoes de combate.

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

func novo_jogo(preparar_mecanicas: bool = true) -> void:
	for acao in ["atacar", "mover_cima", "mover_baixo", "mover_direita", "mover_esquerda", "reiniciar"]:
		Input.action_release(acao)
	if is_instance_valid(cena):
		cena.queue_free()
		await passos(3)
	seed(12345)
	cena = load("res://scenes/sala.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	aluno = cena.get_node("Entidades/Player")
	spawner = cena.get_node("Entidades/Spawner")
	await passos(6)
	if preparar_mecanicas:
		cena.horda.stop()
		cena.relogio.stop()
		for i in range(6):
			spawner.criar_inimigo()
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
	conferir(spawner.provas_vivas == 6, "Seis provas preparadas para testar combate")
	conferir(aluno.vida == 5 and cena.estado == cena.EstadoPartida.HORDA, "Inicio com vida completa")
	for prova in get_nodes_in_group("inimigos"):
		pausar(prova)
	var camera: Camera2D = cena.get_node("Camera2D")
	var area_visivel: Vector2 = root.get_visible_rect().size / camera.zoom
	conferir(area_visivel.x >= 1672.0 and area_visivel.y >= 941.0, "Arena inteira cabe na tela")
	var centro_camera := camera.global_position
	var direcoes_muro := {"esquerda": Vector2(110, 520), "direita": Vector2(1600, 520), "cima": Vector2(600, 165), "baixo": Vector2(836, 860)}
	for direcao in direcoes_muro:
		aluno.position = direcoes_muro[direcao]
		Input.action_press("mover_" + direcao)
		await passos(60)
		Input.action_release("mover_" + direcao)
		conferir(aluno.position.x >= 96.0 and aluno.position.x <= 1616.1 and aluno.position.y >= 154.0 and aluno.position.y <= 876.1, "Colisao impede atravessar muro " + direcao)
	conferir(camera.global_position == centro_camera, "Camera permanece fixa ao mover aluno")
	await passos(3)
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

	# O relogio real roda 60 segundos de fisica: nenhum abate e necessario.
	await novo_jogo(false)
	aluno.invulneravel = 200.0
	while cena.tempo_partida < 59.8:
		await physics_frame
	conferir(cena.estado == cena.EstadoPartida.HORDA and not is_instance_valid(cena.chefe), "Chefe nao aparece antes dos 60 segundos")
	conferir(cena.abates == 0 and spawner.provas_vivas == 10, "Horda atinge dez provas sem exigir abates")
	conferir(is_equal_approx(cena.horda.wait_time, 0.5), "Horda acelera ate o intervalo minimo do roteiro")
	conferir(cena.hud.texto.text.contains("Abates: 0") and cena.hud.texto.text.contains("Chefe em: 1s"), "Placar de abates e contagem visiveis")
	await passos(20)
	conferir(cena.estado == cena.EstadoPartida.CHEFE and cena.tempo_partida < 60.3, "Chefe surge aos 60 segundos sem eliminar a horda")
	var chefe = cena.chefe
	conferir(is_instance_valid(chefe) and chefe.vida == 10 and chefe.dano == 2, "Professor com dez vidas e dois de dano")
	conferir(get_nodes_in_group("inimigos").size() == 11, "Chefe surge mesmo com a horda cheia")
	conferir(spawner.criar_inimigo(true) == null, "Nao nasce um segundo chefe")
	conferir(cena.hud.texto.text.contains("Derrote o professor"), "HUD troca contagem pelo objetivo do chefe")
	conferir(cena.get_node("HUD/Chefe").visible, "Barra de vida do chefe")
	conferir(chefe.animacao.sprite_frames.get_animation_names().size() == 17, "Professor com dezessete animacoes")
	conferir(cena.get_node("HUD/Chefe/Coluna/Texto").text.begins_with("PROFESSOR"), "HUD identifica o professor")
	# Eliminar uma prova libera uma vaga, que o proximo nascimento repoe.
	var prova_reposta = get_nodes_in_group("inimigos")[0]
	prova_reposta.receber_dano(1)
	await passos(40)
	conferir(cena.abates == 1 and spawner.provas_vivas == 10, "Horda repoe uma prova morta respeitando o limite")
	conferir(cena.hud.texto.text.contains("Abates: 1"), "Placar mostra o abate imediatamente")
	cena.horda.stop()
	for prova in get_nodes_in_group("inimigos"):
		if prova != chefe:
			pausar(prova)
			prova.position = Vector2(1500, 850)
	# As provas restantes continuam presentes: a vitoria depende somente do chefe.
	var abates_antes_chefe: int = cena.abates
	# A animacao acompanha a direcao real da perseguicao, nas quatro direcoes.
	aluno.invulneravel = 20.0
	var direcoes := {"baixo": Vector2.DOWN, "direita": Vector2.RIGHT, "cima": Vector2.UP, "esquerda": Vector2.LEFT}
	for nome in direcoes:
		chefe.set_physics_process(false)
		chefe.agente.avoidance_enabled = false
		chefe.velocity = Vector2.ZERO
		chefe.position = Vector2(836, 520)
		aluno.position = chefe.position + direcoes[nome] * 150.0
		# Teleportes do teste precisam atualizar a Area2D antes de retomar a IA.
		await passos(3)
		chefe.mudar_estado(chefe.Estado.PERSEGUINDO)
		chefe.tempo_busca = 0.0
		chefe.agente.set_velocity_forced(Vector2.ZERO)
		chefe.agente.avoidance_enabled = true
		chefe.set_physics_process(true)
		await passos(24)
		conferir(chefe.animacao.animation == StringName("andar_" + nome) and chefe.animacao.frame > 0, "Professor anda animado para " + nome)
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
	for i in range(10):
		aluno.position = Vector2(836, 520)
		aluno.ultima_direcao = Vector2.RIGHT
		chefe.position = Vector2(872, 520)
		await passos(3)
		await atacar_uma_vez()
		if i == 0:
			conferir(cena.get_node("HUD/Chefe/Coluna/Barra").value == 9, "Vida do chefe atualiza ao receber dano")
	conferir(is_instance_valid(chefe) and chefe.morto and chefe.visible and chefe.animacao.animation == &"derrota", "Professor mostra animacao de derrota")
	conferir(chefe.collision_layer == 0 and not chefe.contato.monitoring, "Professor derrotado nao bloqueia nem causa contato")
	conferir(cena.estado == cena.EstadoPartida.CHEFE and cena.abates == abates_antes_chefe, "Vitoria aguarda o fim da animacao")
	chefe.receber_dano(100)
	await passos(65)
	conferir(cena.estado == cena.EstadoPartida.VITORIA, "Vitoria ao derrotar chefe")
	conferir(cena.abates == abates_antes_chefe + 1 and spawner.provas_vivas == 10 and not spawner.ativo, "Contagem final e spawner encerrado")
	conferir(cena.get_node("HUD/Resultado").visible and not aluno.ativo, "Tela de vitoria e controles bloqueados")
	var tempo_final: float = cena.tempo_partida
	await passos(90)
	conferir(cena.tempo_partida == tempo_final and get_nodes_in_group("inimigos").all(func(i): return not i.ativo), "Nada continua apos vitoria")
	cena.get_node("HUD/Resultado/Centro/Painel/Margem/Coluna/Reiniciar").pressed.emit()
	await passos(300)
	cena = current_scene
	aluno = cena.get_node("Entidades/Player")
	spawner = cena.get_node("Entidades/Spawner")
	conferir(aluno.vida == 5 and cena.estado == cena.EstadoPartida.HORDA and cena.abates == 0, "Botao reinicia a partida")

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
	conferir(not aluno.morto and aluno.vida == 5 and cena.estado == cena.EstadoPartida.HORDA, "Tecla R reinicia")
	print(JSON.stringify({"falhas": falhas, "verificacoes": verificacoes, "chefe_em_segundos": 60, "vida_chefe": 10, "desvio_carteira": desvio, "desvio_chefe": desvio_chefe}))
	quit(0 if falhas.is_empty() else 1)
