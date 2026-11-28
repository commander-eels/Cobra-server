#!/usr/bin/env bash
# Nightly backup of the Code Home (forgejo.sh): one Forgejo dump (every repo, LFS file, the database and app.ini)
# written on the vault, then copied to a second drive, dock1a/backups/code. Keeps the newest 14 on each drive.
# Run as podsvc on the SGIN:  ./forgejo-backup.sh
# The first run also enables a daily user timer at 03:40 (after the 03:10 personal-state snapshot).
# CODE_NO_TIMER=1 skips the timer. CODE_KEEP=<n> keeps n dumps instead of 14.
#
# The dump holds app.ini, and app.ini holds the secret key that unlocks the saved GitHub token and 2FA.
# So every dump file is made readable by podsvc only (mode 600), also on the Samba-shared dock1a.
# Nothing outside $CODE_DATA/dumps and dock1a/backups/code is ever deleted, and only files named forgejo-*.zip.
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib.sh
. "$here/../lib.sh"

NAME=forgejo
CODE_DATA=${CODE_DATA:-/srv/storage/vault/code}
KEEP=${CODE_KEEP:-14}
STAMP=$(date +%Y%m%d-%H%M%S)
FILE=forgejo-$STAMP.zip

preflight
[ "$(podman inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" = true ] || die "$NAME isn't running; start it with ./forgejo.sh"
need_folders "$BACKUPS_DIR"
COPY_DIR=$DISKS/$BACKUPS_DIR/code
ensure_dir "$CODE_DATA/data/dumps" "$COPY_DIR"

# keep_newest DIR   Deletes all but the newest $KEEP forgejo-*.zip files in DIR (and nothing else).
keep_newest() {
  local dir=$1
  find "$dir" -maxdepth 1 -type f -name 'forgejo-*.zip' -printf '%T@ %p\n' | sort -rn \
    | tail -n +"$((KEEP + 1))" | cut -d' ' -f2- | while IFS= read -r old; do
      rm -f -- "$old" && say "removed old dump $(basename "$old")"
    done
}

say "writing $FILE inside the container (/var/lib/gitea/dumps, on the vault)"
podman exec -w /var/lib/gitea "$NAME" \
  forgejo dump --type zip --file "/var/lib/gitea/dumps/$FILE" --tempdir /var/lib/gitea/dumps
SRC=$CODE_DATA/data/dumps/$FILE
[ -s "$SRC" ] || die "the dump $SRC is missing or empty; check podman logs $NAME"
chmod 600 "$SRC"

# Check the zip reads back before copying it anywhere.
if command -v unzip >/dev/null; then
  unzip -tq "$SRC" >/dev/null || die "$SRC failed its zip test; the older dumps were left alone"
fi

say "copying to $COPY_DIR (second drive)"
cp -- "$SRC" "$COPY_DIR/$FILE.part" && mv -- "$COPY_DIR/$FILE.part" "$COPY_DIR/$FILE"
chmod 600 "$COPY_DIR/$FILE"
cmp -s "$SRC" "$COPY_DIR/$FILE" || die "the copy on dock1a doesn't match the vault's; both were kept"

keep_newest "$CODE_DATA/data/dumps"
keep_newest "$COPY_DIR"
say "backup done: $(du -h "$SRC" | cut -f1) in $SRC and $COPY_DIR/$FILE"

# The daily timer, installed once.
if [ "${CODE_NO_TIMER:-0}" != 1 ]; then
  unit_dir=$HOME/.config/systemd/user
  if [ ! -e "$unit_dir/cobra-code-backup.timer" ]; then
    mkdir -p "$unit_dir"
    cat >"$unit_dir/cobra-code-backup.service" <<EOF
[Unit]
Description=Back up the Code Home (Forgejo dump to the vault and dock1a)

[Service]
Type=oneshot
ExecStart=$here/forgejo-backup.sh
Environment=CODE_NO_TIMER=1
EOF
    cat >"$unit_dir/cobra-code-backup.timer" <<EOF
[Unit]
Description=Daily Code Home backup

[Timer]
OnCalendar=*-*-* 03:40:00
Persistent=true
RandomizedDelaySec=10min

[Install]
WantedBy=timers.target
EOF
    if systemctl --user daemon-reload && systemctl --user enable --now cobra-code-backup.timer; then
      say "daily Code Home backup enabled (03:40, as $(id -un))"
    else
      warn "couldn't enable the timer. From a podsvc login: systemctl --user enable --now cobra-code-backup.timer"
    fi
  fi
fi
