#!/usr/bin/env bash
# The Code Home: Forgejo 15 LTS, a self-hosted git site for the Formidable Flow, DE and Babelforms repos.
# http://10.6.9.20:3000 on the LAN and WireGuard (public: code.songofeo.com, behind the gate's sign-in + TOTP).
# git over SSH: ssh://git@10.6.9.20:2222/<owner>/<repo>.git (LAN and WireGuard only, never a public port).
# Run as podsvc on the SGIN:  ./forgejo.sh        Runbook: docs/code-home/README.md
#
# GitHub stays the workbench (Claude and Grok work there). Forgejo keeps a pull mirror of each repo and
# refreshes it every hour, so every repo also lives on this hardware. Mirrors are added once in the web page.
#
# Its data lives on the Seagate vault, NOT on the SGIN's SSD: $CODE_DATA (default /srv/storage/vault/code),
# a folder eels creates once and gives to podsvc (runbook step 2). The script never deletes or empties it.
# Nightly backup: ./forgejo-backup.sh (a Forgejo dump copied to dock1a/backups/code, 14 kept).
#
# Its own pod "code", because Forgejo's image runs as uid 1000 inside and needs a keep-id user namespace,
# which is set per pod. podsvc then owns every file on the vault, so a backup or a restore needs no sudo.
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib.sh
. "$here/../lib.sh"

# 15 = the 15.x LTS line (supported until 15 July 2027). data.forgejo.org is Forgejo's own mirror of codeberg.org.
IMAGE=${FORGEJO_IMAGE:-codeberg.org/forgejo/forgejo:15-rootless}
NAME=forgejo
POD=code
HTTP_PORT=3000
SSH_PORT=2222
CODE_DATA=${CODE_DATA:-/srv/storage/vault/code}
VAULT=$(dirname "$CODE_DATA")
PUBLIC_NAME=${CODE_NAME:-code.songofeo.com}
LAN_IP=${CODE_LAN_IP:-10.6.9.20}
GATE_IP=${CODE_GATE_IP:-10.6.9.10}

preflight

# The vault must be the mounted Seagate, not an empty folder on the SSD (part 3.4).
mountpoint -q "$VAULT" || die "$VAULT isn't mounted. Plug in the Seagate and check: findmnt $VAULT (part 3.4)"
[ -d "$CODE_DATA" ] || die "$CODE_DATA doesn't exist yet. As eels: sudo mkdir $CODE_DATA && sudo chown podsvc: $CODE_DATA (runbook step 2)"
[ -w "$CODE_DATA" ] || die "$(id -un) can't write to $CODE_DATA. As eels: sudo chown podsvc: $CODE_DATA (runbook step 2)"
ensure_dir "$CODE_DATA/data" "$CODE_DATA/config"

# The pod. keep-id maps podsvc to the image's uid 1000, so files on the vault belong to podsvc.
no_quadlet "$POD.pod"
if podman pod exists "$POD" && [ "${RECREATE_POD:-0}" = 1 ]; then
  say "RECREATE_POD=1: removing pod $POD (the data on the vault stays)"
  podman pod rm -f "$POD" >/dev/null
fi
if ! podman pod exists "$POD"; then
  say "creating pod $POD (ports: $HTTP_PORT web, $SSH_PORT git over SSH)"
  podman pod create --name "$POD" --infra-name "$POD-infra" \
    --userns keep-id:uid=1000,gid=1000 \
    --publish "$HTTP_PORT:3000" --publish "$SSH_PORT:2222" >/dev/null
fi

# Made once and never changed: the key that encrypts stored secrets (mirror tokens, 2FA) in Forgejo's database.
# Lose it and the saved GitHub token and the TOTP setup stop working, so the backup script saves it too.
ensure_secret forgejo-secret-key "$(random_hex 32)"

# Every setting is an app.ini value: FORGEJO__<section>__<KEY>. The image writes them into app.ini at each start.
run_container "$NAME" "$POD" "$IMAGE" \
  --secret forgejo-secret-key,type=env,target=FORGEJO__security__SECRET_KEY \
  -e FORGEJO____APP_NAME="Code Home" \
  -e FORGEJO____RUN_MODE=prod \
  -e FORGEJO__security__INSTALL_LOCK=true \
  -e FORGEJO__security__REVERSE_PROXY_TRUSTED_PROXIES="$GATE_IP/32" \
  -e FORGEJO__security__LOGIN_REMEMBER_DAYS=7 \
  -e FORGEJO__server__DOMAIN="$PUBLIC_NAME" \
  -e FORGEJO__server__ROOT_URL="https://$PUBLIC_NAME/" \
  -e FORGEJO__server__HTTP_PORT=3000 \
  -e FORGEJO__server__START_SSH_SERVER=true \
  -e FORGEJO__server__SSH_DOMAIN="$LAN_IP" \
  -e FORGEJO__server__SSH_PORT="$SSH_PORT" \
  -e FORGEJO__server__SSH_LISTEN_PORT=2222 \
  -e FORGEJO__server__LFS_START_SERVER=true \
  -e FORGEJO__server__OFFLINE_MODE=true \
  -e FORGEJO__database__DB_TYPE=sqlite3 \
  -e FORGEJO__service__DISABLE_REGISTRATION=true \
  -e FORGEJO__service__REQUIRE_SIGNIN_VIEW=true \
  -e FORGEJO__service__DEFAULT_KEEP_EMAIL_PRIVATE=true \
  -e FORGEJO__service__ENABLE_NOTIFY_MAIL=false \
  -e FORGEJO__openid__ENABLE_OPENID_SIGNIN=false \
  -e FORGEJO__openid__ENABLE_OPENID_SIGNUP=false \
  -e FORGEJO__mailer__ENABLED=false \
  -e FORGEJO__session__COOKIE_SECURE=true \
  -e FORGEJO__repository__DEFAULT_PRIVATE=private \
  -e FORGEJO__repository__FORCE_PRIVATE=true \
  -e FORGEJO__mirror__DEFAULT_INTERVAL=1h \
  -e FORGEJO__migrations__ALLOWED_DOMAINS="github.com,*.github.com,*.githubusercontent.com" \
  -e FORGEJO__other__SHOW_FOOTER_VERSION=false \
  -v "$CODE_DATA/data:/var/lib/gitea:Z" \
  -v "$CODE_DATA/config:/etc/gitea:Z"

wait_port "$HTTP_PORT" 90 || warn "$NAME isn't answering on :$HTTP_PORT yet; check podman logs $NAME"

# The admin account, once. Its first password is printed here a single time and must be changed at first login.
ADMIN=${CODE_ADMIN:-eels}
if podman exec "$NAME" forgejo admin user list --admin 2>/dev/null | awk 'NR>1 {print $2}' | grep -qx "$ADMIN"; then
  say "admin $ADMIN already exists (nothing changed)"
else
  say "creating admin $ADMIN (write down the password printed below; you change it at first login)"
  podman exec "$NAME" forgejo admin user create --admin --username "$ADMIN" \
    --email "${CODE_ADMIN_EMAIL:-$ADMIN@$PUBLIC_NAME}" --random-password --must-change-password
fi

done_msg "$NAME" "http://$LAN_IP:$HTTP_PORT"
echo "    public:  https://$PUBLIC_NAME (after the gate steps)    git: ssh://git@$LAN_IP:$SSH_PORT/<owner>/<repo>.git"
echo "    data:    $CODE_DATA on the vault    backup: ./forgejo-backup.sh"
