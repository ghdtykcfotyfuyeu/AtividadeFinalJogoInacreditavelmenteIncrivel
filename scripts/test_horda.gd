extends SceneTree

func _init() -> void:
	validar.call_deferred()

func validar() -> void:
	var visual := DisplayServer.get_name() != "headless"
	if visual:
		Engine.max_fps = 60
	seed(12345)
	var cena = load("res://mapa/sala.tscn").instantiate()
	cena.onda_atual = 2
	cena.intervalo_ondas = 0.1
	root.add_child(cena)
	current_scene = cena
	var aluno = cena.get_node("Entidades/Player")
	# Somente este teste protege o aluno para manter a horda inteira ativa.
	aluno.invulneravel = 1000.0
	for i in range(180):
		await process_frame
	cena.get_node("HUD/Desempenho").show()
	var amostras: Array[float] = []
	var falhas: Array[String] = []
	var inicio := Time.get_ticks_usec()
	var anterior := inicio
	var pico := 0
	var acoes = ["mover_direita", "mover_baixo", "mover_esquerda", "mover_cima"]
	var acao_atual := ""
	var quadros := 1800 if visual else 7200
	for i in range(quadros):
		if i % 100 == 0:
			if acao_atual != "":
				Input.action_release(acao_atual)
			acao_atual = acoes[(i / 100) % 4]
			Input.action_press(acao_atual)
		await process_frame
		var agora := Time.get_ticks_usec()
		amostras.append((agora - anterior) / 1000.0)
		anterior = agora
		var ativos := get_nodes_in_group("inimigos").size()
		pico = maxi(pico, ativos)
		if ativos != 10 and falhas.is_empty():
			falhas.append("A horda nao permaneceu com dez inimigos")
	Input.action_release(acao_atual)
	var tempo_real := (Time.get_ticks_usec() - inicio) / 1000000.0
	amostras.sort()
	var dados := {"falhas": falhas, "renderizacao": visual, "inimigos_pico": pico, "quadros": quadros, "tempo_real_s": tempo_real}
	if visual:
		dados["fps_medio"] = quadros / tempo_real
		dados["quadro_p95_ms"] = amostras[int(amostras.size() * 0.95)]
		dados["quadros_acima_50ms"] = amostras.filter(func(v): return v > 50.0).size()
		dados["adaptador"] = RenderingServer.get_video_adapter_name()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://teste_horda.png")
	print(JSON.stringify(dados))
	quit(0 if falhas.is_empty() else 1)
