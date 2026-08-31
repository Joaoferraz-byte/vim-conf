#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ui="$repo_root/config/plugins/ui.nix"
keymaps="$repo_root/config/keymaps.nix"
web="$repo_root/config/languages/web.nix"
vault="$repo_root/config/plugins/vault.nix"

fail() {
  printf 'NixVim contract check failed: %s\n' "$1" >&2
  exit 1
}

require() {
  local pattern="$1"
  local file="$2"
  grep -Eq -- "$pattern" "$file" || fail "missing '$pattern' in ${file#$repo_root/}"
}

require_literal() {
  local pattern="$1"
  local file="$2"
  grep -Fq -- "$pattern" "$file" || fail "missing literal '$pattern' in ${file#$repo_root/}"
}

forbidden() {
  local pattern="$1"
  local file="$2"
  if grep -Eq -- "$pattern" "$file"; then
    fail "forbidden '$pattern' in ${file#$repo_root/}"
  fi
}

require 'disabled_statusline_filetypes = \{' "$ui"
require 'snacks_dashboard = true' "$ui"
require 'snacks_picker_list = true' "$ui"
require 'oil = true' "$ui"
require 'attach_navic = false' "$ui"
require 'fidget' "$ui"
require 'poll_rate = false' "$ui"
require 'suppress_on_insert = true' "$ui"
forbidden 'icon = "λ"' "$ui"
forbidden '__unkeyed-1 = "filename"' "$ui"
require 'filetype_component' "$ui"
require '_G\.load_current_template' "$ui"
require 'key = "<leader>nt"' "$keymaps"
require 'Snacks\.dashboard\(\)' "$keymaps"
forbidden '<cmd>Dashboard<CR>' "$keymaps"
require '"<S-Right>"' "$repo_root/config/plugins/completion.nix"
require '"<S-Left>"' "$repo_root/config/plugins/completion.nix"
require_literal 'cmp.mapping.confirm({ select = false })' "$repo_root/config/plugins/completion.nix"
require 'LspAttach' "$ui"
require 'documentSymbolProvider' "$ui"
require 'LivaraStatusline\.render' "$ui"
require 'BufferLineDevIcon' "$repo_root/config/theme.nix"
require 'NeoTreeFileIcon' "$repo_root/config/theme.nix"
require 'NvimTreeFileIcon' "$repo_root/config/theme.nix"
require 'BufWinEnter' "$repo_root/config/theme.nix"
require 'livara_theme_watcher_started' "$repo_root/config/theme.nix"
require 'livara_config_dir = vim\.fn\.stdpath\("config"\)' "$repo_root/config/theme.nix"
require 'lua/matugen_colors\.lua' "$repo_root/config/theme.nix"
require 'legacy/manual install fallback' "$repo_root/config/theme.nix"
forbidden 'local livara_theme_path = vim\.fn\.stdpath\("config"\) .. "/matugen_colors\.lua"' "$repo_root/config/theme.nix"
require 'vim\.o\.statusline' "$ui"
require 'LivaraStatusNormalMode' "$repo_root/config/theme.nix"
require 'LivaraStatusGit' "$repo_root/config/theme.nix"
require 'git_component' "$ui"
require 'mode_component\(\), git_component\(\), filetype_component\(\)' "$ui"
require 'return left .. "%=" .. right' "$ui"
require '  " .. mode.label' "$ui"
require 'winbar\(\)' "$ui"
require 'local path = vim.api.nvim_buf_get_name\(0\)' "$ui"
forbidden 'lualine' "$ui"
forbidden 'lualine' "$repo_root/config/theme.nix"
require 'filetypes = \[' "$web"
require '"php"' "$web"
require 'showExpandedAbbreviation = "always"' "$web"
for server in nil_ls lua_ls bashls dockerls clangd pyright marksman; do
  require "${server}" "$repo_root/config/languages/general.nix"
done
for server in ts_ls eslint html cssls jsonls yamlls emmet_language_server tailwindcss; do
  require "${server}" "$web"
done
require 'phpactor\.enable' "$repo_root/config/languages/specialized.nix"
require 'postgres_lsp\.enable' "$repo_root/config/languages/specialized.nix"
require 'lemminx\.enable' "$repo_root/config/languages/specialized.nix"
require 'plugins\.jdtls' "$repo_root/config/languages/java.nix"
require 'jdtLanguageServerPackage = pkgs\.jdt-language-server' "$repo_root/config/languages/java.nix"
require 'jdtls' "$repo_root/config/languages/java.nix"
require 'JDTLS_JVM_ARGS' "$repo_root/config/languages/java.nix"
require 'cmd = \[ "jdtls" \]' "$repo_root/config/languages/java.nix"
require 'filetypes = \[ "java" \]' "$repo_root/config/languages/java.nix"
require 'rootMarkers = \[' "$repo_root/config/languages/java.nix"
require 'JavaSE-1\.8' "$repo_root/config/languages/java.nix"
require 'JavaSE-21' "$repo_root/config/languages/java.nix"
require 'pkgs\.jdk8' "$repo_root/config/languages/java.nix"
require 'updateBuildConfiguration = "automatic"' "$repo_root/config/languages/java.nix"
require 'wrapper\.enabled = true' "$repo_root/config/languages/java.nix"
forbidden 'cmd = \[[^]]*--jvm-arg' "$repo_root/config/languages/java.nix"
require 'lombok' "$repo_root/config/languages/java.nix"
require 'neotest-java' "$repo_root/config/languages/java.nix"
forbidden 'intellij-lsp-plugin' "$repo_root/config/languages/java.nix"
forbidden 'intellij-server' "$repo_root/config/languages/java.nix"
require 'pattern = "\*\.xopp"' "$vault"
require 'silent! qa!' "$vault"
require 'nvim_buf_delete' "$vault"
require '"## Content"' "$vault"
forbidden '"## Claim"' "$vault"
forbidden '"## Evidence"' "$vault"
forbidden '"## Interpretation"' "$vault"
forbidden '"## Log"' "$vault"
forbidden 'Handwritten page' "$vault"
forbidden 'angularls\.enable' "$web"
require 'xml' "$repo_root/config/plugins/core.nix"
require 'language\.register, "xml", \{ "svg" \}' "$repo_root/config/plugins/core.nix"
require 'vim\.treesitter\.start, args\.buf, "xml"' "$repo_root/config/plugins/core.nix"

# Validate every embedded Lua block with the system compiler when available.
if command -v luac5.4 >/dev/null 2>&1; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  index=0
  for file in "$ui" "$repo_root/config/theme.nix" "$repo_root/config/plugins/completion.nix" "$vault"; do
    while IFS= read -r -d '' block; do
      index=$((index + 1))
      lua_file="$tmp_dir/block-${index}.lua"
      printf '%s\n' "$block" > "$lua_file"
      luac5.4 -p "$lua_file" || fail "Lua syntax in ${file#$repo_root/} block $index"
    done < <(python3 - "$file" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text()
start = 0
while True:
    marker = text.find("extraConfigLua = ''", start)
    if marker < 0:
        break
    body_start = marker + len("extraConfigLua = ''")
    body_end = text.find("'';", body_start)
    if body_end < 0:
        raise SystemExit(f"unterminated extraConfigLua in {sys.argv[1]}")
    sys.stdout.write(text[body_start:body_end] + "\0")
    start = body_end + 3
PY
)
  done
  printf 'Embedded Lua syntax: OK (%d blocks)\n' "$index"
fi

printf 'NixVim contracts: OK\n'
