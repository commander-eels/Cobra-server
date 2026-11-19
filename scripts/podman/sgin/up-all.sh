#!/usr/bin/env bash
# Starts (or, with UPDATE=1, updates) every app on the SGIN, in order. Run as podsvc.
# Skips the radio unless radio.liq is in place.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# navidrome-talk and navidrome-archives are retired (2026-11-18): Talk Radio & Comedy and The Archives are
# Audiobookshelf libraries now. Their scripts and data stay, so ./navidrome-talk.sh brings one back if wanted.
# Do not stop those two containers until 90-verify-gate.sh reports the Audiobookshelf library walls are clean.
for s in jellyfin ersatztv navidrome audiobookshelf kavita romm; do
  bash "$here/$s.sh"
  echo
done
liq=${COBRA_DATA:-/srv/stream}/radio/radio.liq
if [ -r "$liq" ]; then bash "$here/radio.sh"; else echo "==> skipping the radio (no $liq yet, part 8)"; fi
podman ps --pod --format 'table {{.Names}}\t{{.Status}}\t{{.PodName}}'
