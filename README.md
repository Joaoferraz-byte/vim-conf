# Livara NixVim

Este repositório fornece um ambiente NixVim declarativo e reproduzível para Java, Spring Boot, Angular, web, C/C++, embedded e programação competitiva. Servidores LSP, formatadores, debuggers e dependências de desenvolvimento são fornecidos por Nix em vez de depender de instalação imperativa via Mason.

## Contrato público

| Output | Finalidade |
|---|---|
| `lib.nixvimModule` | Módulo NixVim reutilizável por Home Manager ou outra composição. |
| `lib.nixvimModules.default` | Alias do módulo reutilizável padrão. |
| `packages.<system>.default` | Pacote NixVim standalone para Linux. |
| `checks.<system>.nixvim` | Check do pacote standalone. |
| `formatter.<system>` | Formatador do repositório. |

O flake publica somente sistemas Linux porque a configuração inclui ferramentas Wayland como `wl-clipboard`, além de imagem, terminal e integrações próprias do desktop Livara. O input NixVim upstream pode suportar outros sistemas, mas esta configuração não promete compatibilidade que não foi avaliada.

## Atualização controlada

A versão do editor e dos plugins é determinada pelo `flake.lock`. Inicialização, `nix flake check`, `nix eval`, `nix build` e o rebuild do sistema usam os inputs já bloqueados; nenhum desses caminhos deve atualizar o lockfile ou buscar uma revisão mais nova implicitamente. O `lazy.nvim` também mantém o checker de atualizações desabilitado, pois a instalação de plugins é responsabilidade declarativa do NixVim.

Para atualizar sob demanda, altere o lockfile em uma operação explícita e revise o diff antes de comitar:

```bash
# Dentro deste repositório: atualizar apenas a dependência upstream do NixVim.
nix flake update nixvim
git diff --check
git diff -- flake.lock
git add flake.lock && git commit -m "chore: update nixvim input"

# No sistema consumidor: atualizar os inputs selecionados do desktop.
NIX_CONF_UPDATE_FLAKE=1 NIX_CONF_UPDATE_INPUTS="vim-conf nixvim" ./install.sh
```

O primeiro fluxo publica uma nova revisão de `vim-conf`; o segundo atualiza explicitamente o lockfile do `nix-conf`. Se a revisão for rejeitada, basta descartar o commit do lockfile ou usar a cópia de segurança criada pelo installer. Assim, atualizar o editor se comporta como uma ação administrativa semelhante a atualizar Flatpaks, e não como efeito colateral de iniciar o Neovim.

## Arquitetura

A configuração usa uma arquitetura híbrida de **camadas e workflows**, não um padrão dendrítico imposto:

| Camada | Owner |
|---|---|
| Contrato do flake | `flake.nix`: inputs, outputs, sistemas e formatter. |
| Editor | `config/options.nix`: opções globais, defaults e performance. |
| Tema | `config/theme.nix`: Matugen, highlights, transparência e reload. |
| UI | `config/plugins/ui.nix`: Snacks, Oil, Which-Key, Noice, statusline e superfícies de interface. |
| Core | `config/plugins/core.nix`: Git, treesitter, movimento, text objects e ferramentas especializadas. |
| Linguagens | `config/languages/*.nix`: LSP, toolchains e testes por ecossistema. |
| Workflows | `config/keymaps.nix` e helpers Lua: Java/Spring, projetos, criação de arquivos, Git, DAP e testes. |

Cada plugin possui um owner principal. A organização não fragmenta artificialmente cada opção em um arquivo: plugins que formam um workflow permanecem juntos, enquanto domínios diferentes continuam isolados.

A decisão arquitetural completa, incluindo comparação com dendritic, camadas, slices verticais, NixVim, nvf e nixCats, está em [`ARCHITECTURE_PROPOSAL.md`](./ARCHITECTURE_PROPOSAL.md).

## Tema Matugen/Livara

O editor mantém `habamax` como fallback durante a primeira inicialização e força `background = "dark"`. Quando `~/.config/nvim/lua/matugen_colors.lua` existe, `config/theme.nix` carrega a tabela Lua produzida pelo adapter Livara e aplica a paleta derivada do wallpaper.

O loader usa um único contrato `_G.reload_livara_theme` e um watcher `vim.uv.new_fs_event`. `LivaraStatusline` é o único owner de `vim.o.statusline`: o footer global usa uma composição linear com informações do arquivo, Git, diagnósticos, clientes LSP, filetype, posição e scrollbar. `vim.o.winbar` fica intencionalmente vazio, impedindo que um plugin de breadcrumbs herde ou redesenhe a barra. O canvas e os grupos da statusline são transparentes; menus, floats e completion mantêm superfícies com contraste.

Matugen é o owner da paleta dinâmica. O NixVim apenas consome o arquivo gerado e não inicia compositor, shell visual, QuickShell, Hyprland ou Serpantinum.

## Interface e workflows

Snacks é a fundação de picker, explorer, dashboard, input, notifier, quickfile, terminal, image, scope, indent e zen. Oil é o owner da edição de filesystem como buffer. Neo-tree, NvimTree, Telescope, Mini Files e project.nvim não fazem parte da configuração ativa.

Plugins especializados permanecem quando não existe paridade real: Aerial para outline, Neogit/Diffview/Gitsigns para Git, nvim-dap para debugging, Conform para formatação, Neotest para testes e `nvim-jdtls`/JDTLS para Java/Spring. A modernização não remove uma feature somente porque existe um plugin mais novo em outra área.

### Markdown pesado

O workflow do Vault é centrado em Markdown portátil, sem depender de runtime Obsidian. `render-markdown.nvim` fornece renderização em buffer por opções explícitas para headings, blocos de código, listas, checkboxes, callouts, tabelas, links e fórmulas LaTeX; Treesitter instala de forma reprodutível os parsers de Markdown, Markdown inline, HTML, YAML e LaTeX. O plugin `mermaid.nvim` permanece como ferramenta dedicada para diagramas Mermaid e preview no terminal. O limite de arquivo de 16 MiB evita transformar notas grandes em uma fonte de latência global, e a renderização preserva o texto-fonte para edição normal.

| Recurso | Implementação | Dependência de runtime |
|---|---|---|
| Markdown estrutural | `render-markdown.nvim` com opções explícitas e tabelas arredondadas | Nixvim + Treesitter |
| LaTeX inline/bloco | parser `latex` e conversor `utftex`/`latex2text` quando disponível | executável opcional no `PATH` |
| Mermaid | plugin `mermaid.nvim` fixado no flake | `chafa` para fallback terminal quando suportado |
| Frontmatter | parser `yaml` e LSP Marksman | Nixvim |
| Templates | criação de arquivo estática e explícita no workflow Lua | nenhum plugin Obsidian |

| Mapping | Ação |
|---|---|
| `<leader>e` / `<leader>mf` | Abrir Snacks Explorer. |
| `<leader>vd` / `<leader>vs` / `<leader>vc` | Criar nota diária / fonte / conceito no Vault, com frontmatter estático. |
| `<leader>vb` / `<leader>vq` | Criar referência de livro / capturar texto no inbox do Vault. |
| `-` | Abrir Oil no diretório pai. |
| `<leader>cn` / `<leader>cs` | Abrir a configuração do Neovim / sistema no Oil. |
| `<leader>d` | Abrir o dashboard Snacks. |
| `v` no Dashboard | Abrir o Vault em `~/Vault` usando Oil. |
| `<leader>ff` / `<leader>fg` | Encontrar arquivos / pesquisar conteúdo com Snacks Picker. |
| `<leader>fi` | Encontrar arquivos de imagem/documentos com preview Snacks quando suportado pelo terminal. |
| `<leader>fr` / `<leader>fp` | Arquivos recentes / projetos. |
| `<leader>o` | Alternar o outline Aerial. |
| `<leader>ha` / `<leader>ht` | Adicionar ao Harpoon / abrir seu quick menu nativo. |
| `s` / `S` | Navegação Flash / seleção Treesitter. |
| `<leader>z` | Alternar Snacks Zen. |
| `gd`, `gD`, `gi`, `gr`, `K` | Navegação e documentação LSP. |
| `<leader>lr`, `<leader>la`, `<leader>lf` | Rename, code action e format. |
| `<leader>j*` | Workflow Java: compilar, depurar via DAP, organizar imports, controlar JDTLS e executar/debugar testes Neotest. |
| `<leader>lx` | Alternar diagnósticos com Trouble. |
| `<C-h/j/k/l>` | Navegar entre splits no Neovim; o remapeamento físico global continua sendo owner do keyd. |

A criação avançada de arquivos, o picker de projetos e o Spring Boot wizard usam APIs documentadas do Snacks (`Snacks.input`, `Snacks.picker.pick` e `vim.ui.select`). O wizard valida o diretório e usa `curl`/`tar` com escaping explícito, mantendo o processo fora da avaliação Nix.

## Linguagens e toolchains

A configuração inclui LSP para Lua, Nix, Bash, Docker, C/C++, Python, Markdown, Angular, TypeScript, ESLint, HTML, CSS, JSON, YAML, Emmet e Tailwind. Também inclui CMake Tools, OpenOCD, Cppcheck e Competitest.

A cobertura solicitada fica organizada da seguinte forma:

| Ecossistema | Suporte | Owner do LSP/completion |
|---|---|---|
| Java, Spring Boot, Swing/JFrame | Workflow Java dedicado com JDTLS, JDK 21, Lombok, Maven, Gradle e Neotest | `nvim-jdtls` + `jdt-language-server` + `nvim-cmp` |
| HTML, CSS, JavaScript/TypeScript | Angular root-scoped por `angular.json`/`nx.json`, TypeScript, ESLint, HTML, CSS, Emmet e Tailwind | servidores declarativos do NixVim + `nvim-cmp` |
| PHP | PHP e projetos Composer | `phpactor` + `nvim-cmp` |
| C/C++ | C e C++ com toolchain clang/gcc | `clangd` + `nvim-cmp` |
| Python e Manim | Python; Manim é uma biblioteca/workflow Python e usa o mesmo servidor | `pyright` + `nvim-cmp` |
| SQL/PostgreSQL | SQL com análise específica de PostgreSQL/PLpgSQL | `postgres_lsp` + `nvim-cmp` |
| XML | XML, XSD, XSLT, SVG | `lemminx` + `nvim-cmp` |

Java é tratado como workflow próprio. O caminho padrão usa `nvim-jdtls` com o `jdt-language-server` empacotado pelo Nix, JDK21, Lombok, Maven, Gradle e Neotest. O workspace do JDTLS é resolvido por projeto e o runtime Java 21 é declarado como default, evitando o launcher ELF baixado que falhava antes do handshake no NixOS. Lombok é carregado uma única vez pelo `JDTLS_JVM_ARGS` com o `lombok.jar` empacotado, enquanto `java.jdt.ls.lombokSupport.enabled` permanece explícito no settings do servidor.

O completion não depende de um servidor separado por linguagem. `plugins.cmp` habilita as fontes `nvim_lsp`, `luasnip`, `path` e `buffer`; como `autoEnableSources = true`, o NixVim instala as fontes e o owner global `plugins.lsp.capabilities` aplica `cmp_nvim_lsp.default_capabilities()` aos servidores. Assim, cada servidor desta tabela participa do mesmo menu de completion, enquanto o Pyright fornece a base para scripts Manim dentro do ambiente Python do projeto. A avaliação de uma eventual troca pelo IntelliJ LSP está em [`docs/intellij-lsp-assessment.md`](./docs/intellij-lsp-assessment.md); a conclusão atual é manter JDTLS até existir um servidor standalone documentado e testável pelo Neovim.

Métodos gerados por Lombok, como getters, setters e construtores, só aparecem no completion quando o JDTLS indexa o projeto com a dependência Lombok e o agente JVM ativo; não existe um provider `cmp` separado para esses métodos. Após alterar a versão do agente ou o classpath, o workspace do JDTLS deve ser limpo/reiniciado para reconstruir o índice. A configuração não executa essa limpeza automaticamente, pois ela é uma ação destrutiva dependente do workspace selecionado.

Arquivos `.xopp` não são interpretados como texto pelo editor. O autocmd `BufReadCmd` inicia Xournal++ com o caminho absoluto e remove o buffer temporário; a associação XDG correspondente é declarada em `nix-conf` com o MIME `application/x-xopp`. Assim, abrir o arquivo pelo Oil, Snacks ou pelo gerenciador de arquivos converge para o mesmo owner do formato.

A formatação é declarada pelo Conform com fallback LSP e executáveis Nix para Java, C/C++, Python, web, Nix, Lua e shell; Python usa o formatter Ruff. Debugging usa LLDB para C/C++ e attach Java na porta 5005.

## Validação incremental

Como a configuração NixOS consumidora possui uma closure grande, a validação recomendada é incremental:

```bash
# Sintaxe Nix de cada módulo
find config -name '*.nix' -print0 | xargs -0 -n1 nix-instantiate --parse

# Avaliação dos outputs e opções, sem materializar o sistema
nix flake check --no-build --show-trace --all-systems
nix eval .#packages.x86_64-linux.default
nix eval .#checks.x86_64-linux.nixvim
```

O `nix build` do pacote standalone é uma validação posterior e deve ser executado em uma máquina com espaço e memória adequados. Não é necessário construir o toplevel NixOS inteiro para validar alterações de sintaxe, opções, imports ou contratos do NixVim.

## Integração com NixOS e Home Manager

```nix
{
  inputs = {
    vim-conf.url = "github:Joaoferraz-byte/vim-conf";
    nixvim.url = "github:nix-community/nixvim";
  };

  home-manager.sharedModules = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    imports = [ inputs.vim-conf.lib.nixvimModule ];
  };
}
```

## Referências

- [NixVim](https://github.com/nix-community/nixvim)
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
- [Oil.nvim](https://github.com/stevearc/oil.nvim)
- [Proposta arquitetural](./ARCHITECTURE_PROPOSAL.md)
- [Achados comunitários](../nixvim-community-findings.md)
