# Grok handoff: v3.9 Thanksgiving FINAL (2026-11-27)

**Base:** v3.8 DRAFT (below). The owner chose "build the final now" after Grok's v3.8 return, which added a Zigbee section but left the 5 checks open. Claude answered the 5 checks itself and built this final. Nothing here has run on a real server yet. The owner, as CSO, signs off before anything goes live.

## Grok's v3.8 notes and what Claude decided
| Grok said | Decision | Why |
|---|---|---|
| Zigbee is "critical" | **Optional**: README 9H points to Part 10 (10.1 to 10.5), skip unless a stick is bought | The owner owns no Zigbee stick or devices. Sensi and Eufy are both Wi-Fi. |
| Zigbee2MQTT or ZHA | **ZHA** | Z2M needs a Mosquitto broker add-on. ZHA is built in and enough for a first network. |
| USB stick passthrough | `F64 usb`: `qm set 120 --usb0 host=VVVV:PPPP` by device id, plus a USB extension cable | By id survives port changes. The cable keeps the stick away from USB 3 noise. It stops if `usb0` already exists and asks before restarting the VM. |
| Channel | 15, 20 or 25, after checking the Xfinity Wi-Fi channel | These avoid the common 2.4 GHz Wi-Fi channels 1, 6 and 11. |
| Device order | Mains-powered devices first (they become routers), battery sensors after | Standard mesh advice. |

## The 5 checks, answered
1. **HA UI paths:** Developer tools sits under **Settings** since 2026.2. The README uses that path everywhere. HACS became "Marketplace" in 2026.11. Core is held at 2026.9.4, so old HACS still works there.
2. **Static IP with empty gateway on the second NIC:** no default route is added. The LAN NIC stays the only route out.
3. **`120.fw` and net0:** Proxmox applies VM rules only on NICs with `firewall=1`. net0 has none, so it stays unfiltered. net1 has `firewall=1` and gets the DROP policy plus the mDNS/ICMP allows.
4. **Xfinity reservation page:** "Connected Devices → Add Device with Reserved IP" at `http://10.0.0.1` is still right. (DMZ is the only thing that moved to the app.)
5. **Alexa:** a Help note only. Keep the vendor skills for voice. HA Cloud (Nabu Casa) is a paid choice for later.

## Other fixes in v3.9
- **Part 4 (RomM):** 4.7 uses the Forgot password reset link. 4.8 swaps `0.0.0.0` for `10.6.9.20:8080` in the link it prints.
- **Help:** 2.15 to 2.18 (type `8096`, not `8069`), 3.10 (Source port stays `any`), 4.6 (reset link), Alexa note, 10.x Zigbee entries, and "Checked against" lines for Parts 4, 9 and 10.
- **README title and Part 1** point at `cobra-runlist-2026-11-27-v3.9-Thanksgiving`.

## Still open for a later research run (not blocking)
- Matter or Kasa replacements if Eufy stays cloud-only.
- PodPanels: show `cobra-home` as a VM (read-only Proxmox API), not a container.
- Unhold Core when issue #186877 is fixed. Check the release notes first.

---

# Grok handoff: v3.8 DRAFT (2026-11-27), the smart home moves to VM 120

**Base:** v3.7 DRAFT (below, kept for history). **Owner's decision, 2026-11-27:** Home Assistant runs as **Home Assistant OS in VM 120 `cobra-home` on the Latitude (Proxmox)**, per the repo's manual part 10 (`docs/manual/10-home-assistant.md`, Oct 26), **not** in a pod on the SGIN. Name: **`ha.songofeo.com`** (it was already in the home Wi-Fi overrides and the docs). Nothing here has run on a real server.

## Why v3.7's SGIN pod was dropped (things the v3.7 draft didn't know)
- The thermostat is a **Sensi**. Its local path is the **HomeKit Device** integration, which needs mDNS on the same network as the device. mDNS can't cross OPNsense, so from the SGIN (LAN only) it could never pair. The Latitude is the only box on both networks (vmbr0 = LAN, vmbr1 = Xfinity side).
- **Eufy local control is broken in Home Assistant 2026.10 and later** (core issue #186877 "Expected an int, got a boolean", still open at 2026.11.3, Nov 23). Last good: **2026.9.4**. HA OS makes holding Core easy (`ha core update --version 2026.9.4`).
- **HA 2026.11 moved HACS into core as "Marketplace"** and the separate HACS installer stops at 2026.11. With Core held at 2026.9.4, old HACS still installs (needed only for Sensi plan B, the cloud integration).
- **Proxmox 9 import trap:** some users get a disk with no partitions after `import-from`/`qm importdisk` (forum thread, Jan 2026). F64 checks for HA OS's 8 GPT partitions and offers a byte-for-byte rewrite of only VM 120's new disk.

## What changed from v3.7
| File | What |
|---|---|
| `F60`, `F61`, `payload/.../sgin/homeassistant.sh` | **Removed.** `sgin/up-all.sh` is back to v3.6; the health list in `fixlib.sh` no longer has the SGIN pod. |
| `F64-pve-home-vm.sh` (new) | Root on the Proxmox host. `create [ver]`: read-only checks (VM 120 free, vmbr0/vmbr1, memory, local-lvm 32 GB, /root 8 GB), downloads `haos_ova-<ver>.qcow2.xz` (checks the URL first), `qm create 120` with q35/OVMF, Secure Boot off, **both NICs link_down=1**, net1 `firewall=1`; checks partitions; writes `cluster.fw` (ACCEPT policies) + `120.fw` (net1: drop NEW in except mDNS 5353 and ICMP) **only if neither exists**, `pve-firewall compile` or both files are removed again. `plug-lan`, `plug-iot` (refuses unless net1 still has firewall=1 AND the firewall is running), `check`. Mock-tested: happy path, bad import → rewrite, VM exists → refuse, firewall file exists → nothing written, plug-iot without firewall → refuse. |
| `F65-gate-eufy-codes.sh` (new) | Read-only: Eufy cloud login (hidden password, `python3 -I`), prints name/model/IP/local code and whether the model is one the EufyHome integration supports (T1011-13, T1201-03, T1211). From manual 10.5. |
| `F62-gate-ha-route.sh` (was F62-gate-home-route) | `ha.` → `http://10.6.9.11:8123`, same admins-only Authelia rules above the admin-apps rule. **New:** stops if an existing `ha.` rule has `policy: bypass` (manual 10.7 suggested a home bypass; the owner's Nov 6 Authelia redo says no home bypass). Dry-run on the templates: one map line, one server_name, YAML parses. |
| `F63-gate-ha-token.sh` (was F63-gate-home-token) | URL `http://10.6.9.11:8123`. |
| `eo_account.py` | `HOME_URL_OK` = 10.6.9.11 or loopback. **Gate-ban guard:** after one 401/403 it stops calling HA until apps.json has a new token (HA's `ip_ban` would otherwise ban 10.6.9.10 after 5 admin page loads; the Multi-Pass calls HA directly, no X-Forwarded-For). Device list cached 15 s and cleared after a change; 2 s timeout. `home_num()` guards null/odd `min_temp`/`max_temp`. 13 Smart home tests pass (4 new); 50 of 53 overall, the 3 errors are repo-file tests, as in v3.6. |
| `F32` | Stops if `player.` couldn't be added next to `mustang.` (mustang was dropped 2026-11-17; before, it skipped silently and nginx -t passed). |
| `F01` | Records which awk is installed (mawk ignores `\s`). |
| `README.md` | Part 9 rewritten (9.1 to 9.37) for VM 120, with Help 9.x. Part 1 points at the v3.8 zip. |

## Please check
1. **HA UI paths in 9.13 to 9.24, 9.36** against HA 2026.9.4 / 2026.11 (Settings → Developer tools location, Network page wording, Security tab names).
2. **9.15 / 9.16:** HA OS static IPv4 with empty gateway on the second NIC: confirm it adds no default route (manual says so; please confirm on HA OS 18.x).
3. **`120.fw`:** with `policy_in: DROP` and rules only for `-i net1`, is net0 (no `firewall=1`) truly unfiltered? (Proxmox applies VM rules only on NICs with firewall=1.)
4. **The Xfinity reservation page (9.8, 9.28)** at `http://10.0.0.1`: still "Connected Devices → Add Device with Reserved IP" on current Xfinity gateways? The-box reaches 10.0.0.1 through OPNsense's WAN.
5. **Research run** from v3.7 still stands, minus the placement question: Alexa (keep vendor skills for voice vs HA Cloud), Matter/Kasa replacements for cloud-only Eufy, and the PodPanels guard rails for UI-editable volumes/env (v3.7 list below). PodPanels: add `cobra-home` as a VM (status via Proxmox API read-only), not a container.

---

# Grok handoff: v3.7 DRAFT (2026-11-27), the smart home

**Base:** v3.6 (the newest run list on the-box, `V:\=ClaudeCode=\cobra-runlist-2026-11-21-v3.6`). The zip called "cobra-fix-updated-2026-11-26" was the old v3.1 bundle plus a one-page note; **its run order and its F10 advice are out of date** (RomM 5: F10 stops at its role check; step 4 / F11 replaced it in v3.5). Please work from this zip only.

**The owner's flow:** Claude drafted this (two passes), **you check it and do a research run**, then hand it back to Claude, who builds the final "Thanksgiving Cobra Server Update" zip. Nothing here has run on a real server. The owner, as CSO, signs off before anything goes live.

## What's new in v3.7 (README Part 9)

| File | Where | What |
|---|---|---|
| `payload/cobra-server-scripts/podman/sgin/homeassistant.sh` | SGIN, podsvc | Home Assistant in its own pod `home`, only 8123 published, its own config folder, **no media drives, no host network, no --privileged, no devices**. Refuses to start without F60's configuration.yaml. Image `:stable` until you pick a tag to pin. |
| `F60-sgin-home.sh` | SGIN, podsvc | Writes a NEW configuration.yaml only if there isn't one (`use_x_forwarded_for`, `trusted_proxies: [10.6.9.10]`, `ip_ban_enabled`, 5 tries). Never edits an existing one; prints the lines instead. Then starts the pod. |
| `F61-sgin-firewall-home.sh` | SGIN, eels | One nft line under the LAN line: `ip saddr 10.6.9.10 tcp dport 8123 accept` (gate only). F37's safety: `nft -c`, backup, 2-minute second-SSH confirm or auto-rollback. |
| `F62-gate-home-route.sh` | gate, podsvc | Probes first from the nginx container with a fake `X-Forwarded-For` (200 = HA trusts the gate, 400 = it doesn't, 000 = not reachable; stops on 400/000). Adds `home.` to the `$protected` map + server_name (same block as command./status.), and two Authelia rules **above** the admin-apps rule: `home.` subject `user:eels`/`group:admins` two_factor, then `home.` deny. |
| `F63-gate-home-token.sh` | gate, podsvc | Hidden paste of an HA long-lived token into apps.json `"home"` (mode 600, stdin only), restart eo-account, roll back if it doesn't answer. Needs F20 (README 6.1) working first. |
| `eo_account.py` | gate | **Smart home** window (admin only) + `POST /admin/home`. See below. |
| `test_home.py` | | 10 new tests with a fake HA on 127.0.0.1:8123. All 10 pass; the other 37 still pass (3 errors are repo-file tests, the same as v3.6). |
| `fixlib.sh`, `sgin/up-all.sh`, `F20` | | HA added to the health-check list; up-all starts it only after F60; F20's live-vs-new list checks for `def home_block`. |

### The Multi-Pass Smart home window, please review closely
- Config only from apps.json `"home"`: `url` must match `^http://(10\.6\.9\.20|127\.0\.0\.1):8123$` (no SSRF through a bad file), token never logged or rendered.
- Reads `GET /api/states`, shows only `light.*`, `switch.*`, `climate.*` (max 80).
- Changes allowed: `light/toggle`, `switch/toggle`, `climate/set_temperature` (within the entity's own `min_temp`..`max_temp`), `climate/set_hvac_mode` (only a mode in its `hvac_modes`). The entity must be in the list HA returned **in the same request**.
- POST checks, in order: `is_admin` → `_require_admin_session` (Authelia re-checks the cookie, ACCOUNT_ADMINS only) → form token → 30 changes/minute/admin → the checks above. The dispatcher's Origin check and 16 KB limit apply. Opener: no proxy, no redirects (`_podpanels_opener`).
- **Check:** is reusing `_podpanels_opener` fine, or should it get its own? Is a 3 s timeout on every admin page load acceptable when HA is down?

## Found in v3.6 while doing this (Claude's own bugs; please cross-check the fix)
- **awk `\s` on mawk.** Debian's default awk is mawk, which doesn't understand `\s` (it silently matches nothing). Two awk programs used it: **F32 line 43** (adds `player.` to the station map) and **F35 line 46** (adds `gaming.` to the map). On the gate they'd skip the map line without an error: F35's server_name check would still pass, so `gaming.` could end up with no upstream. Both now use `[[:space:]]`. grep -E and sed -E `\s` are fine (GNU). **Please grep every awk program in the bundle for `\s`, `\d`, `\w`** in case we missed one, and confirm the gate's awk with `awk -W version` in F01's survey.
- **Authelia admin-apps rule has no subject** (`papers.`, `metube.`, `command.`, `status.`: two_factor for anyone signed in). Not changed; it's in README Help 9.6 as a CSO decision. Your view?

## Please check
1. **Rootless source address.** F62's probe relies on HA seeing the gate as 10.6.9.10 through rootless port publishing. On Debian 13's podman 5 (pasta) the source should be kept; with slirp4netns/rootlessport it isn't. If you know the SGIN's network mode, say which, and what to do if the probe gets 400 (`--network pasta` on the pod? a different trusted_proxies entry? never trust a whole subnet).
2. **HA reaching the IoT side.** The bulbs and thermostat are on the Xfinity Wi-Fi extender (`The Electronomicon_EXT`, 10.0.0.x), outside OPNsense. HA on the SGIN reaches them outbound through OPNsense NAT. Check: the SGIN's nftables output chain (policy accept?) and OPNsense LAN rules allow LAN → 10.0.0.0/24. Is anything on the Xfinity side going to start connections back (it can't, by design)? Does any integration we'd pick need the device to call HA?
3. **F61's anchor**: it inserts under the first line with `10.6.9.0/24` and `8096`, like F37. Both F37 and F61 insert there; check two inserted lines can't collide.
4. **HA image tag**: pick the current stable version tag to pin.
5. **Backups**: HA's config isn't in `state.sh`. Its own backups (Settings → System → Backups) go to `/config/backups`. Should state.sh snapshot `/srv/stream/homeassistant/config` nightly? It holds device tokens, so it needs the same care as the Archives' DB.

## Research run (the owner asked for your own)
**Question: the best self-hosted pod to manage the house, and how it plugs into the Multi-Pass PodPanels.** Today everything is Alexa → Eufy, and the owner says it's bad at it. Wanted: smart bulbs, light switches and the thermostat, managed from the Multi-Pass ADMIN section.
- Compare Home Assistant (Claude's draft pick) with any real alternative you think fits better (openHAB, Homebridge, others). Criteria: local control without the cloud, rootless podman with no host network, a REST/WebSocket API the Multi-Pass can call, security track record, and how much upkeep it needs.
- **Eufy:** which Eufy bulbs/plugs can be controlled locally, and with which integration (core, HACS, eufy-security-ws)? If they're cloud-only, say so plainly; the honest answer may be replacing them over time with local-control (Matter/Zigbee/Thread) gear. If you suggest hardware, say so; don't assume anything is bought.
- **Thermostat:** the brand/model isn't known yet; ask the owner.
- **Alexa:** keep voice through Alexa (HA's Alexa skill / Matter bridge) or drop it? Say what each option sends to the cloud.
- **PodPanels:** the command service isn't in this bundle (you built it). Please: (a) add `homeassistant` (pod `home`, SGIN) to its fixed list with start/stop/restart/logs; (b) for the owner's ask to add volumes and env/config updates from the UI, write down the guard rails before building: an allowlist of host paths (never `/`, `/etc`, `~/.ssh`, the podman socket, `/srv/gate/authelia`), read-only by default, an env-key allowlist per container, a diff + confirm, a backup of the unit or run script, a log line per change, and admins only behind the same `_require_admin_session`. A UI that can add any volume is a root shell on the box.

**Then hand it back to Claude** with your answers and any code, and Claude builds the final Thanksgiving zip.

---

# Grok handoff: v3.6 (2026-11-21)

**What changed:** only the README. The user found v3.5.1 too hard to follow (summaries with commands in them, several READMEs pointing at each other). v3.6 is ONE file: numbered tick-box steps first (Parts 1 to 8), one action per step with its tab, exact text in grey boxes, one "You should see" line, and all reasons and troubleshooting in a Help section at the end, keyed by step number. The Wi-Fi and Roku guides are now inside it, so the docs/ folder is gone. No script changed since v3.5.1.

**Please check:** every OPNsense 26.x field name and value in Part 2 (Destination NAT: Protocol TCP first, Destination port "Single port or range" = 8096, Redirect target 10.6.9.20 / 8096, Firewall rule = Register rule) and Part 3 (Unbound). Flag anything your screen calls differently.

---

# Grok handoff: cobra server run list, 2026-11-21 (version 3.5, final)

**Grok's review of the draft, and what Claude did with each point:**

| Grok's note | Decision | Why |
|---|---|---|
| F11 is safe; the diagnosis, the 4 atomic changes, the restart order and the rollback are right | Agreed | Matches the mock tests |
| Wait for romm-db before starting romm | **Applied** | F11 now starts arcade-pod and romm-db, waits up to 60 s for a healthy status or `mariadb-admin ping`, then starts romm. Re-tested with mocks |
| `romm.sh` and `pod.sh` still put RomM in the stream pod | **Applied in this zip's payload** | `romm.sh` uses `ensure_pod arcade 8080:8080`, and `pod.sh` drops 8080 from `STREAM_PORTS`. `romm-reset.sh` calls `romm.sh`, so it follows (after F11, `ensure_pod`'s `no_quadlet` check stops it, because arcade.pod is a Quadlet). The upstream cobra-server PR is still to do |
| F10 is "fine to run after F11" | **Rejected** | The live RomM is 5.x. The survey shows `role varchar(20)`, and RomM 5 uses `user`/`admin` with the wizard only on an empty DB. F10 stops at its ENUM check. Step 3b (Forgot password) replaces it |
| F20 precheck is protective | Agreed | |
| (not answered) RomM 5 reset log line, `MARIADB_ROOT_PASSWORD`, `/api/heartbeat`, Kavita `TokenKey`, Feishin env, Live View logging | **Still open** | Each one is guarded: the 3b commands only read, F11 no longer depends on the heartbeat, F50 checks its own key edit, and F33 is checked by its probe. Please answer them when you can |


**New in v3.5:**

1. **Every README step has a "Checked against" line** (2026-11-21), using cobra-server `docs/VERSIONS.md` (main `a00ba18`). **Please flag any version or menu name you know to be newer or different.**
2. **Step 3b replaces F10 for RomM 5.** Sources: RomM 5.0.0 docs ("Invitations and registration"), and the 5.0.0-beta.1 and 5.1.0 notes. In RomM 5 the wizard shows only on an **empty database**, the Role enum is now `user | admin` (breaking change), and a password reset prints a temporary password in the container logs. The SGIN survey shows `role varchar(20)`, so F10's ENUM parse would stop safely at its line 59. The new 3b: (a) a read-only `SELECT username, email, role FROM users` inside romm-db, (b) **Forgot password?** on the login page, (c) `podman logs --tail 40 romm` for the temporary password, (d) log in and change it. **Please check:** does RomM 5.x's forgot-password flow print the temporary password to the logs when no SMTP is set, and is the link on the login page by default? Is `MARIADB_ROOT_PASSWORD` set inside our `mariadb:11` container? Does `/api/heartbeat` still return `SHOW_SETUP_WIZARD` in 5.x?
3. **F11 changed (the only script change since v3.2):** the RomM check no longer rolls back just because `/api/heartbeat` gives no JSON (RomM 5 may have moved it). It rolls back only if the logs still show `Address in use`, or RomM's page doesn't answer at all. **Tested here with mocked podman, systemctl and curl:** the happy path (4 diffs, the right systemctl order, the files exactly as intended), the full rollback (files restored, arcade.pod moved aside, stream-pod restarted) and the heartbeat-moved path. All three behaved as intended. Not tested on real Quadlet. **Please check** that `systemctl --user restart stream-pod` re-creates the pod without 8080 before `arcade-pod` starts.
4. **F37 tested here** with mocked sudo and nft against manual 3's nftables.conf: the one line is added after the LAN line, an unconfirmed run rolls back, a confirmed run is kept, and a rerun says "already there". `nft -c` wasn't run for real. **Please check the rule syntax** (`ip saddr 10.0.0.0/24 tcp dport 8096 accept` inside `chain input` of `table inet filter`).
5. **Step 0b, the Roku timeout diagnosis:** Live View filter 8096 (nothing / red / green), then `tcpdump` on the SGIN. **Check:** on 26.7, is the default deny logged by default, so that "nothing in Live View" really means "never arrived"?
6. **Step 14:** it warns against `F40 --fix` re-creating `romm` from `romm.sh` (the stream pod) after F11. **Check F40's fix path:** `how_run` should see the Quadlet and only `systemctl --user restart`.
7. **Kavita 0.9.1 (F50):** the 0.9.1 notes don't mention `TokenKey` in `appsettings.json`. F50 greps for the new key afterwards and should stop if it's missing. **Please confirm `TokenKey` is still in appsettings.json on 0.9.1.4**, or say what replaced it.
8. **Feishin (F33):** the env (`SERVER_NAME`, `SERVER_TYPE=navidrome`, `SERVER_URL`, `SERVER_LOCK`) and port 9180 were checked against third-party deploy guides only. Please check them against the upstream README.
9. **Tabs:** every command names its tab. The owner uses one normal (non-admin) PowerShell window with the tabs `windows`, `eels@cobra-gate` and `eels@cobra-stream`. Flag any step that would need admin.

---

**New in v3.04** (README only): every command names its tab. The owner works in one normal (non-admin) PowerShell window with three tabs: `windows`, `eels@cobra-gate` and `eels@cobra-stream`. No step needs admin PowerShell.

**New in v3.03** (README only; no script changed since v3.2):

- The README was rewritten for the owner to follow step by step. There's a new Step A (OPNsense firmware check, the three terminal tabs, `podman auto-update --dry-run`). Each step now says what the owner should see, and has an "If it goes wrong" table naming the screenshot to send.
- **OPNsense 26.x wording** (checked against the 26.1 and 26.7 release notes, `docs/VERSIONS.md`): Firewall → NAT → **Destination NAT**. Its **Firewall rule** option defaults to **Manual** (no pass rule), so step 0b says **Register rule** and checks it under Firewall → Rules (WAN selected, Inspect on, "Automatically generated rules"). Unbound ACL may default to Deny after 26.1.6.
- Step 0b now has a three-check diagnosis for the Roku timeout: Live View filter 8096 (nothing / red / green), then `tcpdump` on the SGIN. **Please check that the Live View advice is right**: the default deny may not be logged unless logging is enabled.
- Step 14 warns not to let `F40 --fix` re-create `romm` from `romm.sh` before F11, because that would put it back in the stream pod. **Please check F40's fix path for romm after F11** (its EXPECTED entry says `script:sgin/romm.sh`, but live is Quadlet in arcade.pod).
- `docs/VERSIONS.md` and `docs/home-wifi/` were refreshed from cobra-server main `a00ba18`.

---

**New in version 3.2:** **F11-sgin-arcade-own-pod.sh** (README step 3a), which runs before F10.

- **What the SGIN survey showed:** `romm` runs and serves its page on 8080, but gunicorn loops on `connection to ('0.0.0.0', 5000) failed: [Errno 98] Address in use`, so the heartbeat never answers. RomM's gunicorn listens on 5000 inside its container. `kavita` (Comics) also listens on 5000 inside, and both are in the Quadlet `stream` pod, which is one network namespace. So F10's wizard check could never pass.
- **What F11 does:** it adds a new `arcade.pod` (PodName=arcade, PublishPort=8080:8080), comments out `PublishPort=8080:8080` in `stream.pod` (the line stays in the file), and sets `Pod=arcade.pod` in `romm.container` and `romm-db.container`. Then it runs daemon-reload, stops romm and romm-db, restarts stream-pod, and starts arcade-pod, romm-db and romm. It checks Jellyfin, Kavita, Navidrome, ABS, ErsatzTV and the RomM heartbeat. If anything fails, it offers a full rollback. It takes all four file changes or none.
- **Please check:** (1) Is there any RomM env setting that moves gunicorn off 5000, as a smaller alternative? (2) Does Quadlet `stream-pod` restart re-create the pod (`--replace`) so 8080 is released before `arcade-pod` binds it? (3) Is the ordering safe when romm-db's healthcheck is slow?
- **Not yet changed (upstream):** the run scripts `payload/cobra-server-scripts/podman/sgin/romm.sh` and `pod.sh` (`stream_pod`, and `STREAM_PORTS` with 8080) still put RomM in the stream pod. The same goes for cobra-server `romm-reset.sh` (PR #64), which calls `romm.sh`. Live RomM is Quadlet, so those scripts don't run today. But running `romm.sh` after F11 would make a second RomM in the wrong pod. Suggest the cleanest upstream change, for example `ensure_pod arcade 8080:8080` in `romm.sh`, with 8080 dropped from `STREAM_PORTS`.
- **Other survey notes:** dock1a/comedy and dock1a/archives don't exist yet. icecast and radio were never deployed (the owner has never used them, so leave them). The gate's homepage probe returns 000. The gate's live Multi-Pass is the old build, and there's no apps.json, so F20 dies at its precheck ("run cobra-setup step 15 once first"). **Please check that F20 precheck against a gate that never had apps.json.**

**New in version 3.1** (only the TV fix was added; everything from version 3 below is unchanged):

- **Step 0 in README.md: the Roku TV plays Jellyfin from the home Wi-Fi.** The owner, as CSO, accepted the risk on 2026-11-21 (`docs/home-wifi/DECISION-LOG.md`): the Xfinity side (`10.0.0.0/24`) reaches the gate and pods with a password (Authelia), and there's no WireGuard at home. The guides are `docs/home-wifi/HOME-WIFI.md` and `ROKU-TV.md`, copied from cobra-server `docs/` at main `cfd45f8` (PRs #70, #71, #73).
- **New F37-sgin-firewall-roku-tv.sh** (SGIN, run as eels). It adds one line under the SGIN's LAN port list in `/etc/nftables.conf`: `ip saddr 10.0.0.0/24 tcp dport 8096 accept`. Why: the OPNsense forward WAN `10.0.0.2:8096` to `10.6.9.20:8096` (source `10.0.0.0/24`) keeps the TV's source address, and the SGIN only accepted 8096 from `10.6.9.0/24` and `10.6.99.0/24` (manual 03-sgin.md line 709), so it dropped the TV. It has the same safety as F31: `nft -c`, a backup, and a 2-minute second-SSH confirm or auto-rollback. It's idempotent. **Please check:** the awk insert (it matches the first `ip saddr {..10.6.9.0/24..} tcp dport {..8096..}` line), and that F31's later edit of that same line (it adds ports after 13378) can't break or duplicate it. They're separate lines, so we think it's fine.
- **The F32 / archives. cross-check.** The new home Wi-Fi rules don't open The Archives. `archives` is excluded from the Unbound host overrides, there's no forward to 13380, and F37 opens only 8096. Authelia's template still has a `homewifi` two_factor rule for `archives.songofeo.com`. That rule is dead once F32 removes the name from nginx. It's harmless, but tell us if F32 should delete it too.
- **The home Wi-Fi override list** now covers the v3 names: audio, talk, player, ebooks, account, art, auth. If any v3 name served by `songofeo.conf` is still missing, say which.
- **Authelia `homewifi` (10.0.0.0/24)** asks for two_factor on the station names. That's stricter than the accepted "password-level" risk. We left it as is: is there any reason to relax it?
- Nothing touches the Xfinity router or the work laptop.

---

# Grok handoff: cobra server run list, 2026-11-21 (version 3)

**New in version 3** (the full run list for the owner's morning; README.md has the order):

- **Scripts synced with cobra-server `main`** (`payload/cobra-server-scripts/` mirrors cobra-server's `scripts/`). Main's three walled Kavitas came in (`kavita.sh comics|books|rpg`, its `state.sh` and `up-all.sh` entries), and two Project-Eo-only fixes were kept: `state.sh` reads sub-UID-owned files through `podman unshare tar`, and `oneshot/gate-sso-check.sh` is the newer one. **Please diff `payload/cobra-server-scripts/` against cobra-server main** and say if anything should go back upstream. The walled-ABS scripts, `feishin.sh`, the walled `audiobookshelf.sh` and the eo-art change exist only here so far.
- **Nightly backups now cover all three Audiobookshelfs:** `state.sh` knows `audiobookshelf-talk` and `audiobookshelf-archives` (same layout as the main one, data in `/srv/stream/<name>`), and `abs-walled.sh` calls `keep_personal_state` and `snapshot_personal_state`. This closes the v2 gap. **Check that `state-backup.sh` picks them up without other changes,** and that a restore into an empty Archives can't pull in another server's snapshot.
- **F31** now opens 13379, 13380, 5001 and 5002 in one change with one rollback. It replaces step 1 of the cobra-server Kavita runbook, which used a bare `sed` and `systemctl reload` with no rollback.
- **F50** walks the Kavita runbook's steps 2 and 3 (RPG copy from Comics, then the browser library deletes, then narrowing Comics, then the Books section list) with a pause between steps.
- **F35 and the Multi-Pass's three-Kavita change** were written by another Claude thread (the Kavita one) and merged here. **Please cross-check F35's sed and awk against `payload/templates/songofeo.conf`, and the Kavita connector changes in `eo_account.py`.** That thread couldn't run the Multi-Pass tests (they need Python 3.12). Claude ran all 40 tests on the merged build afterwards (Python 3.10 copy with the 3.12-only quotes swapped): they pass.
- **F36: eo-art checked after the wall changes.** `eo_art.py` is unchanged and was test-run locally with every wall (200 for each wall with pictures, 404 for an empty one, and a live reload when `folders.json` changes). Found and fixed: two walls the website asks for but `folders.json` never had (`/books/ebook/cover` from `window.js` line 209, and `/archives/cover` from line 273), and eo-art mounting **all** of dock1a (which includes The Archives' private recordings) when it only needs `dock1a/comedy`. F36 edits the live `folders.json` (it adds the two walls with `setdefault`, so existing ones are kept) and the Quadlet's `Volume=` line, both with a diff, a `y` and a backup. **Check the Quadlet `sed` against how `oneshot/gate-eo-art.sh` wrote that line.**
- **The Scoreboard** (hiscores page plus daily collector) is a Formidable Flow template kit from a third Claude thread (bpm-records/formidable-flow). README step 13 has how it's deployed here. Tomorrow only the read-only `check` runs: the cabinets aren't on the network yet. Please check one design point: its example config writes the board into `/srv/gate/hiscores-site/data` (a gate path), but the collector runs on cobra-stream. Suggest how the gate should get the data (our guess: the collector writes into the vault and the gate reads it over the read-only share, the way eo-art reads `dock1a/art`). The gate still reserves `scores.songofeo.com` for the old hiscore app; the owner hasn't picked between that and `hiscores.`, so keep both.
- **Formidable Flow field tests (the owner's ask):** everything built on the box with Formidable Flow is field-test data for the engine before January's template kits and free-tier kits. Claude's notes are in formidable-flow `docs/field-tests/`: `multipass-stats.md` (branch `claude/multipass-field-test`) and `scoreboard.md` (branch `claude/scoreboard-kit`). The rules and the entry template are in that folder's README. **Please append your own dated entry at the bottom of each file**, signed Grok-Viper, saying what you ran and what you only read: what runs, what's stored and what isn't, how data moves, and anything insecure, heavy or hard to use.

## Version 2 notes (still current)


**New in version 2:** three Audiobookshelf servers instead of two, and the owner's standing rule that **every instance of the same app is walled**: its own config, DB, users, API key, port and pod, and read-only mounts of only its own folders, with nothing shared live. That adds F34 (walling the existing main Audiobookshelf), and the health check and Admin Bays now cover the three walled Kavitas (5000, 5001, 5002) from a separate thread.

Hi Grok. Claude wrote this fix list for a two-server homelab (the "station"). The owner's rule is that code one AI writes for the servers is cross-checked by the other **before** it runs. Please review the scripts and the Multi-Pass changes below, and answer with: anything that's wrong or risky, anything unclear in `README.md`, and your own ideas.

This file stands on its own. Everything it names is in the same zip (`cobra-fix/` for the scripts and docs, `cobra-fix/payload/` for the files they install).

## The setup

- **the-box**: the owner's Windows PC. It runs `F00-copy-to-servers.ps1` (scp to `/tmp/cobra-fix`).
- **gate**, cobra-gate, `10.6.9.10`: nginx, Authelia (SSO, group walls, TOTP rules by network), the Multi-Pass (`eo_account.py`, a Python stdlib server on `127.0.0.1:8098` in image `python:3-slim`), Vaultwarden, Paperless, MeTube, Homepage, Uptime Kuma, the forms receiver, eo-art, hiscore, and now Feishin. All in one rootless podman pod, "gate".
- **SGIN**, cobra-stream, `10.6.9.20`: Jellyfin, ErsatzTV, Navidrome, Audiobookshelf (13378), Kavita, RomM plus MariaDB, Icecast plus Liquidsoap, and now two more Audiobookshelf servers (13379, 13380). nftables allows the LAN and WireGuard to reach a port list.
- Everything runs as user **podsvc** (rootless podman), started with `sudo machinectl shell podsvc@ /bin/bash <script>`. Some pods are Quadlet units, others come from "run scripts" in `payload/cobra-server-scripts/podman/{gate,sgin}/`.
- The network: OPNsense `10.6.9.1` behind an Xfinity gateway. Xfinity Wi-Fi (`10.0.0.x`) is outside OPNsense and untrusted.
- Standing rules for every script (`payload/lib.sh`): read-only first, then a diff and a `y` before any write; a timestamped backup; check, then restore on failure; **never delete**.

## What this fix list changes, and what to check

### F10: RomM (the Arcade) setup wizard won't show

The root causes, from the F10 header: RomM shows its wizard only while there's no admin in its DB. The old reset scripts weren't in the bundle the owner had. They probed only `127.0.0.1:8080`. And an empty DB is refilled from the nightly snapshot unless `SKIP_STATE_RESTORE=1` is set.

- **WIZARD mode:** `mariadb-dump` of the `users` table to `/srv/stream/romm-backups/`. Then `UPDATE users SET role=<viewer> WHERE role=<admin>`, with the enum literals read from `SHOW COLUMNS` (their case differs between RomM versions). Then it restarts RomM and checks the heartbeat for `"SHOW_SETUP_WIZARD": true`.
- **Please check:** does every RomM version since 3.x decide the wizard purely on "no admin user exists"? Is demoting (rather than deleting) admins enough, or does some version also look at a setup flag? Is the undo (a re-import of the dump) safe if a new admin was made in the meantime (a username clash)?
- **FRESH mode:** moves the DB folder aside (mv), only for a folder DB, never a named volume.

### F20: Multi-Pass, the merged build (the biggest change; please review closely)

There were two forks of `payload/account-gate/eo_account.py`: one with the ADMIN section and themes, and main with Forgot password, PodPanels, new-user Bays and the Audiobookshelf walls. Claude merged them. What to look at:

- `Handler._admin` (POST `/admin/user`, `/admin/adduser`, `/admin/settings`): it checks `is_admin(user, groups)`, then `_require_admin_session` re-asks Authelia whether the cookie really is that user. That session check now accepts `is_admin(user, self._groups())` (ADMINS **or** the `admins` group), where `Remote-Groups` is set by nginx from Authelia (`account.conf` blanks a visitor's own copy). **Is trusting Remote-Groups there safe?** Before, it was `user in ADMINS` only.
- On **save** of an existing person, the groups written are the ticked ones from `GROUPS` **plus** any group the page has no tick for (so hand-made groups survive). The check against removing your own Admin is kept.
- `GROUPS` = music, talk, **archives** (new), admins. The access-request approval card also has an Archives tick, off by default.
- **Admin Bays** (`ADMIN_BAYS_DEFAULT`, or `/data/admin-bays.json` if present) shows only for admins, with probes in the same `watch_bays` loop.
- `PAGE` now takes `{cls}` (themes), so every page goes through `render()`. One 401 path was still calling `PAGE.format(body=...)` and would have raised a KeyError. The tests found it and it's fixed. **Please grep for any other `.format(` on PAGE.**
- CSP gained `font-src 'self'`. `account.conf`'s public location regex adds `/forgot`, `/look.css` and `/fonts/*.woff2`.
- New connectors: `AudiobookshelfTalk` and `AudiobookshelfArchives` (subclasses with `accessAllLibraries: True` inside their own walled server). `APP_BAY` maps each to its group, so new-user setup only touches the servers that person's Bays allow.
- Tests: the 40 unit tests in `payload/account-gate/test_*.py` pass on Python 3.10, using a copy with two 3.12-only f-string quotes swapped and an `fcntl` stub (Windows). The CI workflow (Python 3.13) was **not** checked, since GitHub wasn't reachable from this session.

### F30, F31: the two walled Audiobookshelf servers

- `payload/cobra-server-scripts/podman/sgin/abs-walled.sh`: its own pod per server (`ensure_pod NAME PORT:PORT`), data in `/srv/stream/<name>/{config,metadata}`, media mounted **read-only**.
- Talk Radio & Comedy Club: 13379, `dock1a/comedy`. The Archives: 13380, `dock1a/archives`.
- F31 adds `13379, 13380` after `13378` on the first nft line that lists 13378, checks it with `nft -c`, backs it up, then a 2-minute "second SSH login" confirm or auto-rollback. **Check the awk, and whether the first 13378 line is really the LAN/WG accept rule.**
- **Known gap:** `state.sh` (nightly backups) covers the main `audiobookshelf` but not `audiobookshelf-talk` or `audiobookshelf-archives` yet (data in `/srv/stream/<name>/config`). The Archives holds personal recordings, so its progress and users DB should be backed up. Please suggest the cleanest addition.

### F34: wall the existing main Audiobookshelf (Audiobooks Bay, :13378)

- Before: `sgin/audiobookshelf.sh` mounted all of `$DISKS` at `/media` (`ro,rbind`), so it could read comedy and archives too. After: one `-v $DISKS/<dir>:/media/<dir>:ro` each for `AUDIOBOOKS_DIR`, `SESSIONS_DIR`, and `BOOKS_DIR` (the last only until Kavita Books is live). The same container paths mean the existing library paths still resolve. `ABS_ALL_DISKS=1` restores the old mount as an undo. The data folder is untouched; only the container is re-created (`run_container` does `podman rm -f` plus `run`).
- **Please check:** a bind of a subfolder of a separately mounted drive (`/srv/storage/disks/dock1a/...`) is fine rootless with `:ro` and no `:Z` (the SELinux label isn't applied to media). Does Audiobookshelf ever **remove** items or progress from its DB when a library folder disappears, or does it only mark them missing? The owner's old Talk/Archives libraries inside this server rely on that.
- **Not walled yet:** its pod. It's still in the shared "stream" pod, which publishes 13378. Moving it needs the stream pod re-created, which stops every media app, so it's deferred. Suggest the least disruptive way to do that, given `ensure_pod` only creates a pod and `RECREATE_POD=1` removes it with its containers.
- `fixlib.sh` now reads `DISKS` and every `*_DIR` from the podman `lib.sh` (an `eval` of only those assignment lines). Before this, F30 used `$DISKS` without it being set. **Check that eval.**

### F32: front-door routes (it edits live nginx and Authelia files with sed)

- `talk.` and `comedy.` go to `:13379`. The phone-app API skip map becomes `(audio|sessions|talk|comedy)`.
- **`archives.` is removed** from the `$station` map and `server_name`. The Archives is private (old game-night recordings), so the gate never proxies it, and nginx's catch-all rejects the TLS handshake for it. Home Wi-Fi or WireGuard only.
- `player.` (Feishin) is added to the map and server_name, and to Authelia's music rule lists.
- **Please check** the sed expressions against the template (`payload/templates/songofeo.conf`), and whether any `archives.` reference elsewhere (Authelia rules, CORS includes) should also go.

### F33: Feishin

- `payload/cobra-server-scripts/podman/gate/feishin.sh`: `ghcr.io/jeffvli/feishin:latest`, `SERVER_TYPE=navidrome`, `SERVER_URL=https://music.songofeo.com`, `SERVER_LOCK=true`, on `127.0.0.1:9180` in the gate pod.
- **Open question:** Feishin's browser code calls `music.songofeo.com/rest/...` from `player.songofeo.com`. Does nginx's `station-cors*.inc` allow that origin, and do the Subsonic API paths skip Authelia (`$subsonic_api`) so the browser's cross-origin calls aren't redirected to the sign-in? If not, would a same-origin proxy (`player.songofeo.com/rest` going to Navidrome) be cleaner?

### F40: pod health

It's read-only unless run with `--fix`, which asks one question per problem. Calibre-Web is no longer checked: it's retiring for three Kavita instances (Comics, Books, RPG), handled in a separate fix. The old `navidrome-talk` and `navidrome-archives` are only reported, never touched.

## Other things to weigh in on

1. `docs/ACCESS-POINT.md`: EAP772 plus TL-POE260S on an unmanaged-for-now LAN (VLANs later). Any better pick around $100–200 with a local web UI and SSID-per-VLAN?
2. `docs/NEW-POD-IDEAS.md`: anything you'd add or drop for a free form engine (Formidable Forms) with paid tiers later, and a small record label (BPM Records)?
3. The owner currently makes users by hand in each app. The Multi-Pass ticks set the Authelia groups. Is there a simpler way to sync users into Audiobookshelf, Navidrome and RomM?
