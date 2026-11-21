# BAD LAYOUT EXAMPLE: do not copy this style

> **Why this file is here:** this is the cobra run-list README as shipped in **v3.5.1** (2026-11-21), kept word for word as an example of a layout that goes against our company principle of **clear, easy-to-follow information**. The owner tried to follow it and got lost. It was replaced by the one-file checklist in v3.6. The rules that fixed it are in [README-RULES.md](../README-RULES.md).
>
> **What's wrong with it:**
>
> 1. **Preamble before the steps.** Version notes, a philosophy paragraph and an overview table come first. You scroll a long way before step 1.
> 2. **Commands in summary sections.** The overview and "before you start" parts contain real commands, so you start typing and then find out it was only the summary.
> 3. **Several READMEs pointing at each other.** Steps say "see docs/home-wifi" or ROKU-TV.md instead of giving the clicks, so you juggle files.
> 4. **Value-only field tables.** A cell like "DNS to DNS" or "8096 to 8096" reads like text to type. It never says "Dropdown: pick DNS" or "Type 8096".
> 5. **Many actions per step.** One step holds several clicks, commands and tables, so it's easy to lose your place.
> 6. **Troubleshooting mixed into the steps.** "If it goes wrong" tables sit between the actions, so the next real action is hard to find.

---

# Cobra server run list, 2026-11-21 (version 3.5.1)

This is the whole run list, in order. It covers everything since the last cobra-setup README: the TV on home Wi-Fi, the Arcade, the newest Multi-Pass, three walled Audiobookshelf servers, three walled Kavitas (Calibre-Web retiring), Feishin, the eo-art wall covers, The Scoreboard, and a health check of every pod. Nothing already done in the earlier cobra-setup README is repeated.

**New in v3.5.1:** every OPNsense field table now says what to do (pick from the dropdown, or type), not just a value.

**v3.5:** every step was re-checked against current releases on 2026-11-21, and each step starts with a **Checked against** line. The big change is step 3b: RomM 5 changed how it stores roles and when it shows the wizard, so F10 is replaced by RomM's own password reset.

**v3.04:** every command says which of your three PowerShell tabs it goes in (`windows`, `eels@cobra-gate`, `eels@cobra-stream`), and nothing needs an admin window.

**v3.03:** every step is written out click by click and command by command. Each step says what you should see, and has an **If it goes wrong** table: what each result means, what to try next, and which screenshot to send. Menu names were checked against current releases on 2026-11-21 (`docs/VERSIONS.md`): OPNsense 26.1 to 26.7, Jellyfin 12, RomM 5, Authelia 4.39.

**The rule everything here follows:** every copy of the same app is **walled**. Each has its own settings, database, users, keys and port, and reads only its own folders, read-only. Nothing is shared between them.

| Step | Where | What it does |
|---|---|---|
| A | windows tab, OPNsense, both servers | Before you start: your three tabs and versions (5 minutes) |
| 0 | OPNsense, SGIN, phone, Roku | The TV on home Wi-Fi plays Jellyfin (F37 + docs/home-wifi) |
| 1 | the-box | Copies this folder to both servers (F00) |
| 2 | gate and SGIN | Read-only survey of both servers (F01) |
| 3 | SGIN | The Arcade: its own pod (F11), then a password reset if needed (RomM 5) |
| 4 | SGIN | Starts Talk Radio & Comedy Club and The Archives (F30) |
| 5 | SGIN | Walls the Audiobooks server you already have (F34) |
| 6 | SGIN | Opens the four new ports to home and WireGuard (F31) |
| 7 | SGIN | Three walled Kavitas: Comics, RPG Vault, Books (F50) |
| 8 | gate | The newest Multi-Pass: Admin Bays, the Archives tick, three Kavitas (F20) |
| 9 | gate | Front-door routes: talk., comedy., player. Keeps archives. closed (F32) |
| 10 | gate | Front-door routes: books. and gaming. go to their Kavitas (F35) |
| 11 | gate | Feishin, the new music player (F33) |
| 12 | gate | eo-art, the wall-art covers: checked, walled, two new walls (F36) |
| 13 | SGIN and gate | The Scoreboard: daily hiscore collector and the hiscores page |
| 14 | gate and SGIN | Health check of every pod (F40) |
| 15 | you | The "For you to do" list |

Steps 3 to 7 run on cobra-stream (the SGIN), and steps 8 to 12 on the gate. Do the SGIN steps first, because the gate steps point at what they start.

Extra guides in `docs/`:

- `docs/VERSIONS.md`: the software versions these steps were checked against, what changed, and how to check what you run.
- `docs/home-wifi/`: the full home Wi-Fi guide (`HOME-WIFI.md`), the Roku guide (`ROKU-TV.md`) and the security decision log, copied from cobra-server `docs/`.
- `docs/POD-QUICKSTART.md`: the pods you haven't used yet, what each one does, and whether it's worth your time.
- `docs/NEW-POD-IDEAS.md`: new pods for the entertainment complex, for Formidable Forms and BPM Records.
- `docs/ACCESS-POINT.md`: which Wi-Fi access point to buy and every setup step.
- `GROK-HANDOFF.md`: what changed and what to cross-check (the dual-programmer rule).

## How to read this README

- Every grey box holds **one** command. Copy the whole box, paste it, press Enter.
- The explanation for each box is in the text **above** it, never inside it.
- **Your setup:** one ordinary PowerShell window (Windows Terminal, **not** "Run as administrator") with three tabs. Every command says which tab it goes in:

| Tab name | What it is | Its prompt looks like |
|---|---|---|
| `windows` | PowerShell on the-box itself | `PS C:\Users\...>` |
| `eels@cobra-gate` | that tab is logged in to the gate with `ssh eels@10.6.9.10` | `eels@cobra-gate:~$` |
| `eels@cobra-stream` | that tab is logged in to the SGIN with `ssh eels@10.6.9.20` | `eels@cobra-stream:~$` |

- **Nothing in this list needs an admin PowerShell.** The `windows` tab steps (copying files, `scp`, `Resolve-DnsName`) all work in a normal window. Commands on the servers get their extra rights from `sudo`, which asks for eels's password.
- If a server tab says `Connection to 10.6.9.x closed.`, or shows `PS C:\...>` again, the login dropped. Log back in with the same `ssh` line from the table above.
- **OPNsense** steps are clicks in your browser on the-box, at `https://10.6.9.1`. A path like **Firewall → NAT → Destination NAT** means: click Firewall in the left menu, then NAT, then Destination NAT.
- Every script reads first, shows you what it wants to change, and waits for your `y`. Nothing gets deleted. Every changed file gets a backup with a timestamp (`.bak-20261121-...`).
- A line in red that starts with `ERROR:` means the script stopped by itself and changed nothing after that point. Send a screenshot of it.
- If a screen doesn't match what this README says (a menu name, a field, a button), **stop** and send a screenshot. Software changes its menus; your screen wins.

### How to send a screenshot

| From | How |
|---|---|
| the-box | Press **Windows + Shift + S**, drag a box around the window, then paste it (Ctrl+V) into the Claude chat. For a terminal, scroll so the command **and** its last lines are both visible. |
| the phone (S21) | Press **Power + Volume down** together, then share the picture to the Claude app. |
| the TV | Take a photo of the screen with the phone. |
| A long terminal output | In the terminal, select the text with the mouse, right-click to copy, and paste it into the chat. Text is better than a picture for long output. |

## The rule this list follows: users are still made by hand for now

The Multi-Pass ticks (Music, Talk Radio, The Archives, Admin) **do** work at the gate: they put people in the Authelia groups that open each Bay's door. Making the person's account **inside** each app (the three Audiobookshelfs, the three Kavitas, Navidrome, RomM) is still mostly done by hand, in that app's own Users page. The Multi-Pass can do it for an app once that app is switched on in `apps.json` with its admin token. Step 8 adds the two new Audiobookshelf servers switched **off**, so for now you make their users yourself.

---

## Step A. Before you start: versions and terminal tabs

*Checked against (2026-11-21): OPNsense 26.1 to 26.7.9, Podman 5.4.x (Debian 13), Windows 11 PowerShell 5.1 and OpenSSH client. See `docs/VERSIONS.md`.*

This step changes nothing. It makes sure the menu names below match your screens, and opens the three terminal tabs the rest of the list uses.

### A1. OPNsense version (the-box, browser)

1. On the-box, disconnect **PIA** (click its tray icon, then Disconnect). PIA hides the `10.6.9.x` addresses.
2. Open your browser and go to `https://10.6.9.1`. Log in to OPNsense (your web password and TOTP code).
3. Click **System → Firmware → Status**.
4. Write down the version, for example `OPNsense 26.7.9_3`.

**What you should see:** a version that starts with `26.1` or `26.7`. This README was checked against those.

| If you see | What it means | Do this |
|---|---|---|
| A version starting with `25.` or older | Menu names in step 0 are different on your box (for example "Port Forward" instead of "Destination NAT") | Send a screenshot of the Status page before step 0 |
| `27.` | Newer than this README | Send a screenshot; Claude checks the 27.1 notes first |
| **Firewall → Rules** opens a page with an **interface selector** at the top | The new rules page (26.7). Pick **WAN** in the selector when a step says "WAN" | Nothing; that's expected |
| **Firewall → Rules** shows a list of interfaces in the left menu instead | The legacy pages (older build, or the `os-firewall-legacy` plugin) | Click **WAN** in that list instead; the fields are the same |

### A2. Check your three tabs

You already have one PowerShell window open with three tabs: `windows`, `eels@cobra-gate` and `eels@cobra-stream`. Click each tab and check its prompt matches the table in "How to read this README". If a server tab isn't logged in, log it in again:

In the `eels@cobra-gate` tab, if it shows `PS C:\...>`:

```powershell
ssh eels@10.6.9.10
```

In the `eels@cobra-stream` tab, if it shows `PS C:\...>`:

```powershell
ssh eels@10.6.9.20
```

Each asks `eels@10.6.9.x's password:`. Type eels's password (nothing shows while you type) and press Enter.

**A 4th tab, now and then:** F31 and F37 ask you to prove a **new** login still works. When they do, press **Ctrl + Shift + T** for a temporary 4th tab, run the `ssh eels@10.6.9.20` line in it, then close it again.

| If you see | What it means | Do this |
|---|---|---|
| `ssh: connect to host ... Connection timed out` | The `windows` tab can't reach the server | Disconnect PIA, then try again. Still failing: the server may be off. Check cobra-command (Proxmox) at `https://10.6.9.3:8006` |
| `Permission denied, please try again.` | Wrong password | Type it again slowly. Three wrong tries closes the connection; run the `ssh` line again |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` | The server was rebuilt and has a new key | Stop and send a screenshot. Don't delete anything |
| The window's title says **Administrator** | It's an admin window | Close it and open a normal one. Nothing here needs admin |

### A3. Podman and image versions (`eels@cobra-gate` tab, then `eels@cobra-stream` tab)

In the **`eels@cobra-gate` tab**, check the podman version:

```bash
podman --version
```

You should see `podman version 5.4.2` (or another `5.4.x`).

Do the same in the **`eels@cobra-stream` tab**:

```bash
podman --version
```

Then, in the **`eels@cobra-stream` tab**, list which app images have an update waiting. It asks for eels's sudo password once and changes nothing:

```bash
sudo machinectl shell podsvc@ /usr/bin/podman auto-update --dry-run
```

**What you should see:** a table with `UPDATED` showing `false` or `pending` for each app.

| If you see | What it means | Do this |
|---|---|---|
| `jellyfin ... pending` | The next auto-update would move Jellyfin to version 12, a big upgrade | Don't update it today. Finish step 0 first. `docs/VERSIONS.md` section 3 has the checklist for later |
| `romm ... pending` | RomM 5.x is waiting | Fine. Step 3 works on the version you run now |
| Anything else `pending` | A normal update | Nothing to do today |
| `Error: ... no such file` or an empty list | podsvc's units don't use auto-update labels | Fine. Skip it |

---

## Step 0. The TV plays Jellyfin today

*Checked against (2026-11-21): OPNsense 26.7.9 (Destination NAT, Register rule, new rules page, Unbound ACL default), nftables on Debian 13, Jellyfin 10.11 and 12, Roku OS 15, Android 15/16 (One UI 7/8). See `docs/VERSIONS.md`.*

This step stands on its own. You can do it before the rest of the list. The full guides are `docs/home-wifi/HOME-WIFI.md` (phones on home Wi-Fi) and `docs/home-wifi/ROKU-TV.md` (the TV). Your risk decision is in `docs/home-wifi/DECISION-LOG.md`: the Xfinity Wi-Fi (`10.0.0.0/24`) reaches the station with a password, no WireGuard at home.

**Never change anything on the Xfinity router or the work laptop for this.**

Pick the one that matches where the Roku is plugged in:

- **0a:** the Roku is on the **Omada switch** (the 50 ft cable, any port except 6). This is the simplest, with nothing to set up.
- **0b:** the Roku stays on the **Xfinity router** or the Xfinity Wi-Fi. This needs three pieces, in order.

### 0a. Roku on the Omada switch

1. Plug the Roku's network cable into any free port on the Omada switch **except port 6**.
2. On the TV: **Settings → Network → Set up connection → Wired**. It should say **Connected**, with an IP address starting `10.6.9.`.
3. Open the **Jellyfin** app on the Roku. Choose **Add Server** (or Settings → Change server), and type:

```
https://tv.songofeo.com
```

4. Log in with your Jellyfin username and password.

| If you see | What it means | Do this |
|---|---|---|
| The Roku's IP starts with `10.0.0.` | It's still on Xfinity Wi-Fi, not the cable | On the Roku: Settings → Network → Set up connection → **Wired** |
| No IP at all | The cable or port isn't live | Try another switch port (not 6). Photo of the Network → About screen |
| "Unable to connect to server" | The Roku can't reach the gate | Photo of the Roku's Settings → Network → About screen, and send it |

### 0b. Roku on the Xfinity side: three pieces, in this order

| Piece | Where | Why |
|---|---|---|
| 1. F37 | `eels@cobra-stream` tab | The SGIN's own firewall only lets the cobra LAN and WireGuard reach Jellyfin. The TV's address is `10.0.0.x`, so it's dropped. F37 adds one line that lets `10.0.0.0/24` reach port 8096 only. |
| 2. OPNsense | the-box browser | Lets `10.0.0.x` in on WAN, and passes port 8096 through to the SGIN. |
| 3. The test | phone, then the Roku | Proves the path works before you fiddle with the TV. |

#### Piece 1: F37 on the SGIN

F37 must already be on the SGIN. If you haven't done step 1 yet, do it now (it only copies files), then come back.

In the **`eels@cobra-stream` tab**, first look whether the rule is already there:

```bash
sudo nft list ruleset | grep 10.0.0.0
```

- It prints a line ending in `tcp dport 8096 accept`: piece 1 is done. Go to piece 2.
- It prints nothing: run F37 in the same `eels@cobra-stream` tab, as **eels** (not podsvc):

```bash
bash /tmp/cobra-fix/F37-sgin-firewall-roku-tv.sh
```

**What you should see**, in order:

1. `==> 1/4 Look first (read-only)`, then the LAN's line and the port list.
2. `==> 2/4 Proposed change`, then a diff with one new line starting `+` and containing `ip saddr 10.0.0.0/24 tcp dport 8096 accept`.
3. `==> 3/4 Checking the new rules without loading them (nft -c)`, then `Load it? [y/N]`. Type `y` and press Enter.
4. A yellow line: `WARNING: Open a NEW terminal on the-box now and log in:  ssh eels@10.6.9.20`, then a 2-minute question.

For that question, press **Ctrl + Shift + T** for a temporary 4th tab, and log in from it:

```powershell
ssh eels@10.6.9.20
```

If you get the `eels@cobra-stream:~$` prompt, go back to the **`eels@cobra-stream` tab**, type `y` and press Enter. You should see `==> Kept. The Xfinity side (10.0.0.0/24) can reach Jellyfin on 8096, and nothing else.` Close the 4th tab.

| If you see | What it means | Do this |
|---|---|---|
| `bash: /tmp/cobra-fix/F37-sgin-firewall-roku-tv.sh: No such file or directory` | Step 1 hasn't copied this version yet (a reboot empties `/tmp`) | Do step 1, then run F37 again |
| `ERROR: couldn't find the LAN's tcp port list` | The SGIN's firewall file isn't laid out the way the manual made it | Run `sudo cat /etc/nftables.conf` and send the text |
| `ERROR: nft refused the new file; nothing changed` | A syntax problem | Send a screenshot of the whole output |
| `ERROR: no confirmation, so the old rules are back` | You didn't type `y` within 2 minutes | Run F37 again. Nothing is broken |
| The new SSH tab can't log in | The new rules would lock you out | **Don't** type `y`. Wait 2 minutes; the old rules come back by themselves. Send a screenshot |

#### Piece 2: OPNsense (the-box browser, `https://10.6.9.1`)

**2.1 Let the Xfinity side in on WAN**

1. Click **Interfaces → [WAN]**. On 26.7.6 and later, if that page looks different, click **Interfaces → Assignments** and open the **WAN** entry.
2. Scroll to **Generic configuration**.
3. **Untick Block private networks.** Leave **Block bogon networks** as it was.
4. Click **Save** at the bottom, then **Apply changes** at the top.

**What you should see:** a green "The changes have been applied successfully" bar.

**2.2 The Destination NAT rule**

1. Click **Firewall → NAT → Destination NAT**.
2. If a rule called `Roku to Jellyfin` already exists, click its **pencil** icon to edit it. If not, click **+** (Add).
3. Fill it in exactly like this:

| Field | How to set it |
|---|---|
| Disabled | Leave the tick box **empty** |
| Interface | Dropdown: pick **WAN** |
| TCP/IP Version | Dropdown: pick **IPv4** |
| Protocol | Dropdown: pick **TCP** |
| Source | Click **Advanced** if Source is hidden. Dropdown: pick **Single host or Network**, then type `10.0.0.0/24` in the box next to it (on some pages you just type `10.0.0.0/24`) |
| Source port | Leave it on **any** |
| Destination | Dropdown: pick **WAN address** |
| Destination port | **One box:** type `8096`. **Two dropdowns ("from" and "to"):** pick **(other)** in both and type `8096` in both |
| Redirect target IP | Dropdown: pick **Single host or Network** if there is one, then type `10.6.9.20` |
| Redirect target port | Type `8096` (or pick **(other)** and type `8096`) |
| Description | Type `Roku to Jellyfin` |
| **Firewall rule** | Dropdown: pick **Register rule** (never Manual) |

4. Click **Save**, then **Apply**.

**Firewall rule is the key field.** Since OPNsense 26.1 its default is **Manual**, which forwards nothing: the TV just times out. Older guides call it "Filter rule association" and say it's automatic. That's no longer true.

**2.3 Check the rule was made**

1. Click **Firewall → Rules**. In the interface selector at the top, pick **WAN**.
2. Turn on **Inspect** (a switch or button near the top of the list).
3. Expand **Automatically generated rules** (there can be two groups; the one at the **end** of the list holds NAT rules).

**What you should see:** a pass rule with the description `Roku to Jellyfin`, source `10.0.0.0/24`, destination `10.6.9.20`, port `8096`. **Take a screenshot of this list now** and keep it. It's the first thing Claude asks for if the TV fails.

| If you see | What it means | Do this |
|---|---|---|
| No `Roku to Jellyfin` under the generated rules | The Destination NAT rule is still on **Manual** | Back to 2.2, set **Firewall rule** to **Register rule**, Save, Apply |
| No **Inspect** switch | An older rules page | Look under **Firewall → Rules → WAN** for a rule called `NAT Roku to Jellyfin` |
| No **Firewall rule** field in 2.2 | An older OPNsense build | Look for **Filter rule association** instead and pick **Add associated filter rule**. Send a screenshot of the form if neither is there |

#### Piece 3: the test (phone first, then the Roku)

**Don't test from the-box.** the-box is on the cobra LAN, and `10.0.0.2:8096` never loops back to it, so the-box always times out. That's expected.

1. On the phone: turn **WireGuard off** (WireGuard app → switch off the tunnel).
2. On the phone: connect to the **Electronomicon** Wi-Fi (or Electronomicon_EXT).
3. Open **Chrome** on the phone and type:

```
http://10.0.0.2:8096
```

**What you should see:** the Jellyfin login page within a few seconds.

Then on the Roku: open the **Jellyfin** app, choose **Add Server**, type `http://10.0.0.2:8096`, and log in.

Optional, so Jellyfin doesn't cap the TV's quality as "remote": in Jellyfin (on the-box, `https://tv.songofeo.com`), go to **Dashboard → Networking**. Under **LAN networks**, add `10.0.0.0/24` and **Save**. On Jellyfin 12, if Networking has moved, send a screenshot of the Dashboard menu.

#### If the phone test times out: find which piece is blocking

Do these checks in order and stop at the first one that fails.

**Check 1: is the phone really on the Xfinity side?** On the phone: **Settings → Connections → Wi-Fi →** the gear by Electronomicon. The IP address must start with `10.0.0.`, and WireGuard must be off.

**Check 2: does OPNsense see the request?** On the-box, click **Firewall → Log Files → Live View**. In the filter box, type `8096`. Now reload `http://10.0.0.2:8096` on the phone and watch the list for 10 seconds.

| Live View shows | What it means | Next fix |
|---|---|---|
| Nothing at all | The request never reached OPNsense, or isn't logged | Make sure **Block private networks** is unticked (2.1) and you pressed Apply. Then check **System → Settings → Logging**: if default block rules aren't logged, Live View stays empty. Screenshot the Live View page |
| A **red** line (block) from `10.0.0.x` to `10.0.0.2:8096` | OPNsense blocks it: there's no pass rule | 2.2: **Firewall rule** must be **Register rule**. Then 2.3 to confirm. Screenshot the generated-rules list |
| A **green** line (pass) to `10.6.9.20:8096` | OPNsense passed it; the SGIN dropped it | Piece 1. In the `eels@cobra-stream` tab, run the `nft list ruleset` check again. Screenshot it |

**Check 3: does the SGIN see it?** In the **`eels@cobra-stream` tab**, this watches for the phone's traffic for 20 seconds while you reload the page on the phone. It needs `tcpdump`; if the command says "not found", skip this check.

```bash
sudo timeout 20 tcpdump -ni any 'tcp port 8096 and net 10.0.0.0/24'
```

| tcpdump shows | What it means | Do this |
|---|---|---|
| Lines with `10.0.0.x > 10.6.9.20.8096` and answers back | The whole path works | The problem is on the phone (Private DNS, a VPN, Chrome's "secure DNS"). See HOME-WIFI.md step 6 |
| Lines **in** only, no answers | The SGIN's firewall drops it | Piece 1 (F37) |
| Nothing | OPNsense didn't forward it | Check 2 |

**What to send Claude if it still fails:** (1) the Live View screenshot while the phone reloads, (2) the generated-rules screenshot from 2.3, (3) the output of the `nft list ruleset | grep 10.0.0.0` command, and (4) a phone screenshot of the timeout.

### 0c. Phones on home Wi-Fi, by name (no WireGuard)

This lets the phone open `https://music.songofeo.com` and the other station names at home, through the gate. Follow `docs/home-wifi/HOME-WIFI.md` steps 1 to 6. It's all OPNsense pages on the-box, plus the phone's Wi-Fi settings. Four things trip people up there:

1. **Unbound Access Lists:** some upgrades to 26.1.6 changed the default to **Deny**. Always add the explicit `xfinity-side` Allow entry for `10.0.0.0/24` (HOME-WIFI.md step 3).
2. **Host overrides:** the list in HOME-WIFI.md step 4 includes `audio`, `talk`, `player`, `ebooks`, `account`, `art` and `auth`. **Never** add `archives` (step 9 keeps it closed), `vault`, `status`, `www`, `vpn`, the bare `songofeo.com`, or a `*`.
3. **The WAN rule for DNS** goes in **Firewall → Rules**, with WAN picked in the selector, then **+**. Its **Destination port** is port 53. With one box, type `53`. With two dropdowns ("from" and "to"), pick **DNS** in both (or **(other)** and `53` in both).
4. On home Wi-Fi the gate asks for your password **and** your TOTP code. That's on purpose: Authelia treats `10.0.0.0/24` as its own `homewifi` network.

Check from the **`windows` tab** (PowerShell, PIA off). This asks OPNsense's Unbound for a name:

```powershell
Resolve-DnsName tv.songofeo.com -Server 10.0.0.2 -DnsOnly
```

**What you should see:** an answer of `10.0.0.2`. Then, still in the `windows` tab, make sure the LAN still gets the gate's own address:

```powershell
Resolve-DnsName tv.songofeo.com -DnsOnly
```

**What you should see:** `10.6.9.10`.

| If you see | What it means | Do this |
|---|---|---|
| The first check times out | Unbound doesn't answer on WAN, or the access list denies | HOME-WIFI.md step 3 (WAN in Network Interfaces, and the Allow entry). Screenshot **Services → Unbound DNS → Access Lists** |
| The first check gives the public IP (`73.x.x.x`) | The host override is missing or not applied | HOME-WIFI.md step 4, then **Apply**. Screenshot **Services → Unbound DNS → Overrides** |
| The second check gives `10.0.0.2` | The overrides leaked to the LAN | **Stop.** Disable the overrides (untick Enabled, Apply) and send both screenshots |
| The phone gets "site can't be reached" for every name | Phone DNS isn't `10.0.0.2`, or Private DNS is on | HOME-WIFI.md step 6. Phone screenshot of the Wi-Fi IP settings |

---

## Step 1. Copy the fix list to both servers (the-box)

*Checked against (2026-11-21): Windows 11 PowerShell 5.1 (no admin needed for `-ExecutionPolicy Bypass -File`), OpenSSH scp. See `docs/VERSIONS.md`.*

This copies this whole folder to `/tmp/cobra-fix` on the gate and the SGIN. It changes nothing else. A reboot empties `/tmp`, so after a server reboots, run this step again.

1. Disconnect **PIA**.
2. In File Explorer, open `V:\=ClaudeCode=`. Right-click `cobra-runlist-2026-11-21-v3.5.1.zip` and choose **Extract All**. Keep the folder it suggests and click **Extract**.
3. In the **`windows` tab**, go into the unzipped `cobra-fix` folder:

```powershell
cd "V:\=ClaudeCode=\cobra-runlist-2026-11-21-v3.5.1\cobra-fix"
```

4. Still in the `windows` tab, run the copy script:

```powershell
powershell -ExecutionPolicy Bypass -File .\F00-copy-to-servers.ps1
```

It asks for eels's password up to six times (three per server), unless the-box already has an SSH key there.

**What you should see,** in green: `==> gate (cobra-gate) answers on port 22`, `==> SGIN (cobra-stream) answers on port 22`, `==> staged ... files`, two `copying to /tmp/cobra-fix` lines each followed by a list of `F..` file names, and finally `Copied. Next: README.md, step 2`.

| If you see | What it means | Do this |
|---|---|---|
| `ERROR: can't reach gate ... on 10.6.9.10:22` (red) | PIA is on, or the-box isn't on the cobra LAN | Disconnect PIA. Check the-box's IP is `10.6.9.50` (`ipconfig` in the `windows` tab) |
| `cd : Cannot find path` | The folder was extracted somewhere else | In File Explorer, open the extracted folder, click the address bar, copy the path, and use it in the `cd` line |
| `... cannot be loaded because running scripts is disabled` | The `-ExecutionPolicy Bypass` part was left off | Copy the whole box again |
| `Permission denied` | Wrong password | Run F00 again |

---

## Step 2. Survey both servers (read-only)

*Checked against (2026-11-21): Podman 5.4.2, systemd-container (machinectl) on Debian 13. See `docs/VERSIONS.md`.*

This step changes nothing. It writes a report on each server. Send both reports to Claude or Grok before going on, so any surprise turns up before a single file changes.

In the **`eels@cobra-gate` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F01-survey.sh
```

It asks `[sudo] password for eels:` once. Then you should see `Connected to the local host. Press ^] three times within 1s to exit session.`, the report (headings starting with `##`), and at the end `Connection to the local host terminated.`

In the **`eels@cobra-stream` tab**, the same:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F01-survey.sh
```

Bring the two reports to the-box. In the **`windows` tab**, go to the fix-list folder:

```powershell
cd "V:\=ClaudeCode=\cobra-runlist-2026-11-21-v3.5.1\cobra-fix"
```

Still in the `windows` tab, copy the gate's report:

```powershell
scp eels@10.6.9.10:/tmp/cobra-fix-survey-gate.txt .
```

Then copy the SGIN's report (`windows` tab):

```powershell
scp eels@10.6.9.20:/tmp/cobra-fix-survey-sgin.txt .
```

Drag both `.txt` files from File Explorer into the Claude chat.

| If you see | What it means | Do this |
|---|---|---|
| `scp: /tmp/cobra-fix-survey-gate.txt: No such file or directory` | The survey wrote into podsvc's private `/tmp` | Select the survey text in the terminal, copy it, and paste it into the chat instead |
| `Failed to connect to bus` or `machinectl: command not found` | `systemd-container` is missing | Send a screenshot |
| `ERROR: run this as podsvc` | The `sudo machinectl shell podsvc@` part was left off | Copy the whole box again |

**Known results from the 2026-11-21 survey** (so they don't surprise you):

- **SGIN:** `romm` shows `Address in use` on port 5000. Step 3 fixes it.
- **SGIN:** `icecast` and `radio` are missing. The radio was never set up, which is fine.
- **SGIN:** `dock1a/comedy` and `dock1a/archives` are missing. Step 4 shows how to make them.
- **gate:** `homepage` shows `000`. Step 14 looks at it.
- **gate:** `no apps.json`. Step 8 will stop safely (see step 8).

---

## Step 3. The Arcade: get RomM working, then its setup wizard (SGIN)

*Checked against (2026-11-21): Podman 5.4.2 Quadlet (`.pod` files work on 5.x), RomM 5.0 to 5.2 (setup wizard only on an empty database; roles are now user/admin; temporary password in the logs). See `docs/VERSIONS.md`.*

**What's wrong:** RomM has been broken for days. Its page loads, but its engine crashes with `Address in use` on port 5000. RomM and Kavita Comics share the "stream" pod, which is one network inside, and both need port 5000 in there. Kavita gets it first. With no engine, the setup wizard can never show.

**The fix (F11):** RomM and its database move into a pod of their own, called `arcade`. The address stays `http://10.6.9.20:8080` and `arcade.songofeo.com`, so the gate, the firewall and the Multi-Pass don't change. No data moves; RomM's database stays in `/srv/stream/romm/db`, and your ROMs on dock1b are never touched.

### 3a. F11: the Arcade's own pod (SGIN)

**Run it when nobody is watching the TV.** It restarts the stream pod, so Jellyfin, music, audiobooks, comics and Calibre-Web are off for about a minute. It asks before that part.

In the **`eels@cobra-stream` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F11-sgin-arcade-own-pod.sh
```

**What you should see**, in order:

1. `==> 1/5 Look first (read-only)`. It shows `Pod=stream.pod` for `romm.container` and `romm-db.container`, the stream pod's `PublishPort=` lines (including `8080:8080`), and RomM's last log lines with `Address in use`.
2. `==> 2/5 The four Quadlet changes (all four, or none)`. Four diffs, each followed by `Write this change ...? [y/N]`. Type `y` four times:
   - `arcade.pod`: a new file with `PodName=arcade` and `PublishPort=8080:8080`.
   - `stream.pod`: the `PublishPort=8080:8080` line gets a `# ` in front (commented out, not deleted).
   - `romm.container`: `Pod=stream.pod` becomes `Pod=arcade.pod`.
   - `romm-db.container`: the same.
3. `==> 3/5 Restart (about a minute of no TV, music or books)`, then `Restart the stream pod and start the Arcade pod now? [y/N]`. Type `y`.
4. `==> 4/5 Check`. It waits up to 2 minutes for Jellyfin, then prints a code for each app. You want `200` for each (`302` or `401` are fine too), and no `000`. Then `RomM heartbeat: {...}`. A yellow line saying the heartbeat gave no JSON but the engine no longer clashes is also OK: RomM 5 may answer differently there, and the change is kept.
5. `==> 5/5 Result`, then `==> Done. RomM runs in its own pod (arcade) ...`.

Then one of two lines:

- `The setup wizard is ON.` On the-box, open `http://10.6.9.20:8080` in the browser. You should see RomM's setup screen. Make the new admin with a **new** password and save it in Vaultwarden. Skip 3b.
- `The wizard is off (RomM already has an admin). Next: README step 3b ...` RomM works now, but it still has the old admin you can't log in as. Go to **3b**.

| If you see | What it means | Do this |
|---|---|---|
| `ERROR: romm.container isn't in stream.pod` | RomM is set up differently than the survey showed | Send a screenshot of the whole output. Nothing was changed |
| `ERROR: stream.pod has no plain PublishPort=8080:8080 line` | The pod file is laid out differently | Run `sudo machinectl shell podsvc@ /usr/bin/cat .config/containers/systemd/stream.pod` and send the text |
| `the four changes only work together, so the ones you said yes to were put back` | You said no to one diff | Nothing restarted. Run F11 again and answer `y` to all four |
| Any `000` in step 4/5 | That app didn't come back | Answer `y` to **Put everything back the way it was?** Everything returns to how it was. Send a screenshot |
| `RomM's engine still says 'Address in use'` or `RomM doesn't answer at all` | RomM started but its engine still isn't up | Answer `y` to put everything back. Then run `sudo machinectl shell podsvc@ /usr/bin/podman logs --tail 30 romm` and send the text |

**Afterwards, check from the-box:** open `http://10.6.9.20:8080` in the browser. You should see RomM's sign-in or setup screen, not a blank page or an error.

### 3b. If F11 says the wizard is off: reset the old admin's password (RomM 5)

**Why not F10 any more:** your RomM is version 5. RomM 5 shows the setup wizard only on a completely **empty** database, and it stores roles as plain text (`user` / `admin`). The survey shows `role varchar(20)`. F10 was written for RomM 3 and 4. It stops by itself with `ERROR: RomM's role column looks different than expected` and changes nothing, so don't run it. RomM 5's own password reset is simpler, and it keeps every game, save and user.

**3b.1 Find the admin's username.** In the `eels@cobra-stream` tab, this lists RomM's accounts and their roles. It reads only, and asks for eels's sudo password:

```bash
sudo machinectl shell podsvc@ /usr/bin/podman exec romm-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" romm -e "SELECT username, email, role FROM users;"'
```

**What you should see:** a small table. Note the `username` (and `email`) on the line whose role is `admin` (or `ADMIN`).

**3b.2 Ask for a reset.** On the-box, open `http://10.6.9.20:8080` in the browser. On the login page, click **Forgot password?**, type that username or email, and send it.

**3b.3 Read the temporary password.** RomM 5 prints it in its own log. In the `eels@cobra-stream` tab:

```bash
sudo machinectl shell podsvc@ /usr/bin/podman logs --tail 40 romm
```

**What you should see:** a line near the end that mentions a reset or a temporary password for that user.

**3b.4 Log in and change it.** Log in at `http://10.6.9.20:8080` with the username and the temporary password. Then go to your profile and set a **new** password, and save it in Vaultwarden.

| If you see | What it means | Do this |
|---|---|---|
| No **Forgot password?** link | This RomM build has it switched off | Send a screenshot of the login page |
| No password line in the logs | The reset went by email, or the log rolled over | Run the logs line again with `--tail 200`. Still nothing: copy the last 40 lines into the chat |
| The SELECT says `Access denied` | The database password variable has another name in this image | Send the screenshot. Nothing was changed |
| You'd rather start RomM completely empty | That's the "empty database" wizard path | Tell Claude. It needs a small change to the reset script for the new arcade pod first (`romm-reset.sh` still assumes the stream pod) |

After this step the Multi-Pass still has the **old** RomM admin login. Fixing that is on the "For you to do" list (item 3).

---

## Step 4. Start Talk Radio & Comedy Club and The Archives (SGIN)

*Checked against (2026-11-21): Audiobookshelf 2.38 (API keys under Settings, `/ping`). See `docs/VERSIONS.md`.*

The station has **three** Audiobookshelf servers. Your rule is that every copy of the same app is **walled**: each has its own settings, database, users, API key and port, and reads only its own folders, read-only. Nothing is shared between them. Being on one server gives a person nothing on the other two. This step starts the two new ones, and step 5 walls the one you already have.

| Bay | Address at home | Reads (read-only) | From outside |
|---|---|---|---|
| Audiobooks (already running) | `http://10.6.9.20:13378` | `dock1a/audiobooks`, `dock1a/sessions` (and `dock1a/books` until Kavita Books takes over) | `https://audio.songofeo.com`, `sessions.` |
| Talk Radio & Comedy Club | `http://10.6.9.20:13379` | `dock1a/comedy` | `https://talk.songofeo.com` and `comedy.` |
| The Archives | `http://10.6.9.20:13380` | `dock1a/archives` | **none**: home Wi-Fi `cobra`, wired, or WireGuard only |

**Why Audiobookshelf:** it remembers each person's spot inside a 2-hour show, keeps bookmarks, and plays at 1.25x or 1.5x. Its phone app also downloads for offline listening. Podcast-only pods (like Podgrab or PinePods) are built to pull RSS feeds. They're weaker with long local files and give each person a worse saved spot. Navidrome treats every file as a song, so it loses your place. Audiobookshelf is the best fit.

**Why The Archives has no outside address:** it holds the old game-night recordings, which are personal. So it isn't reachable from the internet at all, not even behind the gate's sign-in. It has its own users, and nobody is added to it unless you do it.

In the **`eels@cobra-stream` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F30-sgin-talk-archives.sh
```

If it says a folder is missing, it prints the exact `mkdir` line to run as eels. Run that line, then run F30 again.

At the end it prints a first-time setup list for each server: the root user, the libraries, the users and an API key. Do that list in a browser on the-box. If the pages don't load from the-box yet, do step 6 (the firewall) first, then come back to the list.

**The first-time list, in short** (F30 prints it with more detail):

1. Open `http://10.6.9.20:13379`. Make the root user with its own password, and save it in Vaultwarden.
2. Settings, Libraries, Add: "Talk Radio" (type **Book**) and "Comedy Club" (type **Book**), each pointing at its own folder under `/media/comedy/`.
3. Settings, Users, Add: one user per person who has Talk Radio on their pass. Use the **same** username as their gate account.
4. Settings, API Keys, Add, name it `eo-account`. Keep the token for step 8.
5. Do the same on `http://10.6.9.20:13380` with a different root password and one library, "The Archives" at `/media/archives`. Only add the people you choose.

**What you should see:** `==>` lines for each server: the pod made (`audiobookshelf-talk` on 13379, `audiobookshelf-archives` on 13380), the folders mounted read-only, then the first-time setup list.

| If you see | What it means | Do this |
|---|---|---|
| `ERROR: ... /srv/storage/disks/dock1a/comedy is missing` (or `archives`) | The folder doesn't exist yet (the survey said so) | Copy the exact `sudo mkdir ...` line F30 printed, paste it in the **`eels@cobra-stream` tab** as eels (not inside machinectl), then run F30 again |
| `Error: ... address already in use` for 13379 or 13380 | Something else holds that port | Run `ss -ltnp | grep -E '1337[89]|13380'` in the `eels@cobra-stream` tab and send the text |
| `http://10.6.9.20:13379` doesn't load from the-box | The SGIN firewall doesn't open it yet | Do step 6, then try again |
| The page loads but the library is empty | The folders are new and empty | Copy shows into `\\cobra-stream\dock1a\comedy` from the-box, then Library → Scan in Audiobookshelf |

**Screenshot to send if stuck:** the last 20 lines of F30's output.

---

## Step 5. Wall the Audiobooks server (SGIN)

*Checked against (2026-11-21): Audiobookshelf 2.38. See `docs/VERSIONS.md`.*

The Audiobooks server already exists, so this script doesn't make a new one. Up to now it could read **every** drive, including the comedy and archives folders. This step re-creates its container so it reads only its own folders: audiobooks, sessions, and books until Kavita Books is live. The folders are mounted at the same paths, so its libraries, users and everyone's saved spot stay exactly as they are.

Run step 4 first, so Talk and Archives have their new homes before this server stops reading them.

In the **`eels@cobra-stream` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F34-sgin-audiobooks-wall.sh
```

Afterwards, any old "Talk Radio & Comedy Club" or "The Archives" library **inside** the Audiobooks server shows its items as missing. The files themselves are fine. Once the new servers have everything, delete those two libraries in `http://10.6.9.20:13378`, under Settings, Libraries.

If something you still need goes missing, this line puts back the old mounts (`eels@cobra-stream` tab):

```bash
sudo machinectl shell podsvc@ /usr/bin/env ABS_ALL_DISKS=1 bash /tmp/cobra-fix/payload/cobra-server-scripts/podman/sgin/audiobookshelf.sh
```

One part of the wall waits for later: the Audiobooks server still runs in the shared "stream" pod with Jellyfin and the others. Moving it to its own pod means re-creating that pod, which stops every media app at once, so it's a quiet-evening job. Ask Claude for it when you're ready. It shares no data, users or libraries in the meantime.

**What you should see:** a diff of `audiobookshelf.sh`'s mounts (one `-v .../audiobooks:/media/audiobooks:ro` line per folder instead of the whole drive), your `y`, the container re-made, then `200` from `http://127.0.0.1:13378/ping`.

| If you see | What it means | Do this |
|---|---|---|
| `000` at the end | Audiobookshelf didn't come back | Run the undo line above (`ABS_ALL_DISKS=1 ...`), then send a screenshot |
| Books show as **missing** in the Audiobooks library | That book lives outside audiobooks, sessions or books | Send the book's folder path. Nothing is deleted; Audiobookshelf only marks it missing |
| Everyone's listening progress is gone | It shouldn't be: the data folder isn't touched | Stop, run the undo line, send a screenshot |

---

## Step 6. Open the four new ports to home and WireGuard (SGIN)

*Checked against (2026-11-21): nftables on Debian 13. See `docs/VERSIONS.md`.*

The SGIN's firewall only lets the LAN and WireGuard reach the ports on its list. This script adds the four new walled servers next to 13378 (the main Audiobookshelf): 13379 (Talk Radio), 13380 (The Archives), 5001 (Kavita Books) and 5002 (Kavita RPG Vault). Use this script instead of step 1 of the cobra-server Kavita runbook: it adds the Kavita ports too, with the same safe rollback. It runs as **eels**, not podsvc, because the firewall belongs to root.

**Safety:** after it loads the new rules, it asks you to open a **second** SSH login within 2 minutes. If you don't confirm, the old rules come back by themselves, so a mistake can't lock you out.

In the **`eels@cobra-stream` tab**:

```bash
bash /tmp/cobra-fix/F31-sgin-firewall-talk-archives.sh
```

When it says "Open a NEW terminal", press **Ctrl + Shift + T** for a temporary 4th tab and run this in it. If it logs in, go back to the `eels@cobra-stream` tab and type `y`.

```powershell
ssh eels@10.6.9.20
```

Close the 4th tab afterwards.

**What you should see:** `to add: 13379 13380 5001 5002`, a diff of one line in `/etc/nftables.conf`, `Load it? [y/N]`, then the 2-minute second-login check, then `==> Kept.`

| If you see | What it means | Do this |
|---|---|---|
| `13379 13380 5001 5002 are already open. Nothing to do.` | Already done | Go on |
| `ERROR: couldn't find the LAN's port list` | The firewall file is laid out differently | Run `sudo cat /etc/nftables.conf` and send the text |
| The second login fails | The new rules would lock you out | Don't type `y`. Wait 2 minutes; the old rules come back |
| After this, F37's `10.0.0.0/24` line is gone | It shouldn't be (separate line), but check | Run `sudo nft list ruleset | grep 10.0.0.0`. If empty, run F37 again |

---

## Step 7. Three walled Kavitas: Comics, RPG Vault and Books (SGIN)

*Checked against (2026-11-21): Kavita 0.9.1.4 (one forced re-login; Docker port set by the run command, not inside Kavita). See `docs/VERSIONS.md`.*

Calibre-Web is retiring, and Kavita takes over the books because its pages are simpler. There are exactly three Kavitas, one per wall:

| Kavita | Address at home | Reads (read-only) | From outside |
|---|---|---|---|
| Comics | `http://10.6.9.20:5000` | `dock1a/comics` | `https://comics.songofeo.com` |
| RPG Vault | `http://10.6.9.20:5002` | `dock1a/books/RPG Books` | `https://gaming.songofeo.com` (step 10) |
| Books | `http://10.6.9.20:5001` | only the bookstore sections you list | `https://books.songofeo.com` (step 10) |

The script goes one step at a time and waits for you between steps, because two of them are clicks in a browser:

1. It makes the RPG Vault's own Kavita from a **copy** of Comics' settings, so accounts and RPG reading progress come along. Then it gives the copy its own signing key and API keys, so a Comics sign-in can't open it. People sign in to the RPG Vault once more, with the same password.
2. It asks you to delete "Comics" inside the RPG Vault and "RPG Vault" inside Comics. That only drops the library from that Kavita's database. The files stay.
3. It narrows Comics to its own folder.
4. It writes the list of your bookstore section folders and shows it to you. Then it starts Books with exactly those folders. `RPG Books` is never allowed in Books.

In the **`eels@cobra-stream` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F50-sgin-kavita-walls.sh
```

If you want to change the section list before Books starts, press Ctrl+C when it shows the list, then open the list in an editor (`eels@cobra-stream` tab):

```bash
sudo machinectl shell podsvc@ /bin/bash -c 'nano ~/.config/cobra/kavita-books.sections'
```

Keep one folder per line, then save with Ctrl+O, Enter, Ctrl+X, and run the F50 line again.

The first time you open Books (`http://10.6.9.20:5001`), make its admin with its own password and save it in Vaultwarden. Then go to Admin, Libraries, Add, once per section, with type **Book**. The script printed each name and folder.

Calibre-Web keeps running for now. Removing it deletes files, so it's not in this list. It's step 5 of the cobra-server Kavita runbook, and it waits for your yes.

**What you should see:** four parts, each ending with a pause (`Press Enter when done`). Part 1 copies Comics to the RPG Vault and prints new keys. Part 2 waits while you delete the libraries in the browser. Part 3 narrows Comics. Part 4 shows the Books section list and starts Kavita Books on 5001.

| If you see | What it means | Do this |
|---|---|---|
| `http://10.6.9.20:5001` or `:5002` doesn't load from the-box | The firewall doesn't open it yet | Do step 6 |
| Kavita asks everyone to log in again | Expected: Kavita 0.9.1+ forces one re-login | Nothing to fix |
| Comics shows RPG books after part 3 | Part 2 (deleting "RPG Vault" inside Comics) was skipped | In Comics (`:5000`): Admin → Libraries → delete **RPG Vault** (only the library entry; files stay) |
| `ERROR` in part 1 about `podman unshare` | A file couldn't be copied | Send the screenshot. Comics was restarted and is unchanged |

---

## Step 8. Put the newest Multi-Pass live (gate)

*Checked against (2026-11-21): Python 3 slim image; Authelia 4.39 (`Remote-Groups` header). See `docs/VERSIONS.md`.*

**Why the live page was missing the updates:** there were two builds. Your downloaded zip had the ADMIN section and the themes. GitHub had Forgot password, PodPanels, the new-user Bays and the Audiobookshelf walls. This step installs one merged build with all of that, plus:

- **Admin Bays**: a fold on the admin page listing your personal pods, each with a live up or down light and a link: Vaultwarden, Paperless, MeTube, Homepage, Uptime Kuma, the radio (Liquidsoap and Icecast), ErsatzTV, all three Audiobookshelf admin pages, all three Kavita admin pages, RomM, high scores, eo-art, the forms inbox, PodPanels, Feishin, OPNsense and Proxmox.
- **The Archives tick**: in People, in Add someone, and on each access-request card, next to Music and Talk Radio. It's **off** for everyone until you tick it.
- **Three Kavitas**: the Multi-Pass knows Comics, Books and the RPG Vault as three separate servers, and Calibre-Web is gone from it. The Library card gives the Kavita Books address.

Have the two API tokens from step 4 ready. The script asks for each one, and your typing stays hidden. If you don't have them yet, press Enter to skip. You can run this step again later; it only offers what's still missing.

In the **`eels@cobra-gate` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F20-gate-multipass.sh
```

To check it, open `https://account.songofeo.com` on the-box. Your page should show the **ADMIN** fold with **People**, **Add someone**, **Settings** and **Admin Bays**. In People, each person has a tick for **The Archives**.

If the page doesn't load, the script has already put the old files back. Send the screen output to Claude or Grok.

**Known stop on your gate:** the 2026-11-21 survey showed `no apps.json`. F20 checks for it first and stops with `ERROR: /srv/gate/eo-account/data/apps.json is missing. Run cobra-setup step 15 once first.` That stop is safe, because nothing was written. Tell Claude when you get there, and the missing setup comes as its own small step.

| If you see | What it means | Do this |
|---|---|---|
| The `apps.json is missing` error | Expected on your gate (see above) | Tell Claude. Skip to step 9 meanwhile |
| `eo-account isn't set up yet (no Quadlet)` | The Multi-Pass was never installed | Tell Claude |
| `https://account.songofeo.com` shows no **ADMIN** fold | You're not in the `admins` group, or the old build is still running | Screenshot the page, and the last 20 lines of F20 |
| The page doesn't load at all | F20 has already put the old files back | Send the screen output |

---

## Step 9. Front-door routes (gate)

*Checked against (2026-11-21): nginx stable 1.28/1.30, Authelia 4.39.28 (`/api/authz/auth-request`). See `docs/VERSIONS.md`.*

This step changes two live files on the gate, line by line. You see a diff for each and say `y` first:

- `talk.` and `comedy.` go to the new Talk Radio server (13379). The Audiobookshelf phone app can use them too, like it already uses `audio.`.
- `player.songofeo.com` goes to Feishin, behind the same Music wall as `music.`.
- `archives.songofeo.com` is **taken out**. The gate refuses that name, so The Archives can't be reached from the internet.

Restarting Authelia signs everyone out once.

In the **`eels@cobra-gate` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F32-gate-routes.sh
```

At the end it prints the Porkbun and certificate items. They're also on the list at the bottom of this README.

**What you should see:** `0/3` shows `000` for 13379 if step 4 isn't done (that's OK). Then a diff for `songofeo.conf` (the talk./comedy. lines change from `:4533` to `:13379`, archives. disappears, player. appears) and a diff for Authelia's `configuration.yml`. Then `nginx: ... test is successful` and Authelia restarts.

| If you see | What it means | Do this |
|---|---|---|
| `nginx: [emerg] ...` | The new file has an error | The script puts the old file back by itself. Send a screenshot |
| Everyone is signed out | Expected: Authelia restarted | Sign in again at `https://gate.songofeo.com` |
| `https://talk.songofeo.com` shows a 502 error | Step 4 isn't done, or step 6 hasn't opened 13379 | Do steps 4 and 6 |

---

## Step 10. Front-door routes for the Kavitas (gate)

*Checked against (2026-11-21): nginx stable, Kavita 0.9.1 OPDS. See `docs/VERSIONS.md`.*

This step changes the gate's live `songofeo.conf`, line by line, with a diff and your `y` first:

- `books.songofeo.com` (and the old `ebooks.`) goes to Kavita Books (5001) instead of Calibre-Web.
- `gaming.songofeo.com` goes to the RPG Vault's Kavita (5002) instead of the holding page.
- Kavita's phone and reading apps (OPDS) can use `books.` and `gaming.` the way they already use `comics.`. Each Kavita's own login is the wall there.

Authelia isn't touched, so nobody gets signed out.

In the **`eels@cobra-gate` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F35-gate-kavita-routes.sh
```

On the station website, the Library window now reads Kavita Books, and the RPG Vault window reads its own Kavita. That change is in this branch and goes live when it's merged and published.

**What you should see:** a diff of `songofeo.conf` (books., ebooks. and gaming. point at `:5001` and `:5002`), your `y`, then `nginx: ... test is successful`.

| If you see | What it means | Do this |
|---|---|---|
| `https://books.songofeo.com` shows 502 | Kavita Books isn't running, or 5001 isn't open | Steps 6 and 7 |
| Kavita's phone app can't log in on books. | The app uses OPDS with its own key | In Kavita Books: your user → **API Key / OPDS**, then copy the new URL into the app |

---

## Step 11. Feishin, the better music player (gate)

*Checked against (2026-11-21): Feishin `ghcr.io/jeffvli/feishin:latest`: port 9180, `SERVER_TYPE=navidrome`, `SERVER_URL`, `SERVER_LOCK`. Navidrome 0.64. See `docs/VERSIONS.md`.*

Feishin is just a nicer page in front of Navidrome. Your music, playlists, stars and play counts all stay in Navidrome. Navidrome's own page at `music.` keeps working. People sign in to Feishin with their usual station username and password.

In the **`eels@cobra-gate` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F33-gate-feishin.sh
```

Once the Porkbun `player` record is in (list item 1), open `https://player.songofeo.com`. On a phone, **Add to Home screen** turns it into an app icon.

**What you should see:** Feishin pulled and started on `127.0.0.1:9180`, then `200`.

| If you see | What it means | Do this |
|---|---|---|
| `https://player.songofeo.com` doesn't resolve | The Porkbun `player` CNAME isn't added yet | "For you to do" item 1 |
| Feishin loads but says it can't reach the server | Navidrome's API is blocked by the sign-in or CORS (an open question for Grok) | Screenshot the Feishin page, plus F12 → Console on the-box |
| On home Wi-Fi, player. fails but music. works | No Unbound override for `player` | Step 0c (host overrides) |

---

## Step 12. eo-art, the wall-art covers (gate)

*Checked against (2026-11-21): Python 3 slim image. See `docs/VERSIONS.md`.*

eo-art is the small server that puts a random cover from your own pictures into each Bay's window (`art.songofeo.com`). It runs on the **gate**. The pictures live on **cobra-stream** (`dock1a/art` and `dock1a/comedy`), and the gate reads them over the media share.

**Claude checked it after all the wall changes.** The program itself still works; it was test-run with every wall. The check turned up three things, and this script fixes them:

1. The Library window asks for `/books/ebook/cover`, and The Archives window asks for `/archives/cover`. Neither wall ever existed, so those two windows always showed their drawn art. The script adds both walls: `dock1a/art/ebooks` and `dock1a/art/archives`, holding copies you pick.
2. eo-art could read **all** of `dock1a`, including The Archives' private recordings. Now it reads only `dock1a/art` and `dock1a/comedy` (for the Comedy Club covers).
3. Nothing else needed changing. Kavita and the Audiobookshelf walls don't touch eo-art, and every path it uses stays the same.

In the **`eels@cobra-gate` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F36-gate-eo-art.sh
```

It prints what each wall answers. **200** means it has pictures, **404** means none yet (that window shows its drawn art), and **000** means eo-art isn't answering. If the restart fails, it puts everything back by itself.

The two new walls need picture folders on cobra-stream. In the `eels@cobra-stream` tab, make them once:

```bash
sudo mkdir -p /srv/storage/disks/dock1a/art/ebooks /srv/storage/disks/dock1a/art/archives
```

Then copy `.jpg` covers in from the-box: in File Explorer, open `\\cobra-stream`, then `dock1a`, `art`, `ebooks` (or `archives`). eo-art picks them up within 6 hours, or right away if you run F36 again.

The Archives wall only ever shows the pictures you put in `art/archives`, and only to people signed in to the station. It never reads the recordings.

**What you should see:** a diff of `folders.json` (two new walls), a diff of the Quadlet's `Volume=` line (`dock1a` becomes `dock1a/art` and `dock1a/comedy`), then a list of walls with `200`, `404` or `000`.

| If you see | What it means | Do this |
|---|---|---|
| `404` for a wall | No pictures in that folder yet | Copy `.jpg` covers into it |
| `000` for every wall | eo-art didn't restart | The script puts everything back by itself. Send a screenshot |
| The Bay windows show the drawn art instead of photos, on home Wi-Fi only | No Unbound override for `art` | Step 0c |

---

## Step 13. The Scoreboard: hiscores page and the daily collector

*Checked against (2026-11-21): Python 3.11+ (`tomllib`). See `docs/VERSIONS.md`.*

The Scoreboard is built as a **Formidable Flow template kit** (the bpm-records/formidable-flow repository), so other retro gamers can use it too. Your setup is one example config inside it. It has two parts:

- **The collector** runs on cobra-stream once a day. It picks up any updated `hiscore.dat` and per-game hiscore files from the cabinets and adds them to a permanent archive. Scores survive a cabinet reset, older records are never overwritten, and the history is kept.
- **The page** at `hiscores.songofeo.com` is a big arcade-style board with three columns: most played games, each player's last played game, and the longest-standing hiscores, plus a recent hiscores strip. It has marked spots for your PNG art. Claiming a score or entering initials goes through Formidable forms.

**Where things stand tonight.** The kit is finished and tested, but the cabinets aren't on the network yet, so there are no score files to collect. The page's address isn't set up on the gate yet either. So tomorrow you only put the collector on cobra-stream and run its read-only check. The daily run and the page go live when the cabinets do. The kit is in this zip at `payload/scoreboard-kit`.

Copy the collector into podsvc's home on cobra-stream. The settings file is copied only if you don't have one yet (`cp -n` never overwrites). In the **`eels@cobra-stream` tab**:

```bash
sudo machinectl shell podsvc@ /bin/bash -c 'mkdir -p ~/scoreboard && cp /tmp/cobra-fix/payload/scoreboard-kit/collector/scoreboard.py ~/scoreboard/ && cp -n /tmp/cobra-fix/payload/scoreboard-kit/collector/examples/songofeo.toml ~/scoreboard/scoreboard.toml'
```

The collector needs Python 3.11 or newer for its `.toml` settings. Check which one cobra-stream has (`eels@cobra-stream` tab):

```bash
python3 --version
```

If it says 3.9 or 3.10, stop here and tell Claude or Grok. The kit takes a `.json` settings file instead, and we'll convert it.

Do the read-only check (`eels@cobra-stream` tab). It lists every file it would collect, and writes nothing. Tonight it will say the cabinet folder is empty or missing, which is expected:

```bash
sudo machinectl shell podsvc@ /bin/bash -c 'python3 ~/scoreboard/scoreboard.py --config ~/scoreboard/scoreboard.toml check'
```

**Later, when the cabinets are on the network** (not tomorrow):

1. Edit `~/scoreboard/scoreboard.toml`: one `[[cabinets]]` block per cabinet, with its real host and hiscore folder. Every setting is explained in the file.
2. Decide where the page lives. The example writes the board into `/srv/gate/hiscores-site/data`, which is on the **gate**, but the collector runs on cobra-stream. Claude or Grok will set that up as its own step (most likely the collector writes into the vault and the gate reads it over the share, like eo-art does), so don't run `run` until then.
3. Turn on the daily 05:00 run with `scoreboard.service` and `scoreboard.timer` from the kit (the kit README, step 5, has the three commands).

**Two names, one decision for you.** The gate still reserves `scores.songofeo.com` for the old hiscore app, and the kit uses `hiscores.songofeo.com`. Both names stay reserved until you pick one (see "For you to do").

**The Arcade link.** RomM's in-browser player (EmulatorJS) keeps its own saves, not MAME `hiscore` files, so scores from games played in the browser won't reach the board yet. The cabinets' scores will. Whether to collect browser scores too is an open question in the kit's field-test notes.

| If you see | What it means | Do this |
|---|---|---|
| `python3 --version` says 3.9 or 3.10 | Too old for `.toml` settings | Tell Claude; the kit takes `.json` instead |
| `check` says the cabinet folder is missing | Expected tonight: the cabinets aren't on the network | Nothing to fix |
| `cp: cannot stat ... scoreboard.py` | Step 1 wasn't run with this version | Run step 1 again |

---

## Step 14. Health check of every pod (gate, then SGIN)

*Checked against (2026-11-21): Podman 5.4.2. See `docs/VERSIONS.md`.*

The first run only looks. It prints **OK** or **DOWN** for every pod the cobra-server setup should have, with the reason.

Calibre-Web isn't checked anymore. It's retiring, and the three walled Kavitas (Comics :5000, Books :5001, RPG :5002) from step 7 replace it. The old Talk and Archives Navidromes only get a note. This script never stops or removes them; they go only when you say so.

In the **`eels@cobra-gate` tab**, the look-only run:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F40-pod-health.sh
```

In the **`eels@cobra-stream` tab**, the same look-only run:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F40-pod-health.sh
```

If anything is **DOWN**, run the fix mode in that server's tab (`eels@cobra-gate` or `eels@cobra-stream`). It asks about each problem one at a time (start it, re-create it from its script with the same data folders, or restart it). Pods that are healthy are never touched.

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F40-pod-health.sh --fix
```

Run the look-only line once more afterwards. A clean run prints only OK lines.

**What you should see:** one line per pod with `OK` or `DOWN` and a reason.

**Known DOWN lines on your servers (2026-11-21):** `icecast` and `radio` were never set up, and `hiscore` and `feishin` aren't installed until their steps run. With `--fix`, answer **no** for `icecast`, `radio` and `hiscore`. Answer **no** for `romm` too if step 3 hasn't been done: re-creating it from its script would put it back in the stream pod.

| If you see | What it means | Do this |
|---|---|---|
| `homepage DOWN 000` on the gate | The dashboard isn't answering on 3000 | Answer `restart` once in `--fix`. If it stays down, run `sudo machinectl shell podsvc@ /usr/bin/podman logs --tail 30 homepage` and send the text |
| `jellyfin DOWN` | The TV is off the air | Answer `restart` in `--fix`. Still down: send `podman logs --tail 30 jellyfin` |
| Anything else DOWN | | Send the look-only output before running `--fix` |

---

## Step 15. For you to do

*Checked against (2026-11-21): Porkbun DNS web page, lego 5.x (wildcard cert), RomM 5. See `docs/VERSIONS.md`.*

These are web pages or choices only you can make, so no script does them.

1. **Porkbun DNS:** songofeo.com, DNS, add a **CNAME** `player` pointing to `gate.songofeo.com`. Optional: delete the `archives` CNAME. The gate refuses that name either way, and deleting it just stops the name from showing up in public DNS.
2. **Certificate:** step 2's gate survey lists the names the certificate covers. If it shows `*.songofeo.com`, you're done. If it lists the names one by one and `player.songofeo.com` isn't there, add it where the certificate is made (cobra-setup manual part 5.3), then reload nginx.
3. **RomM's new admin in the Multi-Pass** (only after step 8 has worked; your gate has no `apps.json` yet, and this would make an empty one): the Multi-Pass still has the old RomM admin login. In the `eels@cobra-gate` tab, open its app list:

   ```bash
   sudo machinectl shell podsvc@ /usr/bin/nano /srv/gate/eo-account/apps.json
   ```

   In the `"romm"` line, put the new admin's username and password from step 3, then save with Ctrl+O, Enter, Ctrl+X. Then restart the Multi-Pass:

   ```bash
   sudo machinectl shell podsvc@ /usr/bin/systemctl --user restart eo-account
   ```

4. **Users in each app, by hand for now:** for each friend, tick their Bays in the Multi-Pass (this opens the gate's door), then make their account in that app's own Users page with the same username. That means Audiobookshelf Audiobooks (13378), Talk (13379) and Archives (13380, only people you trust with the recordings), each Kavita, Navidrome and RomM. Because they're walled, a person needs an account on each server they use.
5. **The access point:** buy one and set it up from `docs/ACCESS-POINT.md`. Short version: the **TP-Link EAP772** plus a **TL-POE260S** PoE+ injector (about $190 together), or the **EAP723** plus a **TL-POE160S** (about $110). After that, your own devices at home won't need WireGuard.
6. **Grok cross-check:** send `GROK-HANDOFF.md` (now with the v3.03 note) to Grok before steps 3 to 13 run on a server (the dual-programmer rule).
7. **Old libraries in the Audiobooks server:** after step 5, delete its old Talk and Archives libraries once the new servers have everything (step 5 explains).
8. **Wall-art pictures:** copy covers into `dock1a/art/ebooks` and `dock1a/art/archives` (step 12).
9. **Calibre-Web removal:** when Kavita Books has worked for a while, tell Claude you're ready, and it'll walk you through step 5 of the Kavita runbook (it deletes Calibre-Web's copies, after a full backup). Nothing in this list removes it.
10. **The old Talk/Comedy Navidrome:** once Talk Radio on Audiobookshelf has everything, tell Claude it's OK to retire `navidrome-talk`. It stays until you say so.
11. **The hiscores name:** pick `hiscores.songofeo.com` (the kit's name) or the old `scores.songofeo.com`. Tell Claude which, and the gate entry and the Porkbun CNAME (pointing to `gate.songofeo.com`, like `player`) come with the page step. Until then, add no DNS for it.
12. **Field-test notes:** after you've used the Multi-Pass and the Scoreboard for a while, add anything awkward you noticed to `docs/field-tests/` in formidable-flow, or just tell Claude and it'll write it up.
