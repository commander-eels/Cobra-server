#!/usr/bin/env bash
# Kavita, as three walled-off instances. Each one has its own users, its own sign-in and its own database,
# and is given ONLY its own folders, so it can't see (or leak) the others' books:
#
#   ./kavita.sh comics   comics, manga, graphic novels   http://10.6.9.20:5000   comics.songofeo.com
#   ./kavita.sh books    the Library's bookstore sections http://10.6.9.20:5001  (books., once the gate points there)
#   ./kavita.sh rpg      the RPG Vault (PDF rulebooks)    http://10.6.9.20:5002  (the RPG Vault Bay)
#
# Run as podsvc on the SGIN. No argument = comics, the instance this script always ran.
# Every folder is mounted read-only: Kavita keeps metadata edits, covers and reading progress in its own
# database, never in the book files, and can't move, rename or delete anything on the drives.
#
# The folders come from ../lib.sh: COMICS_DIR, BOOKS_DIR, RPG_DIR. The bookstore sections are the folders
# listed in ~/.config/cobra/kavita-books.sections (one folder name under BOOKS_DIR per line). The first
# ./kavita.sh books writes that file from what's on the drive and stops, so you check it before anything starts.
#
# Moving the RPG Vault out of the comics instance (once): COPY_FROM_COMICS=1 ./kavita.sh rpg
# starts the RPG instance from a copy of comics' settings, so accounts and RPG reading progress carry over.
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib.sh
. "$here/../lib.sh"
# shellcheck source=pod.sh
. "$here/pod.sh"

IMAGE=${KAVITA_IMAGE:-docker.io/jvmilazz0/kavita:latest}
INSTANCE=${1:-comics}
SECTIONS_FILE=$COBRA_CONF/kavita-books.sections
COMICS_DATA=$STREAM_DATA/kavita

preflight
need_folders "$COMICS_DIR" "$RPG_DIR"
stream_pod
ensure_dir "$DATA"
keep_personal_state "$NAME"

run_container "$NAME" "$POD" "$IMAGE" \
  -v "$DATA:/kavita/config:Z" \
  "${MOUNTS[@]}"

wait_port 5000 60 || warn "Kavita isn't answering on :5000 yet; check podman logs kavita"
snapshot_personal_state kavita
done_msg kavita http://10.6.9.20:5000
echo "    Once: first visit creates the admin, then Libraries -> add 'Comics' (type Comic) with folder /media/$COMICS_DIR"
echo "    RPG Vault: Libraries -> add 'RPG Vault' (type Book, so PDFs open in the PDF reader) with folder /media/$RPG_DIR."
echo "          One folder per game system (e.g. /media/$RPG_DIR/<Game System>/<Book>.pdf); tick the library per user."
