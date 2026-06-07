#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/lixiao90s/pick10-legal.git}"
BRANCH="${2:-main}"

cd "$(dirname "$0")"

if ! git remote get-url origin &>/dev/null; then
  git remote add origin "$REPO_URL"
  echo "Added remote: $REPO_URL"
else
  git remote set-url origin "$REPO_URL"
  echo "Updated remote: $REPO_URL"
fi

echo "Pushing branch $BRANCH to origin..."
git push -u origin "$BRANCH"

echo ""
echo "Done. Next: Cloudflare Dashboard → Workers & Pages → pick10-legal → Custom domains → pick10.lx06.com"
