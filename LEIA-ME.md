# Provas voadoras — sala de aula

Extraia o ZIP em uma **pasta nova**, importe `project.godot` na **Godot 4.4.1**
e pressione **F5**. A cena principal é `mapa/sala.tscn`.

## Objetivo e regras

Sobreviva às três ondas, elimine as provas de cada uma e derrote a **Prova Final**.
A vitória aparece quando o chefe morre. A derrota aparece quando a vida do aluno
chega a zero. Ambas as telas permitem iniciar outra partida.

| Etapa | Inimigos | Vida de cada inimigo | Dano por contato | Velocidade |
| --- | --- | --- | --- | --- |
| Onda 1 | 6 provas | 1 | 1 | 55 pixels/s |
| Onda 2 | 8 provas | 1 | 1 | 62 pixels/s |
| Onda 3 | 10 provas | 1 | 1 | 70 pixels/s |
| Chefe | 1 Prova Final | 12 | 2 | 78 pixels/s |

O aluno começa com **5 pontos de vida**. Depois de receber dano, pisca e fica
protegido por **1 segundo**, impedindo que vários inimigos retirem toda a vida
no mesmo instante. O contato também provoca um pequeno recuo com colisão.
Concluir cada onda recupera **1 ponto de vida**, até o máximo de 5, e inicia
um intervalo de **3 segundos** antes da próxima etapa.

Cada golpe de lápis causa 1 de dano no terceiro quadro da animação. O aluno pode
andar enquanto ataca; a direção do golpe permanece fixa até a sequência terminar.
Segurar Espaço repete o ataque aproximadamente a cada 0,4 segundo. Mesas e paredes
bloqueiam tanto o golpe do aluno quanto o dano de contato através de obstáculos.

A reposição infinita da versão anterior foi substituída por ondas finitas.
Os inimigos de uma onda nascem em intervalos de 0,14 segundo; a próxima onda só
começa depois de todos os inimigos da atual serem eliminados. O limite é de
**10 inimigos simultâneos**. A partida completa possui 24 provas comuns e o chefe.
Vitória e derrota interrompem controles, inimigos, novos nascimentos e cronômetro.

O painel superior mostra apenas **vida, onda e provas restantes**, em uma linha
compacta no canto da tela. O tempo e o total de provas derrotadas aparecem na tela final.

## Controles

| Tecla | Ação |
| --- | --- |
| WASD ou setas | Andar nas quatro direções; também permite diagonais normalizadas. |
| Espaço | Atacar com o lápis na direção para a qual o aluno está olhando. |
| R | Reiniciar após vitória ou derrota. |
| Enter ou clique no botão | Ativar “Jogar novamente” na tela final. |
| F3 | Mostrar ou esconder FPS e quantidade de inimigos. |

## Requisitos das aulas

| Aula | Implementação |
| --- | --- |
| 08 | Visão de cima, paredes com colisão, móveis sólidos e movimento nas quatro direções. |
| 09 | Vida do aluno e dos inimigos, ataque, dano por contato, ondas, chefe, vitória e derrota. |
| 10 | Máquina de estados explícita; provas e chefe perseguem o aluno e contornam os obstáculos. |
| 11 | Sprites temáticos e aluno animado; horda de dez inimigos verificada com renderização gráfica. |

## Organização

Todos os sete scripts ficam juntos em `scripts/`. Os arquivos `.gd.uid` nessa
pasta são identificadores usados pela Godot. As cenas continuam em suas pastas
de personagem, inimigos, mapa e interface, com as referências já atualizadas.

| Arquivo ou pasta | Responsabilidade |
| --- | --- |
| `player/player.tscn` | Aluno, AnimatedSprite2D, câmera, colisão e área do lápis. |
| `scripts/player.gd` | Movimento, animações, ataque, vida, invulnerabilidade e recuo. |
| `player/aluno_animacoes.tres` | 12 animações: idle, caminhada e ataque nas quatro direções. |
| `player/sprites/aluno_completo.png` | Atlas com 64 quadros de 64 × 64 pixels. |
| `player/ANIMACOES.md` | Explicação das animações e sincronização do golpe. |
| `scripts/inimigo.gd` | Máquina de estados compartilhada pelas provas e pelo chefe. |
| `inimigos/inimigo.tscn` | Prova comum, navegação e área de contato. |
| `inimigos/chefe/chefe.tscn` | Prova Final maior e avermelhada, com atributos próprios. |
| `scripts/spawner.gd` | Fila de nascimento, limite de inimigos, contagem e fim de onda. |
| `inimigos/ESTADOS.md` | Estados, transições e parâmetros de comportamento. |
| `scripts/sala.gd` | Progressão da partida, cura entre ondas e resultados finais. |
| `mapa/sala.tscn` | Sala completa com jogador, móveis, spawner, navegação e HUD. |
| `mapa/estrutura.tscn` | Piso, paredes e limites físicos. |
| `mapa/objetos/` | Cenas reutilizáveis dos móveis e enfeites. |
| `mapa/sprites/` | PNGs organizados em estrutura, móveis e decoração. |
| `mapa/CATALOGO.md` | Tamanhos dos sprites e formas de colisão. |
| `mapa/referencias/` | Referência artística e vista geral da sala. |
| `ui/` | Cenas do painel compacto, barra do chefe e telas finais. |
| `scripts/` | Todos os arquivos `.gd`, incluindo os dois testes automatizados. |
| `testes/` | Registro de verificação e capturas da interface. |

## Ajustar o jogo

As quantidades e velocidades das ondas ficam na constante `ONDAS`, em
`scripts/sala.gd`. O intervalo pode ser alterado no Inspetor da cena Sala.
A vida do aluno fica no Inspetor do Player; vida e dano do chefe ficam em
`inimigos/chefe/chefe.tscn`. O limite simultâneo e a distância de nascimento
ficam no Inspetor do Spawner. Mantenha o limite em dez para a configuração testada.

Para mover uma carteira, abra `mapa/sala.tscn`, expanda `Entidades → Moveis`
e mova a instância inteira. **Ctrl+D** duplica o objeto com imagem e colisão.
A navegação é recalculada ao iniciar a partida, considerando as posições atuais.
A origem dos móveis fica na base para facilitar o posicionamento e a ordem por Y.
Use **Depurar → Formas de Colisão Visíveis** para conferir as áreas sólidas.

A sala mede **1672 × 941 pixels**. Possui oito carteiras, mesa do professor,
estantes, armário, plantas, lousa, murais, relógio e porta. Os móveis e as quatro
paredes possuem colisão. Lousa, relógio e murais são decoração; a porta permanece
fechada. A câmera acompanha o aluno com zoom 1,5 e respeita os limites da sala.
A janela de referência é de 1152 × 656. As imagens usam filtro Nearest.

| Camada física | Uso |
| --- | --- |
| 1 — Cenario | Móveis, plantas e paredes. |
| 2 — Inimigos | Corpo das provas e seleção de alvos do lápis. |
| 3 — Player | Corpo do aluno e detecção de contato dos inimigos. |

## Desempenho e verificação

A navegação é preparada uma vez por partida. Cada inimigo atualiza o caminho a
cada 0,22 segundo; os nascimentos são espaçados, as entidades mortas são liberadas
e nunca existem mais de dez inimigos ativos. O chefe reutiliza a mesma lógica.

Foram aprovadas **78 verificações automatizadas** de combate, estados, navegação,
ondas, chefe, vitória, derrota e reinício. Uma simulação adicional manteve a
horda inteira durante 7.200 quadros, sem erros de execução.

Também foi executado um teste gráfico em 1152 × 656 com dez inimigos ativos:
**59,5 FPS médios**, com limite de 60, durante 1.800 quadros. A renderização usou
OpenGL Compatibility e Mesa llvmpipe (software). Houve três quadros acima de
50 ms; o percentil 95 foi 17,87 ms. O resultado descreve esse ambiente de teste;
F3 permite conferir os FPS no computador da apresentação.

Os testes e os detalhes do procedimento estão em `testes/VERIFICACAO.md`.
As artes foram criadas com auxílio de IA e estão incluídas no projeto; o jogo
não precisa de conexão com a internet.
