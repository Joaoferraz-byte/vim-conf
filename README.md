# Livara NixVim

This repository provides a declarative and reproducible NixVim environment for Java, Spring Boot, Angular, web, C/C++, embedded and competitive programming. LSP servers, formatters, debuggers and development dependencies are supplied by Nix rather than installed imperatively through Mason.

## Public contract

| Output | Purpose |
|---|---|
| `lib.nixvimModule` | Reusable NixVim module for Home Manager or another composition. |
| `lib.nixvimModules.default` | Alias for the default reusable module. |
| `packages.<system>.default` | Standalone NixVim package for Linux. |
| `checks.<system>.nixvim` | Check for the standalone package. |
| `formatter.<system>` | Repository formatter. |

The flake publishes Linux systems only because the configuration includes Wayland tools such as `wl-clipboard`, terminal/image tooling and Livara desktop integrations. Upstream NixVim may support other systems, but this configuration does not promise compatibility that has not been evaluated.

## Controlled updates

The editor and plugin versions are determined by `flake.lock`. Startup, `nix flake check`, `nix eval`, `nix build` and system rebuilds use the locked inputs; none of these paths may update the lockfile or implicitly fetch a newer revision. `lazy.nvim` also keeps its update checker disabled because plugin installation is declarative NixVim responsibility.

To update on demand, change the lockfile in an explicit operation and review the diff before committing:

```bash
# Inside this repository: update only the upstream NixVim dependency.
nix flake update nixvim
git diff --check
git diff -- flake.lock
git add flake.lock && git commit -m "chore: update nixvim input"

# In the consuming system: update the selected desktop inputs.
NIX_CONF_UPDATE_FLAKE=1 NIX_CONF_UPDATE_INPUTS="vim-conf nixvim" ./install.sh
```

The first flow publishes a new `vim-conf` revision; the second explicitly updates the `nix-conf` lockfile. If the revision is rejected, discard the lockfile commit or use the backup created by the installer. Updating the editor is therefore an auditable administrative action rather than a side effect of starting Neovim.

## Architecture

The configuration uses a hybrid **layered and workflow** architecture rather than imposing a strict dendritic pattern:

| Layer | Owner |
|---|---|
| Flake contract | `flake.nix`: inputs, outputs, systems and formatter. |
| Editor | `config/options.nix`: global options, defaults and performance. |
| Theme | `config/theme.nix`: Matugen, highlights, transparency and reload. |
| UI | `config/plugins/ui.nix`: Snacks, Oil, Which-Key, Noice, statusline and interface surfaces. |
| Core | `config/plugins/core.nix`: Git, Treesitter, movement, text objects and specialized tools. |
| Languages | `config/languages/*.nix`: LSP, toolchains and ecosystem tests. |
| Workflows | `config/keymaps.nix` and Lua helpers: Java/Spring, projects, file creation, Git, DAP and testing. |

Each plugin has one primary owner. The layout does not artificially fragment every option into its own file: plugins that form a workflow stay together, while distinct domains remain isolated.

## Matugen/Livara theme

The editor keeps `habamax` as its first-start fallback and forces `background = "dark"`. When `~/.config/nvim/lua/matugen_colors.lua` exists, `config/theme.nix` loads the Lua table produced by the Livara adapter and applies the wallpaper-derived palette.

The loader uses one `_G.reload_livara_theme` contract and a `vim.uv.new_fs_event` watcher. `LivaraStatusline` is the sole owner of `vim.o.statusline`: the global footer uses a linear composition with file, Git, diagnostic, LSP client, filetype, position and scrollbar information. `vim.o.winbar` intentionally remains empty, preventing a breadcrumb plugin from inheriting or redrawing the bar. The canvas and statusline groups are transparent; menus, floats and completion retain contrasting surfaces.

Matugen is the owner of the dynamic palette. NixVim only consumes the generated file and does not start a compositor, visual shell, QuickShell, Hyprland or Serpantinum.

## Interface and workflows

Snacks is the foundation for picker, explorer, dashboard, input, notifier, quickfile, terminal, image, scope, indent and zen. Oil owns filesystem editing as a buffer. Neo-tree, NvimTree, Telescope, Mini Files and project.nvim are not active.

Specialized plugins remain when no real parity exists: Aerial for outlines, Neogit/Diffview/Gitsigns for Git, nvim-dap for debugging, Conform for formatting, Neotest for testing and nvim-java/JDTLS for Java. Modernization does not remove a feature merely because another area has a newer plugin.

### Rich Markdown

The Vault workflow is centered on portable Markdown and does not depend on an Obsidian runtime. `render-markdown.nvim` renders buffers through explicit options for headings, code blocks, lists, checkboxes, callouts, tables, links and LaTeX formulas; Treesitter reproducibly installs Markdown, Markdown inline, HTML, YAML and LaTeX parsers. `mermaid.nvim` remains the dedicated tool for Mermaid diagrams and terminal previews. The 16 MiB file limit prevents large notes from becoming a global latency source, and rendering preserves source text for normal editing.

| Resource | Implementation | Runtime dependency |
|---|---|---|
| Structured Markdown | `render-markdown.nvim` with explicit options and rounded tables | NixVim + Treesitter |
| Inline/block LaTeX | `latex` parser and `utftex`/`latex2text` converter when available | Optional executable in `PATH` |
| Mermaid | `mermaid.nvim` plugin pinned in the flake | `chafa` for terminal fallback when supported |
| Frontmatter | `yaml` parser and Marksman LSP | NixVim |
| Templates | Static and explicit file creation in the Lua workflow | No Obsidian plugin |

| Mapping | Action |
|---|---|
| `<leader>e` / `<leader>mf` | Open Snacks Explorer. |
| `<leader>vd` / `<leader>vs` / `<leader>vc` | Create a daily note, source or concept in the Vault with static frontmatter. |
| `<leader>vb` / `<leader>vq` | Create a book reference or capture text in the Vault inbox. |
| `-` | Open Oil in the parent directory. |
| `<leader>cn` / `<leader>cs` | Open the Neovim or system configuration in Oil. |
| `<leader>d` | Open the Snacks dashboard. |
| `v` in Dashboard | Open the Vault at `~/Vault` using Oil. |
| `<leader>ff` / `<leader>fg` | Find files or search content with Snacks Picker. |
| `<leader>fi` | Find image/document files with Snacks preview when supported by the terminal. |
| `<leader>fr` / `<leader>fp` | Recent files or projects. |
| `<leader>o` | Toggle the Aerial outline. |
| `<leader>ha` / `<leader>ht` | Add to Harpoon or open its native quick menu. |
| `s` / `S` | Flash navigation or Treesitter selection. |
| `<leader>z` | Toggle Snacks Zen. |
| `gd`, `gD`, `gi`, `gr`, `K` | LSP navigation and documentation. |
| `<leader>lr`, `<leader>la`, `<leader>lf` | Rename, code action and format. |
| `<leader>j*` | Java workflow: run/build with nvim-java, inspect JDTLS, organize imports, debug through DAP, and run/debug Neotest tests. |
| `<leader>lx` | Toggle diagnostics with Trouble. |
| `<C-h/j/k/l>` | Navigate between Neovim splits; the global physical remapping remains owned by keyd. |

Advanced file creation, the project picker and the Spring Boot wizard use documented Snacks APIs (`Snacks.input`, `Snacks.picker.pick` and `vim.ui.select`). The wizard validates the directory and uses `curl`/`tar` with explicit escaping, keeping the operation outside Nix evaluation.

## Languages and toolchains

The configuration includes LSP support for Lua, Nix, Bash, Docker, C/C++, Python, Markdown, Angular, TypeScript, ESLint, HTML, CSS, JSON, YAML, Emmet and Tailwind. It also includes CMake Tools, OpenOCD, Cppcheck, Competitest and a declarative LeetCode workflow under `<leader>p`.

The supported coverage is organized as follows:

| Ecosystem | Support | LSP/completion owner |
|---|---|---|
| Java, Spring Boot, Swing/JFrame | Dedicated local JDTLS workflow with Maven, Gradle, nvim-java, Neotest and DAP | nvim-java/JDTLS + `nvim-cmp` |
| HTML, CSS, JavaScript/TypeScript | Angular root-scoped by `angular.json`/`nx.json`, TypeScript, ESLint, HTML, CSS, Emmet and Tailwind | Declarative NixVim servers + `nvim-cmp` |
| PHP | PHP and Composer projects | `phpactor` + `nvim-cmp` |
| C/C++ | C and C++ with clang/gcc toolchains | `clangd` + `nvim-cmp` |
| Python and Manim | Python; Manim is a Python library/workflow using the same server | `pyright` + `nvim-cmp` |
| SQL/PostgreSQL | SQL with PostgreSQL/PLpgSQL-specific analysis | `postgres_lsp` + `nvim-cmp` |
| XML | XML, XSD, XSLT, SVG | `lemminx` + `nvim-cmp` |

Java is a dedicated local workflow backed by JDTLS and orchestrated by nvim-java. JDTLS, the JDK, Lombok, Java Test and Java Debug Adapter are provided by Nix and referenced by fixed store paths; no nvim-java tool downloads occur at startup. Spring Tools auto-install is disabled because the pinned nixpkgs set does not provide the matching VS Code extension as a native store package. The Spring Boot plugin remains available without making it a second Java LSP client.

Completion uses the shared `nvim-cmp` sources and the global LSP capabilities path. JDTLS provides diagnostics, completion, references, code actions and formatting; `java.configuration.completion.importOnCompletion` and `saveActions.organizeImports` manage imports, while Conform does not issue a competing Java LSP format request. `<leader>jl` opens `:LspInfo`, `<leader>jh` checks LSP health, `<leader>jo` runs an explicit organize-import fallback, `<leader>jr` runs the current main class, `<leader>jR` builds the workspace, and `<leader>jt`/`<leader>jT` run or debug the nearest test.

Every Java file creation path converges on `lua/java_scaffold.lua`. The module infers the project root, Maven/Gradle group package and source root, validates package/class names, creates the requested class atomically and opens it with Java filetype. Names ending in `Exception` or `Error` receive a `RuntimeException` base by default; interfaces, enums and records are supported through the same renderer API. Snacks Explorer, Oil, `BufNewFile` and the generic new-file workflow do not maintain separate Java templates. The dashboard no longer exposes an unsolicited Java creation shortcut.

`.xopp` files are not interpreted as text by the editor. The `BufReadCmd` autocmd starts Xournal++ with the absolute path and removes the temporary buffer; the corresponding XDG association is declared in `nix-conf` with the `application/x-xopp` MIME type. Opening the file through Oil, Snacks or the file manager therefore converges on the same format owner.

Formatting is declared through Conform with LSP fallback and Nix executables for Java, C/C++, Python, web, Nix, Lua and shell; Python uses the Ruff formatter. Debugging uses LLDB for C/C++ and Java attach on port 5005.

## Incremental validation

Because the consuming NixOS configuration has a large closure, validation should be incremental:

```bash
# Parse each Nix module
find config -name '*.nix' -print0 | xargs -0 -n1 nix-instantiate --parse

# Evaluate outputs and options without materializing the system
nix flake check --no-build --show-trace --all-systems
nix eval .#packages.x86_64-linux.default
nix eval .#checks.x86_64-linux.nixvim
```

The standalone package `nix build` is a later validation step and should run on a machine with sufficient space and memory. Building the complete NixOS toplevel is not necessary to validate syntax, options, imports or NixVim contracts.

## NixOS and Home Manager integration

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

## References

- [NixVim](https://github.com/nix-community/nixvim)
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
- [Oil.nvim](https://github.com/stevearc/oil.nvim)

## Repository structure

```text
.
ARCHITECTURE_PROPOSAL.md
README.md
config
  └── config/default.nix
  └── config/keymaps.nix
  └── config/languages
  └── config/options.nix
  └── config/plugins
  └── config/theme.nix
flake.lock
flake.nix
```
