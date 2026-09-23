#!/usr/bin/env bash
# Rename template placeholders after "Use this template".
# Usage: ./scripts/bootstrap.sh <app-name> <owner>/<repo>
set -euo pipefail

if [[ $# -ne 2 || ! "$1" =~ ^[a-z][a-z0-9-]{1,40}$ || ! "$2" =~ ^[^/]+/[^/]+$ ]]; then
  echo "usage: $0 <app-name (lowercase, dashes)> <owner>/<repo>" >&2
  exit 1
fi

app="$1"
slug="$2"
owner="${slug%%/*}"
repo="${slug##*/}"

cd "$(git rev-parse --show-toplevel)"

# Portable in-place sed (GNU + BSD/macOS).
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }

git ls-files -z | while IFS= read -r -d '' f; do
  [[ "$f" == scripts/bootstrap.sh ]] && continue
  grep -Iq . "$f" 2>/dev/null || continue # skip binaries
  if grep -qE 'template-app|OWNER/REPO|OWNER/' "$f"; then
    sedi -e "s#template-app-repo#${repo}#g" \
         -e "s#template-app#${app}#g" \
         -e "s#OWNER/REPO#${owner}/${repo}#g" \
         -e "s#@OWNER/#@${owner}/#g" "$f"
    echo "updated: $f"
  fi
done

echo
echo "Done. Next: review 'git diff', then follow README -> Template setup."
