# Verificacao da versao atual — 18/11/2026

## Logica e recursos

- Godot 4.6.3, renderer Compatibility.
- 69 verificacoes automatizadas aprovadas, incluindo quatro direcoes, animacoes,
  colisoes, golpe bloqueado por mesas, invulnerabilidade, FSM e navegacao.
- O teste roda 60 segundos de fisica sem matar provas e confirma o nascimento do chefe.
- Horda cheia: dez provas e um professor, sem duplicar chefe e sem exigir abates.
- Matar uma prova libera vaga; o proximo nascimento a repoe. O HUD mostra o abate.
- Professor com dez vidas, ataque, navegacao, animacao de derrota, vitoria e reinicio.
- Vitoria funciona com provas restantes; derrota para controles, timers e inimigos.
- Camera fixa e arena inteira visivel; colisao testada nos quatro muros.
- Simulacao adicional de 7.200 quadros manteve onze inimigos sem erros.

Os testes protegem e reposicionam o aluno em trechos controlados. Isso permite
verificar as regras, mas nao substitui um teste de dificuldade feito por uma pessoa.

## Desempenho com renderizacao

- Resolucao: 1152 x 656; limite: 60 FPS.
- Dez provas e professor ativos, com a sombra do ventilador.
- Amostras: 1800 quadros em 30.05 segundos.
- Media: 59.91 FPS; percentil 95: 17.482 ms.
- Quadros acima de 50 ms: 0.
- Renderizacao por software: llvmpipe (LLVM 19.1.7, 256 bits).

A captura `capturas/partida.png` e desta versao. O resultado descreve este ambiente;
confira o desempenho no computador da apresentacao com F3.

## Exportacoes

- **Linux:** executavel release aberto fora do editor, com cenario completo,
  contagem, nascimentos de provas e tela de derrota. Sem erros de script no log final.
- **Windows:** exportacao release x86_64 gerada; nao executada neste ambiente Linux.
- **Web:** exportacao gerada e pagina de apresentacao conferida no navegador.
  A captura enviada pelo aluno em 18/11 mostra a partida aberta no navegador,
  com vida 5/5, tres abates e 46 segundos restantes ate o chefe. Essa imagem
  confirma o inicio da partida, mas nao comprova vitoria, derrota ou desempenho web.
  O navegador remoto deste ambiente nao oferece WebGL 2 para testar a partida.
- A primeira exportacao usando apenas a cena principal omitia as cenas carregadas
  pelo spawner. O preset passou a exportar todos os recursos, excluindo documentos,
  testes e pagina de apresentacao. As tres plataformas foram exportadas novamente.
- O driver grafico local informa que nao pode configurar V-Sync; o benchmark usa
  limite explicito de 60 FPS. Nao foi detectado erro de script no teste grafico.

## Ajuste de tela da exportacao web — 18/11/2026

- A captura do aluno revelou um canvas de tamanho fixo no canto superior esquerdo.
- Alterado `html/canvas_resize_policy` de Project (1) para Adaptive (2).
- O projeto ja usa `canvas_items` com preservacao de proporcao; o canvas agora
  acompanha a janela ou o iframe, mantendo a arena inteira visivel.
- O pacote web foi exportado novamente. A escala final precisa ser conferida
  no navegador do aluno, inclusive ao entrar e sair da tela cheia.
- Adicionado `exports/.gdignore` para evitar que a Godot reimporte os arquivos
  gerados como recursos e duplique os identificadores das imagens exportadas.
- Pequenas faixas nas bordas podem permanecer em telas com proporcao diferente.

## Publicacao no itch.io — 18/11/2026

- Pagina publica: https://ghdtykcfotyfuyeu.itch.io/provas-voadoras.
- Acesso sem autenticacao retornou HTTP 200, titulo Provas Voadoras e area de jogo HTML.
- O aluno confirmou o sucesso da publicacao e aceitou o enquadramento mostrado nas capturas.
- Esta verificacao confirma o acesso a pagina; nao representa um novo teste completo de jogabilidade no navegador deste ambiente.

## Reproduzir os testes do projeto

```bash
godot --headless --editor --path . --import --quit
godot --headless --path . --fixed-fps 60 --script res://scripts/testes/test_partida.gd
godot --headless --path . --fixed-fps 60 --script res://scripts/testes/test_horda.gd
godot --path . --script res://scripts/testes/test_horda.gd
```

Os relatorios em `historico/` pertencem a versoes antigas, com ondas finitas.
