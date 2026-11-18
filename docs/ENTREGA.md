# Executar, exportar e publicar

A orientacao complementar do professor exige uma versao jogavel no navegador.
Os executaveis de PC sao opcoes adicionais; a entrega precisa incluir o link web.

## Jogo publicado

Jogue em https://ghdtykcfotyfuyeu.itch.io/provas-voadoras.
O aluno confirmou a publicacao em 18/11/2026; a pagina respondeu publicamente
com HTTP 200 e apresentou a area do jogo HTML. O enquadramento das capturas,
com espaco preto ao redor da sala, foi aceito pelo aluno.

## Sem instalar a Godot

- **Windows:** extraia o pacote e abra `ProvasVoadoras.exe`.
- **Linux:** extraia, permita executar `ProvasVoadoras.x86_64` e abra o arquivo.
- **Web:** sirva a pasta do pacote web por HTTP; abrir `index.html` com duplo clique nao executa WebAssembly corretamente.
  Com Python instalado: `python -m http.server 8000 --directory web` e abra `http://localhost:8000`.

A versao Windows foi exportada em Linux; sua execucao deve ser conferida no computador
Windows da apresentacao. O executavel Linux foi aberto neste ambiente. A captura
enviada pelo aluno mostra a partida web iniciada; o navegador remoto deste ambiente
nao oferece WebGL 2. O teste completo de jogabilidade deve ser feito no PC do aluno.

## Publicar ou atualizar no itch.io

1. Em **Edit game**, mantenha **Kind of project: HTML**.
2. Envie `ProvasVoadoras_Web.zip` sem extrair e marque **This file will be played in the browser**.
3. Se houver uma versao anterior, remova esse upload somente depois de o novo concluir com sucesso.
4. Em **Embed options**, escolha **Click to launch in fullscreen**.
5. Salve em **Save & view page** e teste movimento, ataque, chefe, vitoria e derrota.
6. Confira se a sala acompanha o tamanho da janela e da tela cheia.
7. Quando estiver funcionando, escolha **Visibility & access: Public**, salve e coloque o link no README.

O ZIP de envio deve conter `index.html`, `index.js`, `index.wasm`, `index.pck`
e os demais arquivos da exportacao diretamente na raiz. O preset Web usa
**Canvas Resize Policy: Adaptive**, que ajusta o canvas ao espaco disponivel.
A proporcao da sala e preservada; telas com formato diferente podem ter faixas nas bordas.

## Exportar novamente

Use Godot **4.6.3** com os modelos oficiais da mesma versao instalados.
Os presets Web, Windows e Linux estao em `export_presets.cfg`.

```bash
mkdir -p exports/web exports/windows exports/linux
godot --headless --editor --path . --import --quit
godot --headless --path . --export-release Web
godot --headless --path . --export-release Windows
godot --headless --path . --export-release Linux
```

Os comandos rodam na raiz do projeto. O build Web usa Compatibility e uma unica
thread, sem exigir cabecalhos especiais para SharedArrayBuffer.
O motor Web exige WebGL 2.0 e WebAssembly. O controle e por teclado.

## Alternativa: publicar no GitHub Pages

O workflow `.github/workflows/jogo.yml` testa, exporta e disponibiliza os pacotes em
Actions. A pagina combina `web/index.html` e o jogo exportado em `jogar/`.

Para a publicacao do repositorio:

1. Integre a atualizacao em `main` depois de revisar os testes.
2. Em **Settings > Pages > Build and deployment**, selecione **GitHub Actions**.
3. Execute o workflow **Verificar e exportar jogo**, marcando **Publicar pagina**,
   ou envie um novo commit para main depois de habilitar Pages.
4. Confira o endereco retornado pela etapa Deploy. Nao trate uma URL prevista como publicada antes do sucesso.

## Historico de entrega

O repositorio original tinha dois commits e nenhuma tag. A organizacao atual nao
transforma esses commits em entregas pontuais das aulas. Nao recrie datas para
simular entregas. O DEVLOG diferencia evidencia historica e revisao atual.
A tag `entrega-final` deve apontar para a versao efetivamente revisada e apresentada.

## Referencias tecnicas

- https://docs.godotengine.org/en/4.6/tutorials/editor/command_line_tutorial.html
- https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_web.html
- https://docs.godotengine.org/en/4.6/classes/class_editorexportplatformweb.html
- https://itch.io/docs/creators/html5
- https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages
