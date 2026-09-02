# Java/Spring and IntelliJ migration proposal

## Decision

The default Java backend will be Eclipse JDT Language Server (JDTLS), orchestrated by `nvim-java`. The proprietary IntelliJ LSP bridge will no longer attach to Java or Kotlin buffers. IntelliJ IDEA remains an optional desktop IDE and is not used as a Neovim language-server dependency.

This decision is based on the current repository state, the public `gipo355/nvim-intellij-lsp` implementation, the current Nixvim module surface, Eclipse JDTLS, nvim-java, Neovim LSP, Conform, LeetCode and JetBrains documentation. The IntelliJ bridge is functional but depends on a preview backend, private launcher behavior, EULA negotiation, mutable remote bundles, log parsing and protocol workarounds. JDTLS and nvim-java provide a maintained open ecosystem for Maven, Gradle, Spring Boot Tools, completion, diagnostics, imports, formatting, tests, debug and refactoring.

## Ownership and boundaries

| Owner | Responsibility | Non-responsibility |
| --- | --- | --- |
| `vim-conf` | NixVim modules, editor UX, Java commands, diagnostics presentation, format routing, LeetCode and file creation | Installing system packages or managing IntelliJ mutable state |
| `nix-conf` | JDKs, JDTLS and CLI tools, IntelliJ IDEA package, Matugen templates, user files and desktop integration | Java buffer callbacks or a second LSP client |
| Nixvim | Declarative plugin composition and generated stable setup | Replacing dynamic Lua logic that needs runtime context |
| Lua | JDTLS callbacks, Java scaffolding planner, explorer adapters and runtime commands | Downloading mutable tools or duplicating package management |
| Eclipse JDTLS | Java project model, classpath, completion, diagnostics, navigation, imports and semantic actions | Spring-specific UI, editor keymaps and DAP presentation |
| `nvim-java` | JDTLS orchestration, Spring Boot Tools, Java test/debug bundles, runner, profiles and refactoring UX | Running alongside `nvim-jdtls` or IntelliJ LSP |
| Conform | One formatter policy per filetype and format-on-save | Semantic import resolution or a second Java formatter |
| JDTLS plus Checkstyle | Java semantic diagnostics plus build-aligned style warnings | Treating Checkstyle as a replacement for type analysis |
| IntelliJ IDEA | Desktop Java/Spring IDE with IdeaVim, NixIDEA, Spring Explyt and Matugen color scheme | Providing Neovim's Java LSP |

## Nixvim viability

Nixvim is viable for this NixOS/Home Manager configuration because the environment already owns a Nixvim flake and supplies tools declaratively. The configuration will use Nixvim for stable plugin modules and `extraConfigLua` only for runtime behavior that has no stable option surface. It will not make Nixvim or Nix the owner of the same generated and mutable files twice.

The Nixvim input must remain compatible with the locked nixpkgs revision. The configuration will not add a second `plugins.jdtls` owner beside `plugins.java`; Nixvim explicitly rejects that combination. Auto-installation in nvim-java will be disabled when a compatible Nix path exists. If a required bundle cannot be supplied by the current nixpkgs closure, the implementation will fail visibly and will not silently add an imperative downloader.

## Java workflow contract

The workflow uses the following stable contracts:

1. `nvim-cmp` consumes JDTLS completion capabilities. JDTLS remains the source of project-aware suggestions and imports.
2. JDTLS publishes syntax, compilation and semantic diagnostics through `vim.diagnostic`. Checkstyle is a separate save-time supplement when a project provides its configuration.
3. Java import organization is an explicit JDTLS action. It is not delegated to a formatter.
4. Conform owns format-on-save routing. Java has one selected authority per project: JDTLS formatting or `google-java-format`; the initial migration keeps the LSP fallback and does not run both on one save.
5. `nvim-java` owns Java test/debug/runner commands. The existing DAP UI remains a presentation layer and must not start a second adapter.
6. `leetcode.nvim` remains isolated from Spring workspaces and uses `lang = "java"` with `plugins.non_standalone = true`.
7. `java_scaffold.lua` is the single source of truth for package derivation and class creation. Global mappings, Snacks, Oil and any Neo-tree adapter only pass context to it.

## File and naming standard

The repository keeps one primary owner per workflow. Language modules use `config/languages/<domain>.nix`; cross-plugin behavior uses `config/keymaps.nix` only when it is a genuine editor workflow. New runtime logic belongs in `lua/<domain>.lua` rather than a shell script or a second copy of the same function in a Nix string.

Configuration comments are concise, written in English and limited to non-obvious ownership, compatibility or safety decisions. User-facing notifications and documentation may use Portuguese, but configuration comments will not duplicate the implementation. Commit messages use imperative Conventional Commit prefixes and every commit is authored as `Joaoferraz-byte <joaoferraz467@gmail.com>` on `main`.

## Migration stages

| Stage | Scope | Verification | Commit/push boundary |
| --- | --- | --- | --- |
| 0 | Record this architecture and inspect the legacy integration | Search all relevant repositories, inspect recent history and validate upstream URLs | This document, then `main` push |
| 1 | Replace IntelliJ LSP with nvim-java/JDTLS | Nix option search, source inspection, syntax checks and generated config assertions | Java module change, then `main` push |
| 2 | Align Java UX, formatting, diagnostics, DAP and LeetCode | Static checks, Lua parse checks and focused configuration searches | Workflow changes, then `main` push |
| 3 | Centralize Java file creation and connect all entry points | 50–200 pure planner cases plus adapter smoke checks | Scaffold module and tests, then `main` push |
| 4 | Provision IntelliJ, plugins and Matugen contract | Nix evaluation, XML/template checks and plugin ID/license review | `nix-conf` changes, then `main` push |
| 5 | Integrate the published `vim-conf` revision into `nix-conf` | Lockfile diff, `nix flake check --no-build`, targeted eval and status checks | Lock/update commit, then `main` push |

Full NixOS and editor builds are intentionally deferred to the host gate because the closure is large. Every stage uses small, high-signal checks first: parse all Nix modules, compile Lua modules, inspect generated references, validate package attributes and run a bounded matrix of planner cases. No helper script is introduced to hide a configuration problem.

## Acceptance criteria

A Java file in a Maven or Gradle module attaches exactly one JDTLS-backed client. Completion resolves project and dependency symbols, diagnostics distinguish errors and warnings, organize-imports is available, and a project dependency change can refresh the workspace. Saving a Java file uses the selected formatter without reordering imports unexpectedly. Java tests, debug and runner commands work through the existing DAP/test UX. LeetCode opens Java solutions without attaching Spring tooling. Creating a class from a normal buffer, the dashboard, an explorer or `:JavaNew` produces the same package and class template, never overwrites an existing file and rejects unsafe or ambiguous paths.

IntelliJ is installed through the current Nixpkgs package name, with free plugins identified by their official Marketplace IDs. Matugen generates an IntelliJ `.icls` color scheme from a versioned template; it does not pretend to control the full IDE chrome. IdeaVim and NixIDEA remain inside IntelliJ, while Neovim keeps consuming the shared Matugen palette independently.

## References

[1]: https://nixos.org/manual/nixos/stable/ "NixOS Manual"
[2]: https://nix-community.github.io/nixvim/user-guide/install.html "Nixvim Installation"
[3]: https://github.com/eclipse-jdtls/eclipse.jdt.ls "Eclipse JDT Language Server"
[4]: https://github.com/nvim-java/nvim-java "nvim-java"
[5]: https://github.com/stevearc/conform.nvim "conform.nvim"
[6]: https://github.com/kawre/leetcode.nvim "leetcode.nvim"
[7]: https://github.com/gipo355/nvim-intellij-lsp "Legacy IntelliJ LSP client"
[8]: https://plugins.jetbrains.com/plugin/28675-spring-explyt "Spring Explyt Marketplace"
[9]: https://plugins.jetbrains.com/plugin/8607-nixidea "NixIDEA Marketplace"
[10]: https://plugins.jetbrains.com/plugin/164-ideavim "IdeaVim Marketplace"
[11]: https://github.com/InioX/matugen/wiki/Templates "Matugen Templates"
[12]: https://www.reddit.com/r/NixOS/comments/108fwwh/tradeoffs_of_using_home_manager_for_neovim_plugins/ "Tradeoffs of using Home Manager for Neovim plugins"
[13]: https://www.reddit.com/r/NixOS/comments/1fbyvwf/anyone_using_nixvim/ "Anyone using Nixvim"
[14]: https://nixos.org/guides/nix-pills/ "Nix Pills"
[15]: https://mhwombat.codeberg.page/nix-book/ "Wombat's Book of Nix"
