#!/usr/bin/env bash
# Navidrome, Talk Radio & Comedy Club: its own instance, separate from Music's (its own accounts, stars, playlists and play counts).
# http://10.6.9.20:4534  (public: talk.songofeo.com, comedy.songofeo.com)
# Run as podsvc on the SGIN:  ./navidrome-talk.sh
#
#   Library 1   /media/$COMEDY_DIR   (stand-up albums and talk radio; set in ../lib.sh)
# More libraries for this Bay: Settings -> Libraries -> + (libraries may not overlap).
#
# Same gate trust as navidrome.sh: it believes only the gate's Remote-User header (10.6.9.10), so the
# station's one Authelia sign-in is enough. Authelia's Talk wall (group talk) still decides who may reach talk.songofeo.com.
# If you already started a container named navidrome-talk by hand, run  podman inspect navidrome-talk  and send it to
# Claude first: this script replaces a container with that name (its data folder below is kept).
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib.sh
. "$here/../lib.sh"
# shellcheck source=pod.sh
. "$here/pod.sh"

IMAGE=${NAVIDROME_IMAGE:-docker.io/deluan/navidrome:latest}
NAME=navidrome-talk
PORT=4534
DATA=$STREAM_DATA/$NAME

preflight
need_folders "$COMEDY_DIR"
stream_pod
ensure_dir "$DATA"
keep_personal_state navidrome-talk

run_container "$NAME" "$STREAM_POD" "$IMAGE" \
  -e ND_PORT="$PORT" \
  -e ND_MUSICFOLDER="/media/$COMEDY_DIR" \
  -e ND_SESSIONTIMEOUT=8h \
  -e ND_ENABLEINSIGHTSCOLLECTOR=false \
  -e ND_EXTAUTH_TRUSTEDSOURCES=10.6.9.10/32 \
  -e ND_EXTAUTH_USERHEADER=Remote-User \
  -v "$DATA:/data:Z" \
  -v "$DISKS:/media:ro,rbind"

wait_port "$PORT" 60 || warn "$NAME isn't answering on :$PORT yet; check podman logs $NAME"
snapshot_personal_state navidrome-talk
done_msg "$NAME" "http://10.6.9.20:$PORT"
echo "    Once: the first visit creates its admin (eels, same username as in Authelia's users file)."
echo "    A later account is created when that person loads this Bay's web UI, not from a phone app's /rest/."
echo "    Who may come in: Authelia's Talk wall (group talk) (cobra-setup templates/configuration.yml, step 10)."
