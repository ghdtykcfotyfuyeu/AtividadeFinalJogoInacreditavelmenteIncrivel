# Máquina de estados dos inimigos

`scripts/inimigo.gd` declara `enum Estado`. A variável `estado` guarda o comportamento
atual e `mudar_estado()` centraliza as transições, a cor e a interrupção do movimento.
A prova comum e o chefe compartilham esse script; seus atributos ficam nas cenas.

| Estado | Comportamento | Transição |
| --- | --- | --- |
| NASCENDO | Aparece semitransparente e espera 0,35 segundo. | Vai para PERSEGUINDO. |
| PERSEGUINDO | Consulta a navegação, segue o aluno e contorna os móveis. | Ao detectar contato, vai para ATACANDO. |
| ATACANDO | Para, muda de cor e prepara um golpe de contato. | Após a recuperação, retorna a PERSEGUINDO. |
| FERIDO | Pisca em vermelho e interrompe o movimento por 0,16 segundo. | Se ainda tem vida, volta a PERSEGUINDO. |
| MORTO | Para, sai do grupo de inimigos, avisa o spawner e é removido. | Estado final. |

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

## Navegação e ondas

A região navegável é calculada a partir das colisões do cenário no início.
`NavigationAgent2D` encontra caminhos e evita outras provas. O movimento usa
`move_and_slide()`, mantendo a colisão física mesmo quando há mudanças de caminho.
O chefe tem uma colisão própria, compatível com os corredores da arena.

O spawner distribui a criação entre os 24 pontos livres, a pelo menos 180 pixels
do aluno. Uma onda termina somente quando sua fila está vazia e não existem
inimigos vivos. A Sala controla os estados PREPARANDO, INTERVALO, ONDA, CHEFE,
VITORIA e DERROTA. A conclusão das três ondas libera o chefe; sua morte vence a partida.
