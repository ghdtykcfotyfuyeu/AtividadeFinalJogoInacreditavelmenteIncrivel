# Catálogo de sprites da sala

Os caminhos abaixo são relativos a `mapa/sprites/`. Os objetos têm fundo
transparente; piso e paredes são recortes opacos da arquitetura, montados sem
intervalos na cena `estrutura.tscn`.

| PNG | Tamanho nativo | Cena pronta | Colisão |
| --- | --- | --- | --- |
| `moveis/carteira_cadeira.png` | 80 × 96 | `objetos/moveis/carteira.tscn` | Retângulo 72 × 88. |
| `moveis/mesa_professor.png` | 152 × 104 | `objetos/moveis/mesa_professor.tscn` | Retângulo 144 × 94. |
| `moveis/estante.png` | 112 × 112 | `objetos/moveis/estante.tscn` | Retângulo 102 × 70. |
| `moveis/armario_globo.png` | 112 × 104 | `objetos/moveis/armario_globo.tscn` | Retângulo 104 × 60. |
| `decoracao/vaso_planta.png` | 56 × 80 | `objetos/decoracao/vaso_planta.tscn` | Círculo de raio 16, junto ao vaso. |
| `decoracao/lousa.png` | 480 × 88 | `objetos/decoracao/lousa.tscn` | Decoração de parede. |
| `decoracao/mural_avisos.png` | 136 × 76 | `objetos/decoracao/mural_avisos.tscn` | Decoração de parede. |
| `decoracao/relogio.png` | 48 × 48 | `objetos/decoracao/relogio.tscn` | Decoração de parede. |
| `decoracao/porta.png` | 80 × 110 | `objetos/decoracao/porta.tscn` | Passagem bloqueada pela parede superior. |
| `estrutura/piso_sala.png` | 1536 × 750 | `estrutura.tscn` | Área de chão. |
| `estrutura/parede_superior.png` | 1672 × 140 | `estrutura.tscn` | Limite superior. |
| `estrutura/parede_inferior.png` | 1672 × 51 | `estrutura.tscn` | Limite inferior. |
| `estrutura/parede_janelas.png` | 88 × 750 | `estrutura.tscn` | Limite esquerdo. |
| `estrutura/parede_direita.png` | 48 × 750 | `estrutura.tscn` | Limite direito. |

As cinco peças de estrutura formam uma sala de 1672 × 941 pixels. Elas preservam
a iluminação e o desenho da sala de referência. As janelas e seus radiadores
fazem parte da arquitetura; os nove tipos de objetos possuem PNGs e cenas
separados. Os livros, globo e pequenos itens de mesa fazem parte do sprite do
móvel correspondente.

## Como usar os objetos

Arraste a cena `.tscn` do objeto para `Entidades/Moveis`. Isso leva junto a
imagem, o alinhamento e a colisão. Para enfeites de parede, use o recipiente
`DecoracaoParede`.

Para usar só a imagem em outro projeto, adicione o PNG a um `Sprite2D` e
selecione o filtro `Nearest`. Para móveis, mantenha o ponto de origem na base
e crie a forma de colisão correspondente. As imagens usam tamanhos próprios
para conservar os detalhes dos objetos.

## Direção de arte

Artes geradas com o gerador de imagens integrado, usando `referencias/sala_planejada.png`
como referência visual. Cada objeto foi criado em uma geração individual com
fundo transparente, depois preparado no tamanho indicado por redução com
vizinho mais próximo. Não é necessário acessar um serviço de IA para executar
o jogo: todos os PNGs estão no projeto.

Orientação comum usada nas gerações: pixel art de RPG visto de cima, perspectiva
alinhada aos eixos, contorno escuro nítido, madeira em tons quentes, cores verdes
e creme, iluminação vindo da esquerda, objetos inteiros e sem texto legível.

| Elemento | Orientação específica da criação |
| --- | --- |
| Estrutura | Remover os objetos do mapa de referência e preservar paredes, piso, janelas e iluminação, reparando as áreas vazias. |
| Carteira | Uma carteira de madeira clara com cadeira na frente e pés metálicos escuros; orientação voltada à lousa. |
| Mesa do professor | Mesa de madeira com cadeira atrás, livros à esquerda, folha central e porta-lápis à direita. |
| Estante | Três prateleiras de livros coloridos, com uma planta pequena e caderno sobre o móvel. |
| Armário | Armário baixo de duas portas com livros, planta e globo sobre o tampo. |
| Vaso | Planta de folhas verdes em vaso de cerâmica claro. |
| Lousa | Quadro verde largo com moldura de madeira, giz e apagador, sem escrita. |
| Mural | Mural de cortiça emoldurado com papéis coloridos presos por alfinetes. |
| Porta | Porta de madeira fechada, visor azul, maçaneta e moldura. |
| Relógio | Relógio circular com mostrador creme, aro marrom, marcas e ponteiros escuros. |
