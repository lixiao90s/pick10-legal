#!/usr/bin/env bash
# Pick10 website — one-command update, push & deploy
# Usage:
#   ./deploy-github.sh                  # auto commit + push + verify
#   ./deploy-github.sh "your message"   # custom commit message
set -euo pipefail

cd "$(dirname "$0")"

REPO_SSH="git@github.com:lixiao90s/pick10-legal.git"
REPO_HTTPS="https://github.com/lixiao90s/pick10-legal.git"
BRANCH="main"
SITE="https://pick10.lx06.com"
COMMIT_MSG="${1:-Update website $(date '+%Y-%m-%d %H:%M')}"

info()  { printf '\033[1;34m→\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m!\033[0m %s\n' "$*"; }
fail()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

ensure_ssh() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  if ! grep -q '^github.com ' "$HOME/.ssh/known_hosts" 2>/dev/null; then
    info "Adding github.com to known_hosts..."
    ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
  fi
}

setup_remote() {
  if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$REPO_SSH"
  else
    git remote add origin "$REPO_SSH"
  fi
}

push_ssh() {
  ensure_ssh
  setup_remote
  git push -u origin "$BRANCH"
}

push_https() {
  git remote set-url origin "$REPO_HTTPS"
  git -c http.version=HTTP/1.1 push -u origin "$BRANCH"
}

verify_deploy() {
  local url="$1" max=12 i=0
  info "Waiting for Cloudflare deploy..."
  while [[ $i -lt $max ]]; do
    if curl -sf -o /dev/null --max-time 10 "$url"; then
      ok "Site is live: $url"
      return 0
    fi
    i=$((i + 1))
    sleep 5
  done
  warn "Deploy pushed but site not verified yet. Check Cloudflare Dashboard."
  return 1
}

# --- main ---
info "Pick10 website deploy"
info "Commit message: $COMMIT_MSG"

if ! git rev-parse --git-dir &>/dev/null; then
  fail "Not a git repository. Run from pick10-legal folder."
fi

# Stage all changes
git add -A

if git diff --cached --quiet; then
  ok "No changes to deploy."
  info "Checking live site..."
  verify_deploy "$SITE/" || true
  exit 0
fi

info "Changes to deploy:"
git diff --cached --stat

git commit -m "$COMMIT_MSG"

info "Pushing to GitHub ($BRANCH)..."
if push_ssh 2>/dev/null; then
  ok "Pushed via SSH"
elif push_https 2>/dev/null; then
  ok "Pushed via HTTPS"
else
  fail "Push failed. Check SSH key or network/proxy."
fi

echo ""
verify_deploy "$SITE/" || true
verify_deploy "$SITE/privacy.html" || true

echo ""
ok "Deploy complete!"
echo "  Home:    $SITE/"
echo "  Privacy: $SITE/privacy.html"
echo "  Support: $SITE/support.html"
echo "  Terms:   $SITE/terms.html"
echo "  Legal:   $SITE/legal.html"
