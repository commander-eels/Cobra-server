#!/usr/bin/env bash
# Start RomM over from its first-run setup wizard (lost admin login, broken database).
# Run as podsvc on the SGIN:  bash ./romm-reset.sh   (guided version: /tmp/cobra-setup/24-sgin-romm-reset.sh)
#
# What it does:
#   1. snapshots RomM's personal state to the vault one last time (part 13), if there is a database
#   2. stops romm and romm-db
#   3. MOVES /srv/stream/romm to /srv/stream/romm.pre-reset-<time>. Nothing is deleted.
#   4. runs SKIP_STATE_RESTORE=1 ./romm.sh, so the old snapshot is NOT put back
#      (without that, romm.sh would restore the old database and the old admin, and the wizard never shows)
#
# What it never touches: the ROMs in /srv/storage/disks/dock1b/roms (the cabinet's nightly copy),
# the vault snapshots, and the podman secrets (a fresh MariaDB simply takes the existing password).
# Undo: podman stop romm romm-db, move the new /srv/stream/romm aside, move the pre-reset folder back, ./romm.sh
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib.sh
. "$here/../lib.sh"
# shellcheck source=pod.sh
. "$here/pod.sh"

DATA=$STREAM_DATA/romm
ROMS=$DISKS/$ROMS_DIR

preflight
no_quadlet romm.container romm-db.container
[ -d "$DATA" ] || die "$DATA doesn't exist, so there is nothing to reset. If an earlier reset stopped half-way, finish it with:
       SKIP_STATE_RESTORE=1 bash $here/romm.sh   (or run 24-sgin-romm-reset.sh)"
case $(readlink -f "$ROMS")/ in
  "$(readlink -f "$DATA")"/*) die "the ROMs folder ($ROMS) is inside $DATA. Not moving it. Fix ROMS_DIR in lib.sh first." ;;
esac

aside=$DATA.pre-reset-$(date +%Y%m%d-%H%M%S)
cat <<TXT

  This resets RomM to its first-run setup wizard.
    moves:     $DATA  ->  $aside   (kept, not deleted)
    untouched: $ROMS (your ROMs), the vault snapshots, the podman secrets
  RomM's users, scan results, covers and in-browser saves start empty. Rescan afterwards.

TXT
if [ "${ROMM_RESET_YES:-0}" != 1 ]; then
  read -r -p "Type RESET to go on: " answer
  [ "$answer" = RESET ] || die "not reset. Nothing changed."
fi

say "last snapshot of the current RomM state (to the vault)"
snapshot_personal_state romm

say "stopping romm and romm-db"
podman stop --ignore romm romm-db >/dev/null

mv "$DATA" "$aside"
say "moved the old RomM data to $aside"

# bash, not ./romm.sh: a copied folder often loses the execute bit (00-copy-to-servers.ps1 doesn't keep it),
# and a "Permission denied" here would leave RomM stopped with its data already moved aside.
SKIP_STATE_RESTORE=1 bash "$here/romm.sh" || die "romm.sh failed after the data was moved aside. Your old data is safe in
       $aside
       Fix what romm.sh printed above, then finish the reset with:  SKIP_STATE_RESTORE=1 bash $here/romm.sh
       (or 24-sgin-romm-reset.sh, which finds this half-done reset by itself)"

cat <<TXT

==> RomM is blank. On the-box, open http://10.6.9.20:8080 : the setup wizard asks for a new admin user.
    Save that username and password in Vaultwarden, then Scan.
    The old data stays in $aside until you remove it yourself.
TXT
