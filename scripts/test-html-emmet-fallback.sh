#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

python3 - "$repo_root/config/plugins/completion.nix" "$tmp_dir/completion.lua" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text()
start = source.index("extraConfigLua = ''") + len("extraConfigLua = ''")
end = source.index("'';", start)
Path(sys.argv[2]).write_text(source[start:end])
PY

cat > "$tmp_dir/harness.lua" <<'LUA'
local current_line = "!"
local cursor = { 1, 1 }
local replaced_lines
local captured_tab

vim = {
  bo = { filetype = "html" },
  api = {
    nvim_replace_termcodes = function(value) return value end,
    nvim_feedkeys = function() error("fallback indentation should not run") end,
    nvim_win_get_cursor = function() return cursor end,
    nvim_get_current_line = function() return current_line end,
    nvim_buf_set_lines = function(_, _, _, _, lines) replaced_lines = lines end,
    nvim_win_set_cursor = function(_, value) cursor = value end,
  },
  keymap = {
    set = function(_, key, callback)
      if key == "<Tab>" then captured_tab = callback end
    end,
  },
}

dofile(arg[1])
assert(captured_tab, "completion module did not register Tab")
captured_tab()
assert(replaced_lines and replaced_lines[1] == "<!DOCTYPE html>", "standalone ! did not expand")
assert(replaced_lines[#replaced_lines] == "</html>", "HTML skeleton is incomplete")
assert(cursor[1] == 8, "cursor was not placed inside the generated body")
print("HTML ! expansion contract: OK")
LUA

nvim --headless -u NONE -l "$tmp_dir/harness.lua" "$tmp_dir/completion.lua" 2>&1 | tail -1
