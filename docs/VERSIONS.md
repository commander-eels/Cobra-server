# Software versions the manuals are written for

Checked 2026-11-21. **Rule:** before any step, menu name or command is written or followed, check the app's latest release notes and current docs against the version in this table. If your box runs something older or newer, check that version's notes first. Update this table whenever a manual is updated.

## 1. Latest releases (as of 2026-11-21)

| App | Latest checked | Released | What matters for cobra | Source |
|---|---|---|---|---|
| OPNsense | 26.7.9 (hotfix 26.7.9_3) | 2026-11-11 (_3: 11-16) | See section 2. Next major is 27.1 (January). | [26.7 notes](https://docs.opnsense.org/releases/CE_26.7.html), [26.1 notes](https://docs.opnsense.org/releases/CE_26.1.html) |
| Proxmox VE | 9.2 | 2026-05-21 | Debian 13.5 base, kernel 7.0, QEMU 11.0. 9.1 → 9.2 is a normal apt/GUI upgrade. | [9.2 announcement](https://forum.proxmox.com/threads/proxmox-virtual-environment-9-2-available.183741/) |
| Debian | 13.7 or later point release | 13.7: 2026-09-12 | Point releases need only `apt update` + `apt full-upgrade`. | [debian.org/News](https://www.debian.org/News/2026/20260912) |
| Podman (upstream) | 5.8 | 2026-03 | Debian 13 ships 5.4.x. Don't use newer subcommands such as `podman quadlet install` on the gate or SGIN: the manuals write Quadlet files by hand, which works on 5.4. 5.8 moves BoltDB to SQLite ahead of Podman 6. | [5.8 summary](https://www.linuxtoday.com/blog/podman-5-8-introduces-quadlet-multi-file-install-and-sqlite-migration/) |
| Authelia | 4.39.28 | 2026-09-17 | Our config already uses the 4.38/4.39 keys (`session.cookies[]`, `definitions.network`, `identity_validation.reset_password.jwt_secret`, `server.address`) and nginx calls `/api/authz/auth-request`, not the old `/api/verify`. | [releases](https://github.com/authelia/authelia/releases), [4.39 notes](https://www.authelia.com/blog/4.39-release-notes/) |
| lego | 5.6.0 | 5.0.0: 2026-05-11 | Manual 5.4 already uses v5 syntax. Coming from v4: run `lego migrate` first; `--run-hook`/`--renew-hook` → `--deploy-hook`; `--days` → `--renew-days`; no `renew` command. | [v5 CLI migration](https://go-acme.github.io/lego/migration/cli/index.html), [Porkbun](https://go-acme.github.io/lego/dns/porkbun/) |
| Jellyfin | 12.3 | 12.0: 2026-09-08 | See section 3. Version numbers dropped the "10.". | [JellyWatch 12.0 summary](https://jellywatch.app/blog/jellyfin-12-release-everything-you-need-to-know) |
| ErsatzTV (legacy image) | 26.14.0 | 2026-11 (26.13.0 two days earlier) | 26.12.0 removed the old streaming engine (MPEG-TS (Legacy) and HLS Direct channels auto-move to MPEG-TS / HLS Segmenter). 26.13.0 **breaking**: JWT stream auth removed; if `JWT__ISSUERSIGNINGKEY` is set, IPTV/M3U/XMLTV are disabled until it is removed (our pod script never sets it). Guide: docs/ersatztv. | [v26.14.0](https://newreleases.io/project/github/ErsatzTV/legacy/release/v26.14.0), [v26.13.0](https://newreleases.io/project/github/ErsatzTV/legacy/release/v26.13.0), [docs](https://ersatztv.org/docs/) |
| Navidrome | 0.64.0 | 2026-09-12 | **Back up `navidrome.db` before updating to 0.64**: every internal ID is re-encoded, so phone apps with offline downloads may need to re-sync. Login rate limit now uses the trusted client IP. | [v0.64.0](https://github.com/navidrome/navidrome/releases/tag/v0.64.0) |
| Audiobookshelf | 2.38.0 | 2026-11-17 | Security fixes (users reading other users' sessions). Node 24 image since 2.37. `v3` image tag is a test build: stay on `latest`. | [Releasebot feed](https://releasebot.io/updates/advplyraaudiobookshelf/audiobookshelf) |
| Kavita | 0.9.1.4 | 2026-09-02 | 0.9.0.2 and 0.9.1 are security releases: be on 0.9.1+ . 0.9.1 forces one re-login (tokens now 3 days). "Disable password authentication (OIDC)" now applies to everyone. | [Kavita updates](https://opencollective.com/kavita/updates) |
| RomM | 5.2.0 | 5.0: 2026-07-15 | 4.x → 5.x is a big UI change. 5.1 needs MariaDB to allow trigger creation (`log_bin_trust_function_creators=1` if binary logging is on) and a cache purge of `index.html` behind proxies. Read the notes before pulling. | [RomM releases](https://github.com/rommapp/romm/releases) |
| Vaultwarden | 1.37.4 | 2026-10-05 | **Security release (7 advisories): update.** `IP_HEADER` now takes the rightmost untrusted address; list nginx in `IP_HEADER_TRUSTED_PROXIES` if you set it. | [releases](https://github.com/dani-garcia/vaultwarden/releases) |
| Paperless-ngx | 3.5.1 | 2026-11-18 | Be on 3.3.4 or later (security). 3.5.0 changed the `PAPERLESS_ALLOWED_HOSTS` default: check it if the page stops loading after an update. | [Releasebot feed](https://releasebot.io/updates/paperless-ngx) |
| Pi-hole | Core 6.5 / FTL 6.8 / Web 6.6.1 | 2026-10-17 | Commands in the manuals (`pihole -up`, `pihole setpassword`) are current. `pihole arpflush` is now `pihole networkflush`. Security fixes: update both Pi-holes. | [release post](https://discourse.pi-hole.net/t/pi-hole-ftl-v6-8-web-v6-6-1-and-core-v6-5-released/87951) |
| Omada switch / EAP firmware | not checked against your model | | Check your firmware on tp-link.com for **ES210X-M2** (and the EAP772 when bought) before following parts 2.10b and 2.12. | [TP-Link support](https://www.tp-link.com/us/support/download/) |
| HandBrake | 1.11.x (1.11.2 seen) | 2026-06 | Guide v2 settings still apply (1.8+). | [1.11.2](https://ubuntuhandbook.org/index.php/2026/06/handbrake-1-11-2-released-with-webm-mime-type-support-for-linux/) |
| Roku OS | 15.x | 15.1: 2026 spring | Jellyfin app steps unchanged as far as checked. | [Roku release notes](https://developer.roku.com/dev/docs/release-notes) |
| MakeMKV, WireGuard apps, Home Assistant | not checked this pass | | Check the version on the device (section 4) before using a guide step. | |

## 2. OPNsense changes since the manuals were first written (26.1 and 26.7)

| Old wording | Current (26.1 / 26.7) | Fixed in |
|---|---|---|
| Firewall → NAT → **Port Forward** | Firewall → NAT → **Destination NAT** | PRs #75, #77 |
| A new port forward auto-creates its WAN pass rule | The forward's **Firewall rule** field defaults to **Manual**: no rule is created and the forward stays blocked. Pick **Register rule** (or **Pass**), or add the rule yourself in Firewall → Rules → WAN | 02 terms table + 2.4; 05 5.5 already says it |
| Firewall → Rules → *interface* (separate PHP pages) | One **Firewall → Rules** page (MVC); choose the interface in its selector. Legacy pages only with the `os-firewall-legacy` plugin | 02 terms table |
| Firewall → NAT → **Outbound** | **Firewall → NAT → Source NAT (Outbound)**; 26.7.5 moved the old Outbound page to the legacy plugin. Cobra uses automatic outbound NAT, so nothing to change | not referenced in manuals |
| Services → **ISC DHCPv4** → LAN | **Services → Dnsmasq DNS & DHCP** is the default since 26.1; ISC DHCP needs the `os-isc-dhcp` plugin | 02 2.6, 03 3.1 and 3.9 |
| WAN "Block RFC1918 private networks" | **Block private networks** | 02 2.5 |
| Interfaces → Assignments → open interface | Since 26.7.6 interface settings also open from the Assignments grid; the old page still works | no change needed |

## 3. Jellyfin 12 upgrade checklist (from 10.11.x)

The SGIN pulls `jellyfin/jellyfin:latest`, so the next auto-update jumps to 12.x. Before that:

| Step | Where |
|---|---|
| Be on 10.10.7 or any 10.11.x first | Dashboard shows the version |
| Back up `/config` and `/cache` (stop the container first) | SGIN, as podsvc |
| Remove third-party plugins (Intro Skipper, etc.) until they have 12.x builds; official plugins are updated | Dashboard → Plugins |
| Check no two usernames differ only by upper/lower case (migration fails on them) | Dashboard → Users |
| Let the first start finish its migrations, then run a full library scan | Dashboard → Libraries → Scan All Libraries |
| Hard-refresh browsers (Ctrl+F5) | the-box |
| Subtitle settings are now per library, not global | Dashboard → Libraries → each library |

Menu names in manual parts 3, 5, 6 and the gate runbook were written for 10.11. After you are on 12, check Dashboard → Networking (Known proxies, LAN networks) and Dashboard → Playback → Transcoding still match, and tell Claude what your screen shows if anything moved.

## 4. Check what you actually run

| What | Machine / window | Command or place |
|---|---|---|
| OPNsense | the-box browser, `https://10.6.9.1` | System → Firmware → Status |
| Proxmox VE | cobra-command shell | `pveversion` |
| Debian | gate and SGIN shells | `cat /etc/debian_version` |
| Podman | gate and SGIN shells | `podman --version` |
| Every container image and its tag | gate and SGIN, as podsvc | `podman ps --format '{{.Names}} {{.Image}}'` |
| Images with an update waiting | gate and SGIN, as podsvc | `podman auto-update --dry-run` |
| Authelia | gate, as podsvc | `podman exec authelia authelia --version` |
| lego | gate shell | `/usr/local/bin/lego --version` |
| Pi-hole | each Pi-hole shell | `pihole -v` |
| Jellyfin, Navidrome, Audiobookshelf, Kavita, RomM, Paperless, Vaultwarden | the-box browser | each app's About / Dashboard / admin page |
| Omada switch | the-box browser, `http://10.6.9.5` | the switch's status / system info page (firmware version) |
| HandBrake, MakeMKV | the-box | Help → About |
| Roku | TV remote | Settings → System → About |
| WireGuard | phone / Cobra1 | app → About |

Send the results to Claude and this table gets a "you run" column.
