# NixVim Development Environment

This repository provides a declarative and reproducible NixVim environment for Java, Spring Boot, Angular, web, C/C++, embedded, and competitive programming workflows. Editor servers, formatters, debuggers, and other dependencies are provided by Nix rather than installed through Mason.

## Public contract

The flake exposes the following interfaces:

| Output | Purpose |
|---|---|
| `lib.nixvimModule` | Reusable NixVim module imported by Home Manager or another NixVim composition. |
| `lib.nixvimModules.default` | Alias for the default reusable module. |
| `packages.<system>.default` | Standalone NixVim package. |
| `checks.<system>.nixvim` | Build check for the standalone package. |
| `formatter.<system>` | Nix formatter for this repository. |

The main configuration is composed under `config/`. It includes language servers and tooling for Java/Spring Boot, Angular, TypeScript, ESLint, HTML, CSS, JSON, YAML, Emmet, Tailwind CSS, C/C++, CMake, embedded workflows, and debugging through DAP.

## Theme integration

The editor uses the `dms` colorscheme adapter. DMS/Matugen owns runtime-generated colors, while this repository owns editor behavior, plugin declarations, keymaps, language tooling, and the small Lua adapter required to load the generated palette. Editor evaluation does not require DMS to be running.

## Compatibility

NixVim should remain compatible with the nixpkgs revision against which it is tested. The flake intentionally keeps its `nixvim` input independent and does not force `nixvim.inputs.nixpkgs.follows = nixpkgs` without an explicit compatibility decision.

Before publishing a change, run:

```bash
nix flake check --all-systems
nix build .#packages.x86_64-linux.default
```

To run the standalone package after publishing:

```bash
nix run github:Joaoferraz-byte/vim-conf
```

## Integrate with NixOS and Home Manager

Add this flake as an input and keep the official NixVim Home Manager module in the consuming profile. Import this repository's module inside `programs.nixvim.imports`:

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

The configuration includes JDTLS, Spring Boot tooling, AngularLS, TypeScript, ESLint, HTML, CSS, JSON, YAML, Emmet, Tailwind CSS, Conform, DAP, Clangd, CMake Tools, GDB, LLDB, OpenOCD, Cppcheck, Competitest, Telescope, Aerial, Harpoon, Neogit, Diffview, Trouble, Treesitter, Bufferline, Lualine, Gitsigns, Smart Splits, Zen Mode, Todo Comments, Web Devicons, and Oil.

Java projects are detected from `pom.xml`, Gradle files, wrapper scripts, or Git metadata. JDTLS uses an isolated workspace per project, with source downloads, code lenses, import organization, inlay hints, and DAP support. Spring Boot debugging attaches to port `5005` through the configured DAP profile.

AngularLS and TypeScript LSP are installed declaratively by the NixVim module. Project-specific Angular CLI versions should remain in each application's `devDependencies`, so the editor does not impose a global project version.

Formatting runs on save with a timeout and an LSP fallback when a dedicated formatter is unavailable. Use `<leader>lf` for manual formatting. The dashboard opens when Neovim starts without files, and the file explorer, Telescope, project picker, outline, Git tools, and DAP controls are exposed through the configured leader mappings.

## Dynamic DMS theme

The Neovim theme follows DankMaterialShell dynamically. Colors are read from the Matugen-generated file at `~/.config/DankMaterialShell/dms.css`, keeping the terminal, editor, and desktop shell visually aligned. This is a runtime palette adapter only; editor behavior remains declarative and does not require DMS during Nix evaluation.

## Key mappings

| Mapping | Action |
|---|---|
| `<leader>e` | Toggle the file explorer. |
| `<leader>d` | Open the dashboard. |
| `<leader>?` | Search all key mappings. |
| `<leader>ff` / `<leader>fg` | Find files / search content with Telescope. |
| `<leader>fr` / `<leader>fp` | Recent files / projects. |
| `<leader>o` | Toggle the Aerial outline. |
| `<leader>ha` / `<leader>ht` | Add to Harpoon / open the Harpoon list. |
| `s` / `S` | Flash navigation / Treesitter selection. |
| `<leader>z` | Toggle Zen Mode. |
| `gd`, `gD`, `gi`, `gr`, `K` | LSP navigation and documentation. |
| `<leader>lr`, `<leader>la`, `<leader>lf` | Rename, code action, and format. |
| `<leader>ld` | Toggle diagnostics with Trouble. |
| `<C-h/j/k/l>` | Navigate between splits. |
| `<leader>xb`, `<leader>xc`, `<leader>xn` | DAP breakpoint, continue, and step over. |
| `<leader>xi`, `<leader>xo`, `<leader>xt` | DAP step into, step out, and terminate. |
| `<leader>gg` / `<leader>gc` | Open Git status / create a commit with Neogit. |
| `<leader>gb`, `<leader>gl`, `<leader>gp`, `<leader>gr` | Branches, pull, push, and rebase. |
| `<leader>gd`, `<leader>gh`, `<leader>gH`, `<leader>gB` | Diff, file history, repository history, and line blame. |

## Validation

The repository declares a standalone package and a NixVim check:

```bash
nix flake check --no-build
nix build .#default
```

The consuming NixOS configuration can be evaluated with:

```bash
nix eval .#nixosConfigurations.myMachine.config.system.build.toplevel.drvPath
```

## References

[1]: https://nix-community.github.io/nixvim/user-guide/install.html "NixVim — Installation"
[2]: https://nix-community.github.io/nixvim/plugins/jdtls/index.html "NixVim — JDTLS"
[3]: https://nix-community.github.io/nixvim/plugins/dap/index.html "NixVim — DAP"
[4]: https://nix-community.github.io/nixvim/plugins/lsp/servers/angularls/index.html "NixVim — AngularLS"
[5]: https://github.com/nix-community/nixvim/blob/main/plugins/by-name/conform-nvim/default.nix "NixVim — Conform module"
[6]: https://nix-community.github.io/nixvim/plugins/neogit/index.html "NixVim — Neogit"
[7]: https://nix-community.github.io/nixvim/plugins/diffview/index.html "NixVim — Diffview"
[8]: https://nix-community.github.io/nixvim/plugins/competitest/index.html "NixVim — Competitest"
[9]: https://nix-community.github.io/nixvim/plugins/cmake-tools/index.html "NixVim — CMake Tools"
