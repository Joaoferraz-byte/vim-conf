# NixVim architecture decision

## Scope

This document compares architectural alternatives for the current `vim-conf` and chooses a target based on its existing features, NixOS integration, visual requirements, Java/web development needs, and the need to avoid another large rebuild.

## Alternatives

| Alternative | Strengths | Costs for this repository | Decision |
|---|---|---|---|
| Monolithic NixVim module | Simple import contract and straightforward evaluation. | UI, languages, themes and integrations remain coupled; plugin overlap is hard to reason about. | Reject as target. |
| Strict dendritic modules | One feature per file; easy ownership and selective imports. | Can create excessive fragmentation and artificial modules when several plugins form one workflow. | Use selectively, not dogmatically. |
| Layered architecture | Separates platform contract, editor core, UI foundation, language profiles, workflows and theme adapter. | Requires clear boundaries and some cross-layer contracts. | Choose as primary architecture. |
| Vertical feature slices | Keeps each workflow together, e.g. Java/Spring, Git, debug, filesystem. | Shared UI primitives can be duplicated if slices are too independent. | Combine with layers for workflows. |
| Lua-first with Nix packaging/nixCats | Keeps Neovim-native structure, easier upstream reuse and runtime iteration; category systems can reduce packages per host. | Changes the public contract, increases migration scope and weakens the existing NixVim module reuse unless carefully wrapped. | Do not migrate now; reassess only if NixVim becomes a limitation. |
| Snacks-only UI | Reduces picker/input/dashboard/notifier duplication and centralizes visual behavior. | Snacks does not replace DAP, LSP, formatter, Java tooling or every Git workflow; image and explorer semantics differ. | Choose Snacks as UI foundation, not universal replacement. |

## Chosen model: layered core plus vertical workflows

The target is a **hybrid layered/feature architecture**:

```text
vim-conf flake contract
└── NixVim public module
    ├── platform.nix       NixOS/Wayland/system packages and paths
    ├── editor.nix         options, globals and editor defaults
    ├── ui.nix             Snacks/Oil/Which-Key/Noice/status surfaces
    ├── completion.nix     completion and snippets
    ├── language modules   LSP, treesitter, formatters and language tools
    ├── workflows           Git, test, debug, Spring/Java, LeetCode, projects
    └── theme.nix          Matugen adapter and highlight contract
```

This is not strict dendritic organization. A module may own a coherent workflow even when it contains several cooperating plugins. The rule is that every plugin has one owner and every user-facing command has one canonical implementation.

## UI ownership decision

The current configuration uses Snacks as the picker/explorer foundation and Oil as the filesystem buffer owner. The architecture keeps this separation explicit and avoids reintroducing overlapping file browsers:

| Capability | Canonical owner | Retained alternatives |
|---|---|---|
| Filesystem editing and directory navigation | Oil | None for the same role. |
| File/grep/buffer/LSP/project pickers | Snacks Picker | Telescope removed where parity is confirmed. |
| Dashboard | Snacks Dashboard | Custom actions are declared in the existing dashboard workflow. |
| Input/notifications/quickfile/terminal/zen | Snacks | No duplicate plugin for the same surface. |
| Icons/text objects | mini.icons, mini.ai, mini.surround, mini.bracketed | mini.files removed because Oil owns filesystem navigation. |
| LSP symbols/outline | Aerial or Snacks picker, one canonical owner per command | Keep Aerial if its outline view is required. |
| Git status/history/diff | Neogit/Diffview/Gitsigns | Snacks Git/picker may replace only commands with verified parity. |
| Debugging | nvim-dap/dap-ui | No Snacks replacement. |
| Java/Spring | JDTLS, nvim-jdtls and Neotest | Keep the validated Java workflow; do not introduce an untested IntelliJ LSP replacement. |

## Theme ownership

Matugen remains the dynamic palette owner. The NixVim module consumes a generated palette through a single theme adapter. It must not contain `Serpantinum` names, compositor assumptions, or multiple independent transparency autocmd systems. Theme application should have:

1. one palette loader;
2. one highlight application function;
3. one reload watcher or explicit user command;
4. plugin-specific groups only when the plugin is actually enabled;
5. bounded transparency rules that do not erase intentional readable surfaces.

## Reproducibility and validation

The flake publishes only systems compatible with the actual configuration. The current configuration is Linux/Wayland-specific because it packages `wl-clipboard` and related tools; Darwin outputs are not promised. Validation is incremental: parse all Nix files, run `flake check --no-build`, evaluate selected module attributes, build the small NixVim package only after option evaluation succeeds, and reserve a full NixOS build for the user's machine rather than the temporary sandbox.

## Non-goals

This refactor does not replace NixVim with nixCats, nvf or a Lua-only repository. It does not remove specialized plugins merely because Snacks is newer. It does not change Java tooling without first testing LSP initialization, code lenses, import organization, neotest and DAP attach behavior.

## References

- [NixVim](https://github.com/nix-community/nixvim)
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
- [Oil.nvim](https://github.com/stevearc/oil.nvim)
- [Community comparison](https://www.reddit.com/r/NixOS/comments/1jgmdo3/best_way_to_manage_neovim_config_on_nixos/)
