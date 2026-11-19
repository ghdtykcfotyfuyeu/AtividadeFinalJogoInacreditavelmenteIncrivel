# Origem do codigo e adaptacoes

Veja tambem a [lista de uso de inteligencia artificial no projeto](USO_DE_IA.md).

Referencia principal: Ezefferth C. A. Fernandes, Jogos Digitais II,
[construcao-jogo-godot, tag aula-10](https://github.com/ezefferth/construcao-jogo-godot/tree/aula-10).
Tambem foram usados os PDFs `projeto(1).pdf`, `roteiro-pratica.pdf` (aula 09)
e `roteiro-pratica (1).pdf` (aula 10), fornecidos pelo aluno.

| Exemplo fornecido | Aplicacao neste jogo | Adaptacao |
| --- | --- | --- |
| `jogador.gd`: Input.get_vector e move_and_slide | `scripts/player.gd` | Mesma movimentacao, com animacoes idle/andar/atacar em quatro direcoes. |
| `jogador.gd`: vida, invencibilidade de 1 s, recarga de 0,4 s | `scripts/player.gd` | Cinco vidas, golpe sincronizado com o lapis e teste de parede entre alvo e aluno. |
| `inimigo.gd`: NavigationAgent2D, target_position e get_next_path_position | `scripts/inimigo.gd` | Maquina de estados, consulta a cada 0,22 s e desvio entre agentes. |
| `inimigo.gd`: vida e aviso de morte | `scripts/inimigo.gd`, `scripts/spawner.gd` | Signal informa a morte a sala e libera uma vaga. |
| `vila.gd`: Timer Horda, intervalo x 0,95 e minimo 0,5 | `scripts/sala.gd` e `scripts/spawner.gd` | Limite de dez provas, pontos livres e distancia segura de nascimento. |
| `vila.gd`: abates e ceil(relogio.time_left) | `scripts/sala.gd` e `scripts/hud.gd` | Placar compacto, sempre visivel. |
| Ficha Chefe do roteiro: Relogio 60 s, vida 10 e vencer ao matar o chefe | `_on_relogio_timeout` e `inimigo_morreu`, em `scripts/sala.gd` | Professor com sprite proprio; vitoria depois da animacao de derrota. |
| `fim.gd`: reiniciar a cena | `scripts/sala.gd` e `scripts/hud.gd` | Botao e tecla R; recarregamento adiado ate terminar o quadro. |

O codigo foi adaptado com **ChatGPT/Codex**, incluindo os testes, a maquina de
estados, os sprites animados e a sombra. Ele nao e uma copia literal de todos os
exemplos: os nomes dos nos, a arte e as colisoes sao os deste projeto.
O `vila.gd` base do professor usa vitoria por tempo; a ficha Chefe do PDF substitui
essa funcao para fazer nascer o chefe. Esta versao usa a substituicao da ficha.

## O que explicar na apresentacao

1. `scenes/sala.tscn` junta o cenario, entidades, navegacao, camera, HUD e timers.
2. `player.gd` le as teclas, move com colisao e aplica dano no quadro do lapis.
3. `inimigo.gd` alterna entre nascer, perseguir, atacar, ficar ferido e morrer.
4. O agente calcula o caminho; o corpo anda ate o proximo ponto desse caminho.
5. `Horda` pede novos inimigos; o spawner verifica limite e posicao segura.
6. `Relogio` termina em 60 segundos e cria o professor. Matar provas nao antecipa isso.
7. A morte informa a sala; se o inimigo e o professor, vence. Vida zero do aluno perde.
8. Vitoria e derrota param os timers, os controles e os inimigos. Reiniciar recria a cena.
