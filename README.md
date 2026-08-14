# vim-conf

Este repositório fornece um ambiente NixVim declarativo e reproduzível para Java, Spring Boot, Angular, web, C/C++, embedded e programação competitiva. Servidores, formatadores, debuggers e demais dependências são fornecidos por Nix em vez de serem instalados pelo Mason.

## Contrato público

| Output | Finalidade |
|---|---|
| `lib.nixvimModule` | Módulo NixVim reutilizável por Home Manager ou outra composição. |
| `lib.nixvimModules.default` | Alias do módulo reutilizável padrão. |
| `packages.<system>.default` | Pacote NixVim standalone. |
| `checks.<system>.nixvim` | Check de build do pacote standalone. |
| `formatter.<system>` | Formatador do repositório. |

A configuração é composta em `config/` e inclui tooling para Java/Spring Boot, Angular, TypeScript, ESLint, HTML, CSS, JSON, YAML, Emmet, Tailwind, C/C++, CMake, embedded e DAP.

## Tema adaptativo

O editor mantém um fallback local `habamax` e não exige que Matugen, QuickShell ou uma sessão gráfica estejam ativos durante a avaliação Nix. Quando o arquivo opcional `~/.config/nvim/matugen_colors.lua` existe, ele é carregado como uma tabela Lua e aplicado aos principais grupos de highlight.

O loader é reexecutado quando o arquivo muda, permitindo que o `shell-conf` atualize o Neovim após uma troca de wallpaper. O editor também mantém uma paleta funcional quando o arquivo ainda não existe ou possui conteúdo inválido. A geração pertence ao Serpantinum; este repositório apenas consome o contrato de runtime.

## Compatibilidade

NixVim permanece compatível com a revisão de nixpkgs contra a qual é testado. O flake mantém seu input `nixvim` independente e não força `nixvim.inputs.nixpkgs.follows = nixpkgs` sem uma decisão explícita de compatibilidade.

Antes de publicar mudanças:

```bash
nix flake check --all-systems
nix build .#packages.x86_64-linux.default
```

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

## Workflows

A configuração inclui JDTLS, Spring Boot, AngularLS, TypeScript, ESLint, HTML, CSS, JSON, YAML, Emmet, Tailwind, Conform, DAP, Clangd, CMake Tools, GDB, LLDB, OpenOCD, Cppcheck, Competitest, Telescope, Aerial, Harpoon, Neogit, Diffview, Trouble, Treesitter, Bufferline, Lualine, Gitsigns, Smart Splits, Zen Mode, Todo Comments, Web Devicons e Oil.

Projetos Java são detectados por `pom.xml`, arquivos Gradle, wrappers ou metadados Git. JDTLS usa workspace isolado por projeto, com source downloads, code lenses, organização de imports, inlay hints e suporte DAP. AngularLS e TypeScript LSP são instalados declarativamente; versões específicas de Angular permanecem em `devDependencies` de cada projeto.

Formatação ocorre no save com timeout e fallback LSP. O dashboard abre quando o Neovim inicia sem arquivos, e explorer, Telescope, picker de projetos, outline, Git e DAP ficam disponíveis pelos keymaps declarados.

## Key mappings

| Mapping | Ação |
|---|---|
| `<leader>e` | Alternar o file explorer. |
| `<leader>d` | Abrir o dashboard. |
| `<leader>?` | Pesquisar todos os keymaps. |
| `<leader>ff` / `<leader>fg` | Encontrar arquivos / pesquisar conteúdo com Telescope. |
| `<leader>fr` / `<leader>fp` | Arquivos recentes / projetos. |
| `<leader>o` | Alternar o outline Aerial. |
| `<leader>ha` / `<leader>ht` | Adicionar ao Harpoon / abrir lista. |
| `s` / `S` | Navegação Flash / seleção Treesitter. |
| `<leader>z` | Alternar Zen Mode. |
| `gd`, `gD`, `gi`, `gr`, `K` | Navegação e documentação LSP. |
| `<leader>lr`, `<leader>la`, `<leader>lf` | Rename, code action e format. |
| `<leader>ld` | Alternar diagnósticos com Trouble. |
| `<C-h/j/k/l>` | Navegar entre splits no Neovim; o remapeamento físico global é owner do keyd. |

## Validação

```bash
nix flake check --no-build
nix build .#default
```

A configuração NixOS consumidora pode ser avaliada com:

```bash
nix eval .#nixosConfigurations.myMachine.config.system.build.toplevel.drvPath
```
