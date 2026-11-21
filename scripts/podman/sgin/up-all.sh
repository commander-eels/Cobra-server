#!/usr/bin/env bash
# Starts (or, with UPDATE=1, updates) every app on the SGIN, in order. Run as podsvc.
# Skips the radio unless radio.liq is in place.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for s in jellyfin ersatztv navidrome navidrome-talk navidrome-archives audiobookshelf; do
  "$here/$s.sh"
  echo
done
# The three walled Kavitas. A Kavita that stops (comics still holding the RPG Vault, books' section list not
# written yet) says why and doesn't stop the rest of the apps.
for k in comics rpg books; do
  if [ "$k" = books ] && [ ! -s "${COBRA_CONF:-$HOME/.config/cobra}/kavita-books.sections" ]; then
    echo "==> skipping Kavita books (no section list yet: run ./kavita.sh books once by hand)"; echo; continue
  fi
  if [ "$k" = rpg ] && [ ! -f "${COBRA_DATA:-/srv/stream}/kavita-rpg/kavita.db" ]; then
    # Started here it would come up empty, and the one-time copy from comics only works into an empty instance.
    echo "==> skipping Kavita rpg (not set up yet: run COPY_FROM_COMICS=1 ./kavita.sh rpg once by hand)"; echo; continue
  fi
  "$here/kavita.sh" "$k" || echo "==> Kavita $k didn't start (reason above); the other apps carry on"
  echo
done
"$here/romm.sh"
echo
liq=${COBRA_DATA:-/srv/stream}/radio/radio.liq
if [ -r "$liq" ]; then bash "$here/radio.sh"; else echo "==> skipping the radio (no $liq yet, part 8)"; fi
podman ps --pod --format 'table {{.Names}}\t{{.Status}}\t{{.PodName}}'
