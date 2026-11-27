#!/usr/bin/env bash
# Installs the Cobra Series Filler plugin into the SGIN's Jellyfin and restarts Jellyfin.
# Run on the SGIN as eels:   sudo bash /tmp/series-filler/install-series-filler.sh
# Show the plugin's recent log lines:   sudo bash /tmp/series-filler/install-series-filler.sh --log
# Never overwrites: if a different copy is already installed it stops and says so.
set -euo pipefail

VERSION=1.0.0.0
DLL=Jellyfin.Plugin.CobraSeriesFiller.dll
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PLUGINS=${JELLYFIN_PLUGINS:-/srv/stream/jellyfin/config/plugins}
DEST=$PLUGINS/CobraSeriesFiller_$VERSION
FILLER=${FILLER_DIR:-/srv/storage/disks/wd1/filler}
SVC=podsvc

green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red() { printf '\033[31m%s\033[0m\n' "$*" >&2; }
die() { red "$*"; exit 1; }

as_podsvc() { machinectl -q shell "$SVC@" /usr/bin/env "$@"; }

[ "$(id -u)" -eq 0 ] || die "Run it with sudo:  sudo bash $0"

if [ "${1:-}" = --log ]; then
  as_podsvc podman logs --since 30m jellyfin 2>&1 | grep -E 'CobraSeriesFiller|Cobra Series Filler' | tail -n 20 || yellow "No Cobra Series Filler lines in the last 30 minutes."
  exit 0
fi

[ -f "$HERE/$DLL" ] || die "Can't find $DLL next to this script ($HERE). Copy the whole series-filler folder (step 2.4)."
[ -d "$PLUGINS" ] || die "Can't find Jellyfin's plugins folder $PLUGINS. Is Jellyfin set up on this machine (part 3.8)?"

# Never overwrite another copy or version.
for other in "$PLUGINS"/CobraSeriesFiller_*; do
  [ -e "$other" ] || continue
  if [ "$other" = "$DEST" ] && cmp -s "$HERE/$DLL" "$DEST/$DLL"; then
    green "This exact version is already installed in $DEST. Nothing copied."
    exit 0
  fi
  die "Another copy is already installed: $other. Nothing was changed. Send this line to Claude."
done

owner=$(stat -c %u:%g "$PLUGINS")
mkdir "$DEST"
cp "$HERE/$DLL" "$DEST/"
chown -R "$owner" "$DEST"
green "Copied $DLL to $DEST"

if [ -d "$FILLER" ]; then
  n=$(find "$FILLER" -type f \( -iname '*.mp4' -o -iname '*.m4v' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.avi' -o -iname '*.webm' -o -iname '*.ts' -o -iname '*.m2ts' -o -iname '*.wmv' -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.flv' -o -iname '*.3gp' \) -not -path '*/.*' | wc -l)
  green "Found $n video clips in $FILLER (subfolders included)"
  [ "$n" -gt 0 ] || yellow "The filler folder has no videos yet. Add some before testing."
else
  yellow "No folder $FILLER. Check the folder name before step 3.4."
fi

yellow "Restarting Jellyfin (about a minute)..."
as_podsvc podman restart jellyfin >/dev/null

for _ in $(seq 1 90); do
  if (exec 3<>/dev/tcp/127.0.0.1/8096) 2>/dev/null; then break; fi
  sleep 1
done
sleep 5

if as_podsvc podman logs --since 5m jellyfin 2>&1 | grep -q 'Loaded plugin: Cobra Series Filler'; then
  green "Installed. Jellyfin loaded Cobra Series Filler $VERSION. Next: README step 3.2"
else
  yellow "Jellyfin restarted, but its log doesn't show the plugin loading yet. Wait a minute, then do step 3.2. If the card is missing, see Help 3.1."
fi
