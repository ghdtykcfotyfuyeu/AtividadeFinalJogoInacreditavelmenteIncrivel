# Animações integradas ao aluno

O personagem usa `AnimatedSprite2D`, configurado em `entities/player.tscn`. As sequências
ficam em `sprites/player/aluno_animacoes.tres`, e os desenhos em `sprites/player/aluno_completo.png`.

| Ação | Nomes | Quadros por direção |
| --- | --- | --- |
| Parado | `idle_baixo`, `idle_direita`, `idle_cima`, `idle_esquerda` | 4 |
| Caminhada | `andar_baixo`, `andar_direita`, `andar_cima`, `andar_esquerda` | 6 |
| Ataque | `atacar_baixo`, `atacar_direita`, `atacar_cima`, `atacar_esquerda` | 6 |

Baixo mostra a frente do aluno; cima mostra as costas. Cada quadro tem 64 × 64
pixels com fundo transparente. O sprite é exibido com escala 1 e deslocamento
vertical de -9 pixels para alinhar os pés ao corpo físico do personagem.

## Controle pelo script

`scripts/player.gd` escolhe a animação a partir das teclas WASD ou setas. Ao parar, o
aluno conserva a direção e entra em idle. A caminhada continua avançando seus
quadros enquanto a tecla fica pressionada. Na diagonal, a velocidade continua
normalizada e a pose usa uma das quatro direções; em empate entre os eixos,
usa a direção vertical.

Espaço chama `atacar()`. O ataque mantém a direção em que o aluno estava olhando
e toca a sequência inteira, sem ser interrompido pela animação de caminhada.
O movimento continua disponível durante o golpe.

Quando o desenho chega ao terceiro quadro (índice 2), `frame_changed` agenda o
dano. A consulta de colisão ocorre no próximo passo de física, uma única vez
por golpe. `animation_finished` termina o estado de ataque e devolve o controle
ao idle ou à caminhada. Os seis quadros do golpe tocam a 15 quadros/s, totalizando
aproximadamente 0,4 segundo; manter Espaço pressionado repete o ataque.

`AtaqueLapis/Area2D/CollisionShape2D` define o alcance físico. O script verifica
se existe uma mesa ou parede entre o aluno e a prova antes de aplicar dano.
O lápis visível já faz parte da animação, sem precisar de outra imagem de arma.

## Alterar as animações

Abra `entities/player.tscn`, selecione `AnimatedSprite2D` e expanda **Sprite Frames**.
Mantenha os nomes das sequências caso queira trocar os desenhos ou velocidades,
pois o script usa esses nomes para selecionar cada ação. O quadro de contato
do ataque é definido na função `_on_frame_changed()`.

## Vida e fim da partida

Ao receber dano, o aluno pisca por um segundo e recebe um pequeno recuo, mantendo
as colisões. Esse período protege contra novos golpes de qualquer inimigo.
A Sala desativa o controle ao vencer ou perder; o sprite é pausado e novos
ataques não são aceitos. Reiniciar recarrega a cena, restaurando vida e animações.
