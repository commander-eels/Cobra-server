# Three walled Kavitas, and retiring Calibre-Web

The owner's call (2026-11-21): e-books leave Calibre-Web Automated (CWA) for Kavita, because its interface is simpler. There are exactly three walls, one Kavita each:

| Instance | Port | Sees only | Libraries |
|---|---|---|---|
| `kavita` (Comics) | 5000, stream pod | `dock1a/comics` | Comics |
| `kavita-books` (Books) | 5001, pod `kavita-books` | the folders listed in `~/.config/cobra/kavita-books.sections`, all under `dock1a/books` | one per bookstore section, shelved by author inside |
| `kavita-rpg` (RPG Vault) | 5002, pod `kavita-rpg` | `dock1a/books/RPG Books` | RPG Vault |

Each instance has its own accounts, sign-in and database, and mounts only its own folders **read-only**. An instance can't show a book it can't see, and no Kavita can move, rename or delete a file. Talk Radio & Comedy Club and The Archives already have walls of their own (`navidrome-talk.sh`, `navidrome-archives.sh`), so nothing changes for them here.

The order matters. Calibre-Web still serves `books.songofeo.com` and the website's Library Bay (it reads CWA's OPDS catalog, `web/app/eo-api.js` in Project-Eo). So Kavita Books goes up first, the gate and the website move to it, and only then is CWA removed.

Every command runs as podsvc on the SGIN unless it says eels:

```bash
ssh eels@10.6.9.20
sudo machinectl shell podsvc@          # a real login session; sudo su / sudo -u don't create one
cd ~/cobra-server/scripts/podman/sgin  # with this branch pulled
```

---

## 1. Open ports 5001 and 5002 (as eels)

Kavita has its own login (it doesn't trust a header the way Calibre-Web does), so the two new ports join the same LAN + WireGuard list as Comics' 5000.

```bash
# Adds 5001 and 5002 right after 5000 in the LAN/WireGuard rule; the file is backed up first.
sudo cp -a /etc/nftables.conf /etc/nftables.conf.bak-$(date +%F)
sudo sed -i 's/ 5000, / 5000, 5001, 5002, /' /etc/nftables.conf
sudo nft -c -f /etc/nftables.conf && sudo systemctl reload nftables   # -c checks the file before it's loaded
sudo nft list ruleset | grep -o 'dport {[^}]*}'                       # should now list 5000, 5001, 5002
```

## 2. Move the RPG Vault into its own Kavita

Right now the RPG Vault is a library inside the comics Kavita. This copies comics' settings into a new, empty instance, so the accounts and everyone's RPG reading progress come along. Comics is stopped for a few seconds during the copy.

```bash
COPY_FROM_COMICS=1 ./kavita.sh rpg     # makes pod kavita-rpg on :5002 and copies comics' settings (not its cover cache or logs)
```

Then in a browser:

1. `http://10.6.9.20:5002` (RPG): Admin → Libraries → delete **Comics**. This instance can't see the comics anyway, and deleting a library only drops it from this database. Keep **RPG Vault**.
2. `http://10.6.9.20:5000` (Comics): Admin → Libraries → delete **RPG Vault**.

Then narrow Comics to its own folder:

```bash
./kavita.sh comics     # refuses, and lists them, if Comics still has a library outside dock1a/comics
```

## 3. Start Books, one library per bookstore section

```bash
./kavita.sh books      # first run: writes ~/.config/cobra/kavita-books.sections and stops
nano ~/.config/cobra/kavita-books.sections   # one folder per line; delete any Books shouldn't see; # = comment
./kavita.sh books      # starts pod kavita-books on :5001 with exactly those folders, read-only
```

`RPG Books` is never put in the list, and the script refuses it if you add it. A folder created later stays invisible until you add its line and run the script again. That's the wall working.

In `http://10.6.9.20:5001`: the first visit creates the admin. Then Admin → Libraries → Add, once per section. The script prints each name and folder. Use type **Book**, which covers EPUB and PDF. Inside a section, filter or sort by **Writers** to browse by author.

Kavita reads each EPUB's embedded title and author. PDFs fall back to the file and folder names. Fix a book by hand with ⋯ → Edit. The edits live in Kavita's database, and the files are never touched.

## 4. Point the gate and the website at Books (Project-Eo, separate change)

This step happens in Project-Eo, not here. It's needed before CWA can go:

- The gate: `books.songofeo.com` → `http://10.6.9.20:5001` instead of `:8083` (`10-gate-sso.sh`, nginx). Drop the `ebooks.` alias, or point it at Books as well.
- The website's Library Bay: read Kavita Books' OPDS feed instead of CWA's (`web/app/eo-api.js`; it already reads Kavita's OPDS for Comics and the RPG Vault).
- The account gate (`eo_account.py`): it creates people in "Kavita" and "Calibre-Web". That becomes the three Kavitas, and its Library card should give Kavita Books' OPDS address.
- The health check, nightly backups and verify scripts (`fixlib.sh`, `40-nightly-backups.sh`, `90-verify-gate.sh`, the surveys): swap `calibre-web :8083` for `kavita-books :5001` and `kavita-rpg :5002`.

## 5. Remove Calibre-Web Automated (deletes things: run only once you've said yes to this list)

From Project-Eo `home/cobra-setup/20-sgin-calibre-web.sh`, CWA is exactly these pieces:

| What | Where |
|---|---|
| Container | `calibre-web` (image `docker.io/crocodilestick/calibre-web-automated`) |
| Quadlet file, if it was set up that way | `~/.config/containers/systemd/calibre-web.container` |
| Settings, users, shelves, read marks | `/srv/stream/calibre-web` (`app.db`) |
| Its library: copies of your books plus `metadata.db` | `/srv/storage/disks/dock1a/calibre-library` |
| Its drop box | `/srv/storage/disks/dock1a/calibre-ingest` |
| Firewall line (as eels) | `ip saddr 10.6.9.10 tcp dport 8083 accept` in `/etc/nftables.conf` |
| Personal-state snapshots | the `calibre-web` entry in `scripts/podman/state.sh` (removed in a later commit, once CWA is gone) |

`dock1a/books` itself is not on this list and is never written to.

### 5a. Check what's there and that it matches the list (read-only)

```bash
podman ps -a --format '{{.Names}}  {{.Image}}  {{.Status}}' | grep -i calibre
ls -l ~/.config/containers/systemd/ | grep -i calibre
podman inspect calibre-web --format '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{"\n"}}{{end}}'   # should be the three folders above
du -sh /srv/stream/calibre-web /srv/storage/disks/dock1a/calibre-library /srv/storage/disks/dock1a/calibre-ingest
```

### 5b. Make sure CWA doesn't hold the only copy of any book (read-only)

Step 20 only ever *copied* books in from `dock1a/books`. But anything dropped straight into `calibre-ingest` was moved into CWA's library and exists nowhere else. This compares by content, because Calibre renames files to `Title - Author.ext`:

```bash
# Fingerprints of every book file in your folders and in CWA's library (reads only; slow on a big drive).
find /srv/storage/disks/dock1a/books -type f -print0 | xargs -0 sha1sum | awk '{print $1}' | sort -u > /tmp/books.sha1
find /srv/storage/disks/dock1a/calibre-library -type f \( -iname '*.epub' -o -iname '*.pdf' -o -iname '*.mobi' -o -iname '*.azw3' -o -iname '*.cbz' \) -print0 \
  | xargs -0 sha1sum | sort -k1,1 > /tmp/cwa.sha1
# Prints the books that exist ONLY inside CWA. Nothing printed = removing CWA's library loses no book.
join -v 1 /tmp/cwa.sha1 /tmp/books.sha1 | cut -d' ' -f2-
```

If anything prints, it stays in the backup from 5c. You can copy it into a section folder yourself whenever you like.

### 5c. Back up all of CWA (writes one folder; deletes nothing)

```bash
podman stop calibre-web            # Quadlet: systemctl --user stop calibre-web. Closes app.db and metadata.db cleanly.
BK=/srv/storage/disks/dock1a/backups/calibre-web-final-$(date +%F-%H%M)
mkdir -p "$BK"
podman inspect calibre-web > "$BK/container-inspect.json"                 # how to rebuild it exactly, if ever
cp -a ~/.config/containers/systemd/calibre-web.container "$BK/" 2>/dev/null || true
podman unshare tar -C /srv/stream -czf "$BK/config.tgz" calibre-web        # settings, users, shelves (unshare: reads sub-UID files)
podman unshare tar -C /srv/storage/disks/dock1a -cf "$BK/library.tar" calibre-library calibre-ingest   # books are compressed already
ls -lh "$BK"                                                              # four non-empty files
tar -tf "$BK/library.tar" | grep -c 'metadata.db$'                         # prints 1
```

The archive uses about as much space as `du` showed in 5a. Keep it until Books has worked well for a few weeks, then delete it yourself.

### 5d. Remove it (deletes; only on your yes)

```bash
# The Quadlet file first (if 5a showed one), so systemd doesn't bring the container back.
rm -f ~/.config/containers/systemd/calibre-web.container && systemctl --user daemon-reload
podman rm calibre-web                                       # the container (stopped in 5c)
podman rmi docker.io/crocodilestick/calibre-web-automated   # its image, about 400 MB
# Its three folders, and nothing else. Each path is written out in full on purpose: no variables, no wildcards.
podman unshare rm -rf /srv/stream/calibre-web
podman unshare rm -rf /srv/storage/disks/dock1a/calibre-library
podman unshare rm -rf /srv/storage/disks/dock1a/calibre-ingest
ls /srv/storage/disks/dock1a/            # books, comics, ... still there; calibre-library and calibre-ingest gone
```

Then, as eels, close 8083:

```bash
sudo cp -a /etc/nftables.conf /etc/nftables.conf.bak-$(date +%F)
sudo sed -i '/tcp dport 8083 accept/d' /etc/nftables.conf     # deletes only the gate-only 8083 line
sudo nft -c -f /etc/nftables.conf && sudo systemctl reload nftables
```

Undo, any time before you delete `$BK`: untar `config.tgz` into `/srv/stream` and `library.tar` into `dock1a`, put the Quadlet file back (or re-run Project-Eo step 20), and restore the 8083 line from the `.bak` file.
