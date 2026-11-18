#!/usr/bin/env bash
# Starts (or, with UPDATE=1, updates) every app on the SGIN, in order. Run as podsvc.
# Skips the radio unless radio.liq is in place.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for s in jellyfin ersatztv navidrome navidrome-talk navidrome-archives audiobookshelf kavita romm; do
  "$here/$s.sh"
  echo
done
liq=${COBRA_DATA:-/srv/stream}/radio/radio.liq
if [ -r "$liq" ]; then bash "$here/radio.sh"; else echo "==> skipping the radio (no $liq yet, part 8)"; fi
podman ps --pod --format 'table {{.Names}}\t{{.Status}}\t{{.PodName}}'
