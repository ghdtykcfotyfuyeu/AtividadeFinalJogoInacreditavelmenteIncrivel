# Máquina de estados dos inimigos

`scripts/inimigo.gd` declara `enum Estado`. A variável `estado` guarda o comportamento
atual e `mudar_estado()` centraliza as transições, a cor e a interrupção do movimento.
A prova comum usa esse script diretamente. O professor usa `scripts/chefe.gd`,
que herda a mesma máquina e acrescenta as animações. Os atributos ficam nas cenas.

| Estado | Comportamento | Transição |
| --- | --- | --- |
| NASCENDO | Aparece semitransparente e espera 0,35 segundo. | Vai para PERSEGUINDO. |
| PERSEGUINDO | Consulta a navegação, segue o aluno e contorna os móveis. | Ao detectar contato, vai para ATACANDO. |
| ATACANDO | Para, muda de cor e prepara um golpe de contato. | Após a recuperação, retorna a PERSEGUINDO. |
| FERIDO | Pisca em vermelho e interrompe o movimento por 0,16 segundo. | Se ainda tem vida, volta a PERSEGUINDO. |
| MORTO | Para, sai do grupo de inimigos, avisa o spawner e é removido. | Estado final. |

O professor reproduz uma animação de derrota durante um segundo antes de avisar
o spawner e liberar a vitória. Durante a queda, sua colisão e contato já estão
desativados, e novos golpes são ignorados. Provas comuns continuam sendo removidas
imediatamente. As animações do professor estão descritas em `docs/ANIMACOES_CHEFE.md`.

Receber dano pode levar qualquer estado vivo a FERIDO ou MORTO. O estado final
não aceita novos golpes, evitando contar a mesma morte duas vezes. No fim da
partida, `desativar()` interrompe o comportamento dos sobreviventes e a navegação.

## Ataque por contato

`Contato` é uma Area2D ligeiramente maior que o corpo físico e detecta apenas
a camada do aluno. A prova comum espera 0,12 segundo para aplicar o golpe; o chefe
espera 0,25 segundo. O dano só acontece se o aluno ainda estiver na área e não
houver uma parede ou mesa entre os dois. É possível escapar antes do contato.
Cada entrada em ATACANDO permite um único golpe. A recuperação completa dura
0,65 segundo para a prova e 0,85 segundo para o chefe.

O aluno controla a própria invulnerabilidade, que vale contra todos os inimigos
ao mesmo tempo. Por isso, uma horda encostando não desconta dez vidas de uma vez.

## Navegação e horda

A região navegável é calculada a partir das colisões do cenário no início.
`NavigationAgent2D` encontra caminhos e evita outras provas. O movimento usa
`move_and_slide()`, mantendo a colisão física mesmo quando há mudanças de caminho.
O chefe tem uma colisão própria, compatível com os corredores da arena.

O spawner distribui os nascimentos entre 24 pontos seguros, a pelo menos 180 pixels
do aluno. O Timer Horda reduz seu intervalo de 1,5 ate 0,5 segundo, com limite de
dez provas simultaneas. Matar uma prova libera uma vaga. O professor ocupa uma
vaga adicional, de modo que nasce aos 60 segundos mesmo com a horda cheia.
A Sala controla PREPARANDO, HORDA, CHEFE, VITORIA e DERROTA. O Timer Relogio
chama a criacao do chefe; sua morte vence a partida, mesmo com outras provas vivas.
