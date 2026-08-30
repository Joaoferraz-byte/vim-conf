#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
printf 'dummy xopp\n' > "$tmp_dir/note.xopp"
cat > "$tmp_dir/bin/xournalpp" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > "${XOPP_LOG:?}"
EOF
chmod +x "$tmp_dir/bin/xournalpp"

python3 - "$repo_root/config/plugins/vault.nix" "$tmp_dir/init.lua" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text()
start = source.index("extraConfigLua = ''") + len("extraConfigLua = ''")
end = source.index("'';", start)
Path(sys.argv[2]).write_text(source[start:end])
PY

export PATH="$tmp_dir/bin:$PATH"
export XOPP_LOG="$tmp_dir/xournalpp.log"
set +e
timeout 8s nvim --headless -u "$tmp_dir/init.lua" "$tmp_dir/note.xopp" >/dev/null 2>"$tmp_dir/nvim.log"
status=$?
set -e

[[ "$status" -eq 0 ]] || {
  cat "$tmp_dir/nvim.log" >&2
  printf 'XOPP handler test failed: nvim exited with status %s\n' "$status" >&2
  exit 1
}
[[ -s "$XOPP_LOG" ]] || {
  cat "$tmp_dir/nvim.log" >&2
  printf 'XOPP handler test failed: xournalpp was not launched\n' >&2
  exit 1
}
grep -Fq "$tmp_dir/note.xopp" "$XOPP_LOG" || {
  printf 'XOPP handler test failed: wrong file argument\n' >&2
  exit 1
}

printf 'XOPP external-open contract: OK\n'
