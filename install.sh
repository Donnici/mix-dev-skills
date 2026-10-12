#!/usr/bin/env bash
# Install the mix-* skills by copying them into an agent's skills directory.
#
#   ./install.sh                     # user scope: ~/.claude/skills
#   ./install.sh --project           # this repo only: ./.claude/skills
#   ./install.sh --target DIR        # any agent, e.g. ~/.codex/skills or ./.agents/skills
#   ./install.sh --uninstall [...]   # remove mix-* skills from the chosen scope
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
dest="$HOME/.claude/skills"
uninstall=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) dest="$PWD/.claude/skills" ;;
    --target) dest="${2:?--target needs a directory}"; shift ;;
    --uninstall) uninstall=true ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

[[ -d "$src" ]] || { echo "skills/ not found next to install.sh" >&2; exit 1; }
mkdir -p "$dest"

for skill in "$src"/mix-*/; do
  name="$(basename "$skill")"
  rm -rf "${dest:?}/$name"
  if $uninstall; then
    echo "removed  $name"
  else
    cp -R "$skill" "$dest/$name"
    echo "installed $name → $dest/$name"
  fi
done

$uninstall || echo "Done. Restart your agent session, then run /mix-setup in each repo."
