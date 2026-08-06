## [Unreleased] - 2026-08-06

### Added
- **Neotest + neotest-java**: Test runner inline para Java (run/debug arquivo ou teste mais próximo, summary, output panel) sob `<leader>t`, integrado ao DAP existente
- **Dashboard Footer Dinâmico**: Mostra versão do nvim, módulos Lua carregados e data, mantendo header LIVARA e center intactos

### Changed
- **Transparência Total**: Fundo do editor (não só floats) agora transparente igual ao terminal — Normal, StatusLine, TabLine, Pmenu, SignColumn, etc.
- **Tema DMS Reativo**: Cores e transparência agora são reaplicadas a cada `ColorScheme` (autocmd), não só no startup, sobrevivendo a reloads de tema disparados pelo DMS/matugen

### Fixed
- **Catppuccin Theme Removed**: Replaced Catppuccin Mocha with DMS dynamic theme
- **DMS Theme Integration**: Neovim now reads colors from DankMaterialShell matugen palette
- **Dashboard UI Clean**: Disabled line numbers, syntax, cursorline, and word highlights on startup
- **Floating Window Transparency**: Telescope, leader menus, and popups now match terminal background
- **project.nvim Corruption**: Added error handling for corrupted history.json
- **Illuminate on Dashboard**: Disabled word highlights on dashboard, NvimTree, and help buffers

## [2026-08-04]

### Added
- Catppuccin Mocha theme with transparency
- dashboard-nvim with Doom theme
- Which-Key modern keymap discovery
- Snacks.nvim for enhanced UI experience
