#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ui="$repo_root/config/plugins/ui.nix"
web="$repo_root/config/languages/web.nix"
vault="$repo_root/config/plugins/vault.nix"

fail() {
  printf 'NixVim contract check failed: %s\n' "$1" >&2
  exit 1
}

require() {
  local pattern="$1"
  local file="$2"
  grep -Eq "$pattern" "$file" || fail "missing '$pattern' in ${file#$repo_root/}"
}

forbidden() {
  local pattern="$1"
  local file="$2"
  if grep -Eq "$pattern" "$file"; then
    fail "forbidden '$pattern' in ${file#$repo_root/}"
  fi
}

require 'disabled_filetypes\.statusline = \[[^]]*"snacks_dashboard"' "$ui"
require 'attach_navic = false' "$ui"
require 'icon = "λ"' "$ui"
forbidden '__unkeyed-1 = "filename"' "$ui"
forbidden '__unkeyed-1 = "filetype"' "$ui"
require 'LspAttach' "$ui"
require 'documentSymbolProvider' "$ui"
require 'filetypes = \[' "$web"
require '"php"' "$web"
require 'showExpandedAbbreviation = "always"' "$web"
require 'nil_ls' "$repo_root/config/languages/general.nix"
require 'phpactor\.enable' "$repo_root/config/languages/specialized.nix"
require 'intellij-lsp-plugin' "$repo_root/config/languages/java.nix"
require 'neotest-java' "$repo_root/config/languages/java.nix"
require 'pattern = "\*\.xopp"' "$vault"
require 'silent! qa!' "$vault"
require 'nvim_buf_delete' "$vault"
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
