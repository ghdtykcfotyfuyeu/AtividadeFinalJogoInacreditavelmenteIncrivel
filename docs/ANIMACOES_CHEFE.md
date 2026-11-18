# Professor — chefe final

O professor substitui a prova gigante da versão anterior. Surge após 60 segundos, tem 10 pontos de vida, causa 2 de dano por contato e persegue o aluno
contornando as carteiras. Seu corpo mantém a colisão de 26 × 32 pixels.

O sprite fica em `sprites/chefe/professor_completo.png`. A imagem original foi
preservada, incluindo transparência. Como os quadros possuem espaçamentos
irregulares, `sprites/chefe/professor_animacoes.tres` usa 72 regiões AtlasTexture individuais,
com margens que alinham os pés. Não use uma divisão automática em células iguais.

| Animação | Quantidade por direção | Velocidade | Repetição |
| --- | --- | --- | --- |
| `idle_` | 2 quadros | 3 FPS | Sim |
| `andar_` | 6 quadros | 8 FPS | Sim |
| `atacar_` | 6 quadros | 8 FPS | Não |
| `dano_` | 2 quadros | 12,5 FPS | Não |
| `derrota` | 8 quadros, sequência única | 8 FPS | Não |

As quatro direções usam os sufixos `baixo`, `direita`, `cima` e `esquerda`.
São 17 animações no total. Elas podem ser vistas selecionando **Visual** na cena
`entities/chefe.tscn` e abrindo seu recurso SpriteFrames.

`scripts/chefe.gd` controla a aparência e herda a máquina de estados de
`scripts/inimigo.gd`. A direção vem do movimento real da navegação. Ao atacar,
o professor olha para o aluno e mantém essa direção até terminar o golpe.
O dano por contato ocorre após 0,25 segundo, no terceiro quadro do ataque;
a recuperação completa continua durando 0,85 segundo. O aluno pode escapar
antes do golpe e as carteiras continuam bloqueando o contato através delas.

Ao perder a última vida, o professor deixa de bloquear e de causar dano,
reproduz a queda durante um segundo e só então libera a vitória. Sua morte
é contada uma única vez. Se o aluno perder, a animação do professor também para.

Para mudar o tamanho visual, altere a escala do nó **Visual**, inicialmente 0,5.
A imagem usa filtro Nearest. Vida, velocidade e dano ficam no nó **ProfessorFinal**;
o código continua todo na pasta `scripts/`.
