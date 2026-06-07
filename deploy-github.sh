#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/lixiao90s/pick10-legal.git}"
BRANCH="${2:-main}"
USE_SSH="${USE_SSH:-0}"

cd "$(dirname "$0")"

if [[ "$USE_SSH" == "1" ]] || [[ "$REPO_URL" == git@* ]]; then
  if [[ "$REPO_URL" == https://* ]]; then
    REPO_URL="$(echo "$REPO_URL" | sed -E 's#https://github.com/(.+)\.git#git@github.com:\1.git#')"
  fi
  mkdir -p "$HOME/.ssh"
  if ! grep -q '^github.com ' "$HOME/.ssh/known_hosts" 2>/dev/null; then
    echo "Adding github.com to ~/.ssh/known_hosts ..."
    ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts"
  fi
fi

if ! git remote get-url origin &>/dev/null; then
  git remote add origin "$REPO_URL"
  echo "Added remote: $REPO_URL"
else
  git remote set-url origin "$REPO_URL"
  echo "Updated remote: $REPO_URL"
fi

echo "Pushing branch $BRANCH to origin..."

push_with_https() {
  git -c http.version=HTTP/1.1 push -u origin "$BRANCH"
}

push_with_ssh() {
  local ssh_url
  ssh_url="$(git remote get-url origin | sed -E 's#https://github.com/(.+)\.git#git@github.com:\1.git#')"
  git remote set-url origin "$ssh_url"
  mkdir -p "$HOME/.ssh"
  if ! grep -q '^github.com ' "$HOME/.ssh/known_hosts" 2>/dev/null; then
    echo "Adding github.com to ~/.ssh/known_hosts ..."
    ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts"
  fi
  git push -u origin "$BRANCH"
}

if [[ "$USE_SSH" == "1" ]] || [[ "$REPO_URL" == git@* ]]; then
  push_with_ssh
elif ! push_with_https; then
  echo ""
  echo "HTTPS push failed. Retrying with SSH..."
  push_with_ssh
fi

echo ""
echo "Done. Next: Cloudflare Dashboard -> Workers & Pages -> pick10-legal -> Custom domains -> pick10.lx06.com"
