# NixVim IDE Moderno

Esta configuração fornece um **Neovim declarativo**, reproduzível e pronto para desenvolvimento Java, Spring Boot, Angular, web, C/C++, embarcados e programação competitiva. Ela combina JDTLS por projeto, suporte a Spring Boot, Angular Language Server, TypeScript, ESLint, formatação por Conform, depuração DAP, uma interface visual baseada em **GitHub Dark** e uma **página inicial moderna com dashboard-nvim**. A configuração não utiliza Mason: servidores, formatadores e dependências de editor são fornecidos pelo Nix.

> O NixVim deve ser mantido compatível com a revisão de Nixpkgs usada por ele. Por isso, este flake mantém sua entrada `nixvim` independente e não força `nixpkgs.follows`. [1]

| Área | Componentes incluídos |
|---|---|
| Java e Spring Boot | JDTLS (plugin nativo NixVim), JDK 21, Lombok, Maven, Gradle, `spring-boot.nvim` (plugin nativo), inlay hints, DAP com hot code replace, organização automática de imports e workspace isolado por projeto. |
| Angular e web | AngularLS, TypeScript LSP, ESLint, HTML, CSS, JSON, YAML, Emmet, Tailwind CSS e TS Autotag. |
| Qualidade | Conform com Prettier/Prettierd, Google Java Format, Clang Format, Nixfmt, Stylua e Shfmt. |
| C/C++ e embarcados | Clangd, CMake Tools, Clang Format, CMake, Ninja, GDB, OpenOCD e Cppcheck. |
| Programação competitiva | Competitest, Clang, GCC e Clang Tools, todos fornecidos declarativamente. |
| Depuração | `nvim-dap`, DAP UI, DAP virtual text, LLDB/GDB e perfil para anexar a Spring Boot na porta `5005`. |
| Interface visual | Dashboard-nvim, Snacks.nvim (Statuscolumn, Indent, Scope, Words e rolagem suave), Noice com paleta de comandos, Mini Animate, Barbecue (breadcrumbs), Treesitter Context, Indent Blankline, Fidget (LSP progress), Bufferline, Lualine, Gitsigns, Treesitter, Trouble, Smart Splits e terminal flutuante. |
| Navegação | Flash, Leap, Harpoon, Aerial (outline), Project.nvim, Telescope e Which-Key com layout moderno. |
| Git | Gitsigns, Neogit e Diffview para status, commits, branches, sync, diffs e histórico. |
| Extras | Zen Mode, Todo Comments, Web Devicons e Illuminate. |

## Executar como pacote

Após publicar o flake, a execução direta é:

```bash
nix run github:Joaoferraz-byte/vim-conf
```

O pacote padrão é construído via `nixvim.legacyPackages.<system>.makeNixvimWithModule`, o caminho oficialmente suportado para expor uma configuração NixVim como derivação. [1]

## Integrar com NixOS e Home Manager

Adicione o flake como entrada e mantenha o módulo oficial do NixVim no Home Manager. O módulo de configuração deste repositório deve ser importado dentro de `programs.nixvim.imports`, conforme a interface documentada pelo NixVim. [1]

```nix
{
  inputs = {
    vim-conf.url = "github:Joaoferraz-byte/vim-conf";
    nixvim.url = "github:nix-community/nixvim";
  };

  # No módulo NixOS que configura o Home Manager:
  home-manager.sharedModules = [
    inputs.nixvim.homeModules.nixvim
  ];

  # No home.nix do usuário:
  programs.nixvim = {
    enable = true;
    imports = [ inputs.vim-conf.lib.nixvimModule ];
  };
}
```

## Fluxos de trabalho

### Java e Spring Boot

Ao abrir um arquivo Java dentro de um projeto com `pom.xml`, `build.gradle`, `build.gradle.kts`, `mvnw`, `gradlew` ou `.git`, o `nvim-jdtls` cria ou reutiliza um workspace isolado. As configurações ativam download de fontes, code lenses, organização de imports, inlay hints, JDK 21 e DAP com hot code replace. O JDTLS é o servidor oficialmente exposto pelo NixVim para Java. [2]

Para depurar uma aplicação Spring Boot, inicie-a com depuração remota na porta `5005`, por exemplo:

```bash
./mvnw spring-boot:run \
  -Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005'
```

Em seguida, use `<leader>dc` e escolha **Attach Spring Boot (porta 5005)**. O perfil usa a interface oficial de configurações DAP indexadas por filetype. [3]

### Angular

AngularLS e TypeScript LSP são instalados pelo módulo NixVim, enquanto `nodejs` fica disponível no ambiente do editor. O Angular CLI deve continuar preferencialmente no `devDependencies` de cada aplicação, por exemplo com `npm install --save-dev @angular/cli`; isso preserva a versão exigida por cada workspace Angular. O módulo `angularls` é suportado diretamente pelo NixVim. [4]

### Formatação

A formatação é executada ao salvar, com timeout de 2,5 segundos e fallback para LSP quando não existir um formatador dedicado. Use `<leader>lf` para formatar manualmente. As opções `formatters_by_ft` e `format_on_save` seguem a interface do módulo Conform do NixVim. [5]

### Dashboard e Explorador de Arquivos

Ao abrir o Neovim sem arquivos, o **dashboard-nvim** é exibido automaticamente com atalhos para buscar arquivos, projetos recentes, configurações, keymaps e informações do Git. Há duas linhas de separação entre o logotipo ASCII e as ações. Use `<leader>e` para alternar o explorador de arquivos lateral, `<leader>ff` para buscar arquivos, `<leader>?` para navegar por todos os keymaps e `<leader>d` para reabrir o dashboard a qualquer momento.

## Atalhos

| Atalho | Ação |
|---|---|
| `<leader>e` | Alternar explorador de arquivos. |
| `<leader>d` | Abrir dashboard. |
| `<leader>?` | Abrir lista pesquisável de todos os keymaps. |
| `<leader><leader>` | Abrir menu de atalhos do líder. |
| `<leader>ff` / `<leader>fg` | Procurar arquivos / conteúdo com Telescope. |
| `<leader>fr` / `<leader>fp` | Arquivos recentes / projetos. |
| `<leader>o` | Alternar outline (Aerial). |
| `<leader>ha` | Marcar arquivo no Harpoon. |
| `<leader>ht` | Lista rápida do Harpoon. |
| `<leader>h1`-`h4` | Ir para arquivo marcado (1-4). |
| `s` / `S` | Flash: navegar com rótulos / Treesitter. |
| `<leader>z` | Zen Mode. |
| `gd`, `gD`, `gi`, `gr`, `K` | Navegação e documentação LSP. |
| `<leader>lr`, `<leader>la`, `<leader>lf` | Renomear símbolo, ação de código e formatar buffer. |
| `<leader>ld` | Alternar diagnósticos com Trouble. |
| `<C-h/j/k/l>` | Navegar entre splits (Smart Splits). |
| `<leader>xb`, `<leader>xc`, `<leader>xn` | Breakpoint, continuar e step over no DAP. |
| `<leader>xi`, `<leader>xo`, `<leader>xt` | Step into, step out e encerrar a sessão DAP. |
| `<leader>gg` / `<leader>gc` | Abrir status Git / criar commit com Neogit. |
| `<leader>gb`, `<leader>gl`, `<leader>gp`, `<leader>gr` | Branches, pull, push e rebase da branch atual. |
| `<leader>gd`, `<leader>gh`, `<leader>gH`, `<leader>gB` | Diff, histórico do arquivo, histórico do repositório e blame da linha. |

## Tema GitHub Dark

O tema é configurado pelo módulo oficial `colorschemes.github-theme`, e só então `colorscheme = "github_dark_default"` é selecionado. A Lualine usa `theme = "auto"`, de modo que herda o esquema carregado e não disputa a aplicação do tema. [6]

## Validação

O repositório declara um pacote padrão e uma checagem NixVim:

```bash
nix flake check --no-build
nix build .#default
```

A integração no NixOS deve ser avaliada com:

```bash
nix eval .#nixosConfigurations.myMachine.config.system.build.toplevel.drvPath
```

## Referências

[1]: https://nix-community.github.io/nixvim/user-guide/install.html "NixVim — Installation"
[2]: https://nix-community.github.io/nixvim/plugins/jdtls/index.html "NixVim — JDTLS"
[3]: https://nix-community.github.io/nixvim/plugins/dap/index.html "NixVim — DAP"
[4]: https://nix-community.github.io/nixvim/plugins/lsp/servers/angularls/index.html "NixVim — AngularLS"
[5]: https://github.com/nix-community/nixvim/blob/main/plugins/by-name/conform-nvim/default.nix "NixVim — Conform module"
[6]: https://nix-community.github.io/nixvim/colorschemes/github-theme/index.html "NixVim — GitHub Theme"
[7]: https://nix-community.github.io/nixvim/plugins/neogit/index.html "NixVim — Neogit"
[8]: https://nix-community.github.io/nixvim/plugins/diffview/index.html "NixVim — Diffview"
[9]: https://nix-community.github.io/nixvim/plugins/competitest/index.html "NixVim — Competitest"
[10]: https://nix-community.github.io/nixvim/plugins/cmake-tools/index.html "NixVim — CMake Tools"
