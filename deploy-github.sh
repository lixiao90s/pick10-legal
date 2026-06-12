#!/usr/bin/env bash
# Pick10 website — one-command update, push & deploy
# Usage:
#   ./deploy-github.sh                  # auto commit + push + verify
#   ./deploy-github.sh "your message"     # custom commit message
#   ./deploy-github.sh --redeploy         # force Cloudflare rebuild (empty commit)
set -euo pipefail

cd "$(dirname "$0")"

REPO_SSH="git@github.com:lixiao90s/pick10-legal.git"
REPO_HTTPS="https://github.com/lixiao90s/pick10-legal.git"
BRANCH="main"
SITE="https://pick10.lx06.com"
APP_STORE="https://apps.apple.com/us/app/pick10/id6776469249"
FORCE_REDEPLOY=0
COMMIT_MSG=""

for arg in "$@"; do
  case "$arg" in
    --redeploy|-r) FORCE_REDEPLOY=1 ;;
    *) COMMIT_MSG="$arg" ;;
  esac
done

[[ -z "$COMMIT_MSG" ]] && COMMIT_MSG="Update website $(date '+%Y-%m-%d %H:%M')"

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

do_push() {
  info "Pushing to GitHub ($BRANCH)..."
  if push_ssh 2>/dev/null; then
    ok "Pushed via SSH"
  elif push_https 2>/dev/null; then
    ok "Pushed via HTTPS"
  else
    fail "Push failed. Check SSH key or network/proxy."
  fi
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
  warn "Site not verified yet. Check Cloudflare Dashboard → pick10-legal → Deployments."
  return 1
}

print_urls() {
  echo ""
  ok "Deploy complete!"
  echo "  Home:    $SITE/"
  echo "  Privacy: $SITE/privacy"
  echo "  Support: $SITE/support"
  echo "  Terms:   $SITE/terms.html"
  echo "  Legal:   $SITE/legal.html"
  echo "  AdMob:   $SITE/app-ads.txt"
  echo "  Store:   $APP_STORE"
}

# --- main ---
info "Pick10 website deploy"

if ! git rev-parse --git-dir &>/dev/null; then
  fail "Not a git repository. Run from pick10-legal folder."
fi

LAST_COMMIT="$(git log -1 --format='%h %s (%cr)')"
info "Latest commit: $LAST_COMMIT"

git add -A

if git diff --cached --quiet; then
  if [[ "$FORCE_REDEPLOY" -eq 1 ]]; then
    warn "No file changes — creating empty commit to trigger Cloudflare redeploy."
    git commit --allow-empty -m "$COMMIT_MSG (redeploy)"
    do_push
    echo ""
    verify_deploy "$SITE/" || true
    verify_deploy "$SITE/privacy" || true
    print_urls
    exit 0
  fi

  ok "No changes to deploy — local files already committed and pushed."
  info "This is normal if you haven't edited any files since last deploy."
  echo ""
  info "Tips:"
  echo "  • Edit HTML/CSS in pick10-legal/, then run ./deploy-github.sh again"
  echo "  • Force Cloudflare rebuild: ./deploy-github.sh --redeploy"
  echo ""
  info "Checking live site..."
  verify_deploy "$SITE/" || true
  verify_deploy "$SITE/privacy" || true
  print_urls
  exit 0
fi

info "Commit message: $COMMIT_MSG"
info "Changes to deploy:"
git diff --cached --stat

git commit -m "$COMMIT_MSG"
do_push

echo ""
verify_deploy "$SITE/" || true
verify_deploy "$SITE/privacy" || true
print_urls
