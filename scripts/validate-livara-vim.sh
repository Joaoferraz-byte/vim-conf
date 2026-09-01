#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ui="$repo_root/config/plugins/ui.nix"
statusline="$repo_root/config/plugins/statusline.nix"
keymaps="$repo_root/config/keymaps.nix"
web="$repo_root/config/languages/web.nix"
vault="$repo_root/config/plugins/vault.nix"
theme="$repo_root/config/theme.nix"

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

# The native renderer owns both bars and hides noisy/special buffers.
require 'hidden_filetypes = \{' "$statusline"
require 'snacks_dashboard = true' "$statusline"
require 'snacks_picker_list = true' "$statusline"
require 'snacks_picker_preview = true' "$statusline"
require 'oil = true' "$statusline"
require 'fidget' "$ui"
require 'poll_rate = false' "$ui"
require 'suppress_on_insert = true' "$ui"
forbidden 'icon = "λ"' "$ui"
forbidden '__unkeyed-1 = "filename"' "$ui"
require '_G\.load_current_template' "$ui"
require 'key = "<leader>nt"' "$keymaps"
require 'Snacks\.dashboard\(\)' "$keymaps"
forbidden '<cmd>Dashboard<CR>' "$keymaps"
require '"<S-Right>"' "$repo_root/config/plugins/completion.nix"
require '"<S-Left>"' "$repo_root/config/plugins/completion.nix"
require_literal 'cmp.mapping.confirm({ select = false })' "$repo_root/config/plugins/completion.nix"

# Statusline/winbar visual contract: mini.statusline-inspired sections, no
# capsules outside the single fixed-color mode segment.
require 'LivaraBar\.statusline' "$statusline"
require 'LivaraBar\.winbar' "$statusline"
require 'vim\.o\.statusline' "$statusline"
require 'vim\.o\.winbar = "%!v:lua\.LivaraBar\.winbar\(\)"' "$statusline"
require 'laststatus = 3' "$repo_root/config/options.nix"
require 'MODE_BG = "#ff6b9d"' "$statusline"
require 'LivaraModeEdge' "$statusline"
require 'LivaraModeIcon' "$statusline"
require 'LivaraModeText' "$statusline"
require 'LivaraModeTail' "$statusline"
require 'mode_segment' "$statusline"
require 'git_component' "$statusline"
require 'diagnostics_component' "$statusline"
require 'lsp_component' "$statusline"
require 'position_component' "$statusline"
require 'line_count_component' "$statusline"
require 'file_icon' "$statusline"
require 'MiniIcons\.get' "$statusline"
require 'narrow_statusline' "$statusline"
require 'BufModifiedSet' "$statusline"
require 'livara_statusline_activate' "$statusline"
require 'LivaraStatusText' "$theme"
require 'LivaraStatusMuted' "$theme"
require 'LivaraStatusAccent' "$theme"
for group in LivaraStatusError LivaraStatusWarn LivaraStatusInfo LivaraStatusHint LivaraStatusGit; do
  require "$group" "$theme"
done
for forbidden_visual in 'pill' 'LivaraCap' 'LivaraBarCap' 'LivaraBarBlock' 'blend = 8' 'LivaraStatusMode|LivaraStatusGitSep|LivaraStatusLocationSep'; do
  forbidden "$forbidden_visual" "$statusline"
done
forbidden 'barbecue|nvim-navic' "$ui"
forbidden 'barbecue|nvim-navic' "$theme"
forbidden 'lualine' "$ui"
forbidden 'lualine' "$theme"
forbidden 'vim\.fn\.expand\("%:~:\."\)' "$statusline"
forbidden 'filetype_component' "$statusline"
require_literal '.. "  %#LivaraModeText#"' "$statusline"

# Bufferline remains transparent for all background-bearing subcomponents.
for group in warning warning_visible warning_selected warning_diagnostic warning_diagnostic_visible warning_diagnostic_selected error error_visible error_selected error_diagnostic error_diagnostic_visible error_diagnostic_selected; do
  require_literal "${group} = { bg = \"NONE\"; };" "$ui"
done

# Language and workflow contracts retained by the refactor.
require 'filetypes = \[' "$web"
require '"php"' "$web"
require 'showExpandedAbbreviation = "always"' "$web"
for server in nil_ls lua_ls bashls dockerls clangd pyright marksman; do
  require "$server" "$repo_root/config/languages/general.nix"
done
for server in ts_ls eslint html cssls jsonls yamlls emmet_language_server tailwindcss; do
  require "$server" "$web"
done
require 'phpactor\.enable' "$repo_root/config/languages/specialized.nix"
require 'postgres_lsp\.enable' "$repo_root/config/languages/specialized.nix"
require 'lemminx\.enable' "$repo_root/config/languages/specialized.nix"
require 'plugins\.jdtls' "$repo_root/config/languages/java.nix"
require 'jdtLanguageServerPackage = pkgs\.jdt-language-server' "$repo_root/config/languages/java.nix"
require 'jdtls' "$repo_root/config/languages/java.nix"
require 'JDTLS_JVM_ARGS' "$repo_root/config/languages/java.nix"
require 'jdt\.ls\.lombokSupport\.enabled' "$repo_root/config/languages/java.nix"
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
require 'angularls = \{' "$web"
require 'rootMarkers = \[ "angular\.json" "project\.json" "nx\.json" \]' "$web"
require 'htmlangular' "$web"
require 'xml' "$repo_root/config/plugins/core.nix"
require 'language\.register, "xml", \{ "svg" \}' "$repo_root/config/plugins/core.nix"
require 'vim\.treesitter\.start, args\.buf, "xml"' "$repo_root/config/plugins/core.nix"

# Validate every embedded Lua block with the system compiler when available.
if command -v luac5.4 >/dev/null 2>&1; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  index=0
  for file in "$ui" "$statusline" "$theme" "$repo_root/config/plugins/completion.nix" "$vault"; do
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
