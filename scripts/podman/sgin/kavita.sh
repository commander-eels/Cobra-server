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

# Inside its container Kavita always listens on 5000. A pod is one shared network, so two Kavitas can't sit in
# the same pod. Comics stays in the stream pod as before; books and rpg each get a small pod of their own that
# publishes a different LAN port onto their 5000. (That also avoids re-making the stream pod, which would stop
# every app in it.) nftables must allow 5001 and 5002 from the LAN and WireGuard (manual part 3.7).
case $INSTANCE in
  comics)
    NAME=kavita; DATA=$COMICS_DATA; PORT=5000
    need_folders "$COMICS_DIR"
    stream_pod; POD=$STREAM_POD
    # This instance used to see every drive. If its database still has a library outside the comics folder
    # (the RPG Vault, say), the narrower mount below would hide it, so stop until that library has moved to
    # its own instance and been removed here. ALLOW_NARROW=1 skips the check once you've looked yourself.
    if [ "${ALLOW_NARROW:-0}" != 1 ] && [ -f "$DATA/kavita.db" ]; then
      command -v sqlite3 >/dev/null \
        || die "sqlite3 isn't installed, so I can't check Comics' libraries. In its UI (Admin -> Libraries) check only /media/$COMICS_DIR is left, then: ALLOW_NARROW=1 $0 comics"
      other=$(sqlite3 -readonly "$DATA/kavita.db" "SELECT Path FROM FolderPath WHERE Path NOT LIKE '/media/$COMICS_DIR%';") \
        || die "couldn't read $DATA/kavita.db. In Comics' UI (Admin -> Libraries) check only /media/$COMICS_DIR is left, then: ALLOW_NARROW=1 $0 comics"
      [ -z "$other" ] || die "Comics still has libraries outside /media/$COMICS_DIR:
$(sed 's/^/         /' <<<"$other")
       Move them first (./kavita.sh books / COPY_FROM_COMICS=1 ./kavita.sh rpg), delete them in Comics' Admin -> Libraries
       (that only drops them from Comics' database; the files are read-only and stay), then run this again"
    fi
    # The same path inside as before (/media/<drive>/comics), so the Comics library keeps all its series.
    MOUNTS=(-v "$DISKS/$COMICS_DIR:/media/$COMICS_DIR:ro")
    ;;

  rpg)
    NAME=kavita-rpg; DATA=$STREAM_DATA/kavita-rpg; PORT=5002
    need_folders "$RPG_DIR"
    ensure_pod kavita-rpg "$PORT:5000"; POD=kavita-rpg
    ensure_dir "$DATA"
    if [ "${COPY_FROM_COMICS:-0}" = 1 ]; then
      [ ! -e "$DATA/kavita.db" ] || die "$DATA already has a Kavita database; COPY_FROM_COMICS only starts an empty one. Nothing changed."
      [ -f "$COMICS_DATA/kavita.db" ] || die "no comics database at $COMICS_DATA/kavita.db to copy from"
      say "copying Comics' settings into $DATA (Comics is stopped for the copy so its database is consistent)"
      podman stop kavita >/dev/null
      # podman unshare: some files belong to podsvc's sub-UIDs; inside unshare podsvc can read and copy them all.
      # The cover cache and logs are left out: Kavita rebuilds them.
      if ! podman unshare sh -c 'cd "$1" && tar --exclude=./logs --exclude=./cache -cf - . | tar -C "$2" -xpf -' sh "$COMICS_DATA" "$DATA"; then
        podman start kavita >/dev/null
        die "the copy failed (lines above). Comics is running again and untouched; empty $DATA before trying again"
      fi
      podman start kavita >/dev/null
      COPIED=1
    fi
    # The same path inside as the shared instance used, so a copied RPG Vault library still finds its files.
    MOUNTS=(-v "$DISKS/$RPG_DIR:/media/$RPG_DIR:ro")
    ;;

  books)
    NAME=kavita-books; DATA=$STREAM_DATA/kavita-books; PORT=5001
    need_folders "$BOOKS_DIR"
    # The RPG folder sits inside the books folder; it belongs to ./kavita.sh rpg and never to Books.
    rpg_here=; [ "${RPG_DIR%/*}" = "$BOOKS_DIR" ] && rpg_here=${RPG_DIR##*/}
    if [ ! -s "$SECTIONS_FILE" ]; then
      # First run: list every folder under BOOKS_DIR except the RPG one, and stop so you can check the list.
      # An explicit list is the wall: a folder added later (or one with private files) never shows up by itself.
      find "$DISKS/$BOOKS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort \
        | { grep -vxF "${rpg_here:-//none//}" || true; } > "$SECTIONS_FILE"
      say "wrote $SECTIONS_FILE, the bookstore sections Books will see:"
      sed 's/^/      /' "$SECTIONS_FILE"
      die "check that list (delete any line Books shouldn't see; # starts a comment), then run ./kavita.sh books again"
    fi
    ensure_pod kavita-books "$PORT:5000"; POD=kavita-books
    MOUNTS=(); SECTIONS=()
    while IFS= read -r s || [ -n "$s" ]; do
      s=${s%%#*}; s=${s%"${s##*[![:space:]]}"}; [ -n "$s" ] || continue   # skip blank lines and # comments
      case $s in */*|.|..|*:*) die "'$s' in $SECTIONS_FILE: one plain folder name per line (no slashes or colons)" ;; esac
      [ "$s" != "$rpg_here" ] || die "'$s' is the RPG Vault's folder; it belongs to ./kavita.sh rpg. Remove it from $SECTIONS_FILE"
      [ -d "$DISKS/$BOOKS_DIR/$s" ] || die "$DISKS/$BOOKS_DIR/$s doesn't exist (listed in $SECTIONS_FILE)"
      MOUNTS+=(-v "$DISKS/$BOOKS_DIR/$s:/media/$BOOKS_DIR/$s:ro")
      SECTIONS+=("$s")
    done < "$SECTIONS_FILE"
    [ ${#SECTIONS[@]} -gt 0 ] || die "$SECTIONS_FILE lists no sections"
    ;;

  *) die "usage: $0 [comics|books|rpg]" ;;
esac

ensure_dir "$DATA"
keep_personal_state "$NAME"

run_container "$NAME" "$POD" "$IMAGE" \
  -v "$DATA:/kavita/config:Z" \
  "${MOUNTS[@]}"

wait_port "$PORT" 60 || warn "$NAME isn't answering on :$PORT yet; check podman logs $NAME"
snapshot_personal_state "$NAME"
done_msg "$NAME" "http://10.6.9.20:$PORT"
case $INSTANCE in
  comics)
    echo "    Once: first visit creates the admin, then Libraries -> add 'Comics' (type Comic) with folder /media/$COMICS_DIR" ;;
  rpg)
    if [ "${COPIED:-0}" = 1 ]; then
      echo "    Copied from Comics: same accounts, and the RPG Vault library with everyone's progress."
      echo "    Here, delete the Comics library (Admin -> Libraries; it can't see the comics anyway). Keep 'RPG Vault'."
      echo "    Then in Comics (:5000) delete 'RPG Vault', and run ./kavita.sh comics to narrow its folders."
    else
      echo "    Once: first visit creates the admin, then Libraries -> add 'RPG Vault' (type Book, so PDFs open in the PDF reader)"
      echo "          with folder /media/$RPG_DIR. One folder per game system; tick the library per user."
    fi ;;
  books)
    echo "    Once: first visit creates the admin, then Libraries -> Add, one library per bookstore section (type Book):"
    for s in "${SECTIONS[@]}"; do echo "      $s  ->  /media/$BOOKS_DIR/$s"; done
    echo "    Inside a section, filter or sort by Writers to shelve by author."
    echo "    New section later: add its folder name to $SECTIONS_FILE, run ./kavita.sh books again, then add its library." ;;
esac
