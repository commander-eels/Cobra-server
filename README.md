# cobra-server

Build manual and server code for the Cobra home network, which runs the Song of Eo station (`songofeo.com`) and its apps: a Proxmox/OPNsense gateway on a Latitude, a public gate VM (`cobra-gate`), a Debian media and storage box (the SGIN, `cobra-stream`) and a Windows 11 arcade cabinet on the OptiPlex.

---

## What lives where

| Repository | Owns |
|---|---|
| **this one** (`Cobra-server`) | The build manual, the runbooks, the apps built for this setup (`apps/`), and the **master copy** of the podman scripts (`scripts/podman/`) |
| `commander-eels/Project-Eo` | The website, the numbered gate and SGIN setup steps (`home/cobra-setup/`: Authelia rules, nginx routes, the Multi-Pass, Calibre-Web, RomM, backups, verify), and an identical copy of `scripts/podman/` for its setup bundle |
| `bpm-records/formidable-flow` | The form engine behind the Multi-Pass's one-question-per-screen forms |

Change podman scripts here first, then copy `scripts/podman/` across to Project-Eo's `home/cobra-setup/cobra-server-scripts/podman/`. The two copies matched on 2026-11-18.

---

## Machines

| Host | Address | Role |
|---|---|---|
| `cobra-command` (Dell Latitude 5580) | 10.6.9.2 | Proxmox VE: runs the firewall, Pi-hole #1 and the gate VM |
| `cobra-firewall` (OPNsense, on the Latitude) | 10.6.9.1 | Default gateway, Unbound DNS, WireGuard (10.6.99.0/24) |
| `cobra-pihole-1` (on the Latitude) | 10.6.9.3 | DNS #1 |
| `cobra-gate` (VM on the Latitude) | 10.6.9.10 | The public door (443): nginx, Authelia, the Multi-Pass, forms, eo-art, hiscore, Vaultwarden, Paperless, Homepage, Uptime Kuma |
| `cobra-stream` (the SGIN) | 10.6.9.20 | Media and storage: the `stream` pod (below), Samba, Pi-hole #2, PBS |
| `cobra-arcade` (OptiPlex 7040) | 10.6.9.30 | Arcade cabinet: Windows 11, LaunchBox/Big Box, RetroArch |

The full address plan (switch, Wi-Fi, Home Assistant, R620 lab, desktops) is in [part 0's overview](docs/manual/00-overview-architecture.md).

### The `stream` pod's apps

| App | Port | Public name | Script |
|---|---|---|---|
| Jellyfin | 8096 | `tv.songofeo.com` | `sgin/jellyfin.sh` |
| ErsatzTV | 8409 | (inside Jellyfin) | `sgin/ersatztv.sh` |
| Navidrome, Music | 4533 | `music.`, `mustang.` | `sgin/navidrome.sh` |
| Audiobookshelf | 13378 | `audio.`, `sessions.`, `talk.`, `comedy.`, `archives.` | `sgin/audiobookshelf.sh` (Talk Radio & Comedy Club and The Archives are its libraries since 2026-11-18) |
| Kavita | 5000 | `comics.` | `sgin/kavita.sh` (also the RPG Vault library, `dock1a/books/RPG Books`) |
| (retired) Navidrome, Talk / Archives | 4534, 4535 | | `sgin/navidrome-talk.sh`, `sgin/navidrome-archives.sh`: no longer started by `up-all.sh`; data kept |
| RomM | 8080 | `arcade.` | `sgin/romm.sh` (`romm-reset.sh` to start over) |
| Calibre-Web Automated | 8083 | `books.` | Project-Eo `home/cobra-setup/20-sgin-calibre-web.sh` |
| Icecast radio | 8000 | `radio.` | `sgin/radio.sh` |

---

## The manual

Start with the overview, then follow the parts in order.

| Part | File |
|---|---|
| Overview | [docs/manual/00-overview-architecture.md](docs/manual/00-overview-architecture.md) |
| 0. Before you start | [docs/manual/00-prep.md](docs/manual/00-prep.md) |
| 1. Latitude (Proxmox) | [docs/manual/01-latitude.md](docs/manual/01-latitude.md) |
| 2. Networking (OPNsense, Pi-hole #1) | [docs/manual/02-networking.md](docs/manual/02-networking.md) |
| 3. SGIN (media, Samba, Pi-hole #2, PBS) | [docs/manual/03-sgin.md](docs/manual/03-sgin.md) |
| 4. OptiPlex (arcade) | [docs/manual/04-optiplex.md](docs/manual/04-optiplex.md) |
| 5. Gate VM, go public, backups | [docs/manual/05-final-touches.md](docs/manual/05-final-touches.md) |
| 6. Breaks between episodes (cobra-breaks) | [docs/manual/06-tv-breaks-plugin.md](docs/manual/06-tv-breaks-plugin.md) |
| 7. Hiscore board (scores.songofeo.com) | [docs/manual/07-hiscore-platform.md](docs/manual/07-hiscore-platform.md) |
| 8. Landing site and radio | [docs/manual/08-site-and-radio.md](docs/manual/08-site-and-radio.md) |
| 9. R620 lab and VLANs | [docs/manual/09-r620-lab-and-vlans.md](docs/manual/09-r620-lab-and-vlans.md) |
| 10. Home Assistant | [docs/manual/10-home-assistant.md](docs/manual/10-home-assistant.md) |
| 11. Extra bling (lit buttons, marquee, pinball, CRT bezels) | [docs/manual/11-extra-bling.md](docs/manual/11-extra-bling.md) |
| 12. Form service, inbox only (**the chosen go-live**) | [docs/manual/12-forms-inbox-only.md](docs/manual/12-forms-inbox-only.md) |
| 12 (alt). Form service with Gmail | [docs/manual/12-forms.md](docs/manual/12-forms.md) |
| 13. Personal state (favorites, progress, settings) | [docs/manual/13-personal-state.md](docs/manual/13-personal-state.md) |

---

## Runbooks and guides

| File | Covers |
|---|---|
| [docs/CHECKLIST.md](docs/CHECKLIST.md) | Everything still to do, in order, with a tick box per step |
| [docs/MEMORY.md](docs/MEMORY.md) | Continuity notes |
| [docs/field-guide/](docs/field-guide/README.md) | *You and Your Pod!*: every container explained (PDF and HTML) |
| [docs/gate-sso-tv-runbook.md](docs/gate-sso-tv-runbook.md) | Gate sign-in and TV apps |
| [docs/music.md](docs/music.md) | Navidrome libraries, people and phone apps |
| [docs/arcade-runbook.md](docs/arcade-runbook.md) | The arcade cabinet |
| [docs/authelia-users/](docs/authelia-users/README.md) | Adding people to the sign-in |
| [docs/roku-tv/](docs/roku-tv/README.md) | Roku TVs |
| [docs/jellyfin/red-shelf.css](docs/jellyfin/red-shelf.css) | Jellyfin's custom theme |
| [docs/future-builds/](docs/future-builds/README.md) | Not in a stage yet: distros, Wi-Fi APs, arcade GPU and towers |
| [docs/research/](docs/research/) | Container research, plugin gaps, Quick Sync on Debian |
| [docs/branch-archive.md](docs/branch-archive.md) | Removed branches and how to restore one |

---

## Code

| Path | What it is |
|---|---|
| [scripts/podman/](scripts/podman/README.md) | One `podman run` script per app (master copy), plus personal-state backup and restore |
| [scripts/arcade/](scripts/arcade/) | Arcade bundles and the cabinet's setup |
| [scripts/oneshot/](scripts/oneshot/README.md) | One-time gate fixes (sign-in, phone apps, eo-art folders) |
| [apps/hiscore](apps/hiscore) | Score server (`scores.songofeo.com`) |
| [apps/hiscore-agent](apps/hiscore-agent), [apps/hiscore-launchbox](apps/hiscore-launchbox) | Cabinet uploader and LaunchBox plugin |
| [apps/cobra-breaks](apps/cobra-breaks) | Breaks between episodes |
| [apps/forms](apps/forms) | The form receiver (`forms.songofeo.com`) |
| [apps/radio](apps/radio) | The radio's Liquidsoap script |
| [apps/site](apps/site) | The old landing page (the live site is in Project-Eo) |
