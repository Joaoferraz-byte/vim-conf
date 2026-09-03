# Java and application integration architecture

## Decision

The Java backend is Eclipse JDT Language Server (JDTLS), orchestrated by `nvim-java`. IntelliJ IDEA remains an optional desktop IDE and is not a Neovim language-server dependency. The editor uses one Java LSP owner and does not start `nvim-jdtls` or an IntelliJ bridge beside it.

NixVim remains viable because the repository already provides a stable module boundary, while runtime-sensitive behavior lives in one Lua module. Package management remains declarative: JDTLS, JDKs, Lombok, Java Test and Java Debug Adapter are referenced through Nix store paths, and nvim-java auto-install is disabled.

## Ownership and boundaries

| Owner | Responsibility | Non-responsibility |
| --- | --- | --- |
| `vim-conf` | NixVim modules, Java UX, diagnostics, completion, format routing, tests, debug and file creation | Installing mutable Java tools or managing IDE profile state |
| `nix-conf` | JDKs, JDTLS, Java CLI tools, IntelliJ/Android Studio packages, desktop entries and Matugen entrypoints | Java buffer callbacks or a second LSP client |
| `shell-conf` | Runtime application adapters for generated palettes and documented external formats | Noctalia ownership or arbitrary application state resets |
| `noctalia-conf` | Noctalia runtime, stable settings, wallpaper policy, templates and plugin lifecycle | Application-specific imperative configuration |
| NixVim | Declarative plugin composition and stable setup order | Runtime context that requires Lua callbacks |
| Lua | JDTLS callbacks, Java scaffolding, explorer adapters and editor commands | Downloading mutable tools or duplicating package management |
| JDTLS/nvim-java | Java project model, classpath, completion, diagnostics, imports, formatting, runner, tests, debug and refactoring | Desktop IDE UI |
| Conform | One formatter policy per filetype | Java semantic import resolution |

## Java workflow contract

JDTLS is enabled through `plugins.java`; `plugins.jdtls` is not enabled. The global `cmp_nvim_lsp` capability path is reused, so completion does not create a second capability configuration. The Java configuration enables automatic import on completion, organize-imports on save, project-aware source roots, Maven/Gradle markers, code lenses, formatting, diagnostics and multiple JDK runtimes.

The Java toolchain is externalized to Nix paths. The current nixpkgs set provides JDTLS 1.60.0, JDK 8/21/25, Lombok 1.18.46, Java Test 0.45.0 and Java Debug 0.59.0. nvim-java uses those paths with `auto_install = false`. Spring Tools auto-install is disabled because the matching VS Code extension is not provided as a native package in the pinned nixpkgs set; the Spring Boot plugin remains available without introducing another Java LSP owner.

Java formatting is owned by JDTLS. Conform does not issue a competing Java LSP format request, while the explicit organize-import action remains available as a fallback. Diagnostics are presented through `vim.diagnostic`, and Neotest/DAP use the nvim-java-provided Java integrations.

`lua/java_scaffold.lua` is the only source of Java file creation behavior. It infers project root, Maven/Gradle package and source root, validates names, prevents escape from the project root, writes atomically and opens the result as Java. `Exception` and `Error` suffixes default to `RuntimeException`; class, interface, enum and record rendering are supported through the same module. Snacks Explorer, Oil, `BufNewFile` and generic new-file creation pass context to this module rather than carrying independent templates. The dashboard does not expose a Java creation shortcut.

## Application theme contract

Noctalia produces the wallpaper-derived palette. `shell-conf` converts it only into documented target formats: `.icls` for IntelliJ IDEA and Android Studio, `.tdesktop-theme` for Telegram Desktop, and `theme.css` source for Hydra Launcher. Telegram import remains a user action. Hydra publication remains a review and pull-request action through the official `hydra-themes` repository.

Spotify replaces cmus in the Livara Home Manager profile. Spicetify-Nix produces a reproducible Spotify package with a Livara custom color scheme, Matugen-aligned CSS and a pinned Adblockify extension. The extension is treated as ad/UI blocking only; it is not represented as an unlock for paid Spotify features.

## Validation boundary

Low-cost checks are required first: `git diff --check`, shell syntax checks, Nix parsing, `nix flake check --no-build`, the headless Lua scaffold tests and isolated palette adapter tests. Full NixOS or NixVim builds remain host-gated because their closures are large. Visual compositor sizing, application UI rendering and cloud theme activation require a real user session and are not proven by sandbox evaluation.

## References

[1]: https://nixos.org/guides/nix-pills/ "Nix Pills"
[2]: https://nixos-and-flakes.thiscute.world/ "NixOS and Flakes"
[3]: https://github.com/nix-community/nixvim "NixVim"
[4]: https://github.com/nvim-java/nvim-java "nvim-java"
[5]: https://github.com/eclipse-jdtls/eclipse.jdt.ls "Eclipse JDTLS"
[6]: https://github.com/stevearc/conform.nvim "Conform"
[7]: https://wiki.nixos.org/wiki/Spicetify-Nix "Spicetify-Nix"
[8]: https://www.jetbrains.com/help/idea/configuring-colors-and-fonts.html "JetBrains color schemes"
[9]: https://core.telegram.org/themes "Telegram themes"
[10]: https://github.com/hydralauncher/hydra-themes "Hydra themes"
