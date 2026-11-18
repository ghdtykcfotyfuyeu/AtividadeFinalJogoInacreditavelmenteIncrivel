# Verificação da versão completa

## Atualização: professor como chefe — 11/11/2026

Ambiente: Godot 4.6.3, Linux, OpenGL Compatibility.

- `scripts/testes/test_partida.gd`: **87 verificações aprovadas**, sem falhas.
- As três ondas continuam contendo 6, 8 e 10 provas; o professor surge depois.
- A navegação real ativa as animações de caminhada nas quatro direções.
- A luta mantém 12 vidas no chefe, 2 de dano por contato e bloqueio pelas mesas.
- A queda fica visível, sem colisão nem dano, antes da tela de vitória.
- Novos golpes durante a queda não duplicam a contagem: total final de 25.
- Renderização gráfica conferida para perseguição, ataque, dano, queda e vitória.
- Capturas `professor_andando.png`, `professor_luta.png` e `professor_derrota.png`
  mostram o chefe integrado. Nesse teste visual, a luta começou diretamente no
  chefe e o aluno ficou protegido para permitir conferir as animações.

O teste visual não altera a partida normal. O PNG original do professor é usado
com 72 regiões AtlasTexture, sem redesenho nem substituição da arte enviada.
Os números de FPS mais abaixo continuam sendo os da versão antiga.

## Atualização: sombra do ventilador — 11/11/2026

Ambiente desta atualização: Godot 4.6.3, Linux, OpenGL Compatibility.

- `scripts/testes/test_partida.gd`: 78 verificações aprovadas, sem falhas.
- Cena principal executada com imagem; shader compilado e sombra visível.
- Rotação confirmada em posições diferentes das pás durante a partida.
- Bordas suaves e transparência conferidas sobre os ladrilhos do piso.
- Aluno e provas continuam desenhados acima da sombra; HUD permanece legível.
- Reinício pela tecla R conferido com o efeito presente.

O formato do projeto continua sendo o da Godot 4.4. A atualização adiciona
uma única projeção 2D animada; não usa simulação de iluminação 3D. Os números
de desempenho abaixo são históricos, anteriores à sombra, e não foram
medidos novamente nesta atualização.

## Verificação anterior — 04/11/2026

Ambiente: Godot 4.4.1, Linux, OpenGL Compatibility. Verificação em 04/11/2026.

## Funcionalidade

`scripts/testes/test_partida.gd` passou nas 78 verificações, incluindo:

- movimento, idle e retorno após ataque nas quatro direções;
- dano sincronizado com o lápis e sem repetição no mesmo golpe;
- bloqueio do lápis pelo canto de uma carteira;
- vida, HUD, proteção contra dano simultâneo e limite de recuperação;
- estados de ataque, ferimento, perseguição e morte;
- prova comum e chefe contornando uma carteira;
- ondas de 6, 8 e 10 inimigos, com recuperação de uma vida;
- chefe com 12 pontos de vida e dano de contato igual a 2;
- vitória depois de 25 eliminações, derrota por dano real dos inimigos;
- interrupção da partida e reinício pelo botão e pela tecla R.

A parte de progressão posiciona os inimigos para conferir o alcance e os golpes.
Os testes de contato e navegação mantêm a inteligência dos inimigos funcionando.
As imagens em `capturas/` servem para conferir a interface; sua progressão foi
acelerada e o tempo mostrado nelas não representa a duração normal de uma partida.

## Horda completa

`scripts/testes/test_horda.gd` inicia a terceira onda e protege o aluno apenas dentro do teste,
para manter os dez inimigos ativos durante a medição. Não altera a partida normal.
A simulação sem renderização completou 7.200 quadros sem falhas.

O teste com imagem manteve dez inimigos perseguindo o aluno, que se movimentou
continuamente. A resolução foi de 1152 × 656 e o limite foi de 60 FPS.

| Medida | Resultado |
| --- | --- |
| Renderizador | Mesa llvmpipe, LLVM 20.1.2, software |
| Quadros medidos após aquecimento | 1.800 |
| Duração medida | 30,23 segundos |
| FPS médio | 59,53 |
| Tempo por quadro, percentil 95 | 17,87 ms |
| Quadros acima de 50 ms | 3 |
| Erros de execução | Nenhum |

O ambiente gráfico virtual avisou que não permite alterar V-Sync; a medição usou
o limite de quadros do motor. O resultado não substitui a conferência no computador
da apresentação. Use F3 na partida normal para visualizar FPS e inimigos ativos.

## Executar novamente

Abra o terminal na pasta que contém `project.godot`. Troque `godot` pelo caminho
do executável da Godot se ele não estiver disponível no PATH.

```sh
godot --headless --path . --fixed-fps 60 --script res://scripts/testes/test_partida.gd
godot --headless --path . --fixed-fps 60 --script res://scripts/testes/test_horda.gd
godot --path . --script res://scripts/testes/test_horda.gd
```

O último comando abre uma janela e mede o desempenho real da renderização.
Não use `--fixed-fps` nele. Ele também salva `teste_horda.png` na pasta de dados
do usuário do jogo (`user://`). Os testes encerram com código 0 quando passam.
