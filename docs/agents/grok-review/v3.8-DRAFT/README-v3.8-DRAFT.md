# Cobra run list v3.8 DRAFT (for Grok's check; not the final Thanksgiving zip)

Do the steps in order and tick each box. Every grey box is one thing to type or paste, then press Enter. Help for any step is at the very end, under **Help**, by step number.

Your three PowerShell tabs: **`windows`**, **`eels@cobra-gate`**, **`eels@cobra-stream`**. Browser = your normal browser on the-box.

---

## Part 1. Copy the files to the servers

- [ ] **1.1** the-box: click the PIA tray icon → **Disconnect**.

- [ ] **1.2** File Explorer: open `V:\=ClaudeCode=` → right-click `cobra-runlist-2026-11-27-v3.8-DRAFT.zip` → **Extract All** → **Extract**.

- [ ] **1.3** `windows` tab, type:

```powershell
cd "V:\=ClaudeCode=\cobra-runlist-2026-11-27-v3.8-DRAFT\cobra-fix"
```

You should see: the prompt now ends in `\cobra-fix>`.

- [ ] **1.4** `windows` tab, type:

```powershell
powershell -ExecutionPolicy Bypass -File .\F00-copy-to-servers.ps1
```

Type eels's password each time it asks (up to 6 times). You should see, last line in green: `Copied. Next: README.md, step 2`.

---

## Part 2. The TV (Roku on the Xfinity router or Xfinity Wi-Fi)

If the Roku is plugged into the **Omada switch** instead, do only **2.0** and skip to Part 3.

- [ ] **2.0** (Omada switch only) Roku: Jellyfin app → **Add Server** → type `https://tv.songofeo.com` → log in. You should see: your Jellyfin home screen. **Done with Part 2.**

### 2A. The SGIN's firewall

- [ ] **2.1** `eels@cobra-stream` tab, type:

```bash
sudo nft list ruleset | grep 10.0.0.0
```

You should see: either a line ending `tcp dport 8096 accept` (then skip to **2.6**), or nothing (go on to 2.2).

- [ ] **2.2** `eels@cobra-stream` tab, type:

```bash
bash /tmp/cobra-fix/F37-sgin-firewall-roku-tv.sh
```

You should see: a diff with one `+` line containing `ip saddr 10.0.0.0/24 tcp dport 8096 accept`, then `Load it? [y/N]`.

- [ ] **2.3** Type `y` and press Enter. You should see: a yellow line `Open a NEW terminal ...` and a 2-minute countdown question.

- [ ] **2.4** Press **Ctrl + Shift + T** (a temporary 4th tab), and type:

```powershell
ssh eels@10.6.9.20
```

Type eels's password. You should see: `eels@cobra-stream:~$`.

- [ ] **2.5** Go back to the `eels@cobra-stream` tab, type `y` and press Enter. You should see: `==> Kept.` Close the 4th tab.

### 2B. OPNsense (browser on the-box)

- [ ] **2.6** Browser: go to `https://10.6.9.1` and log in.

- [ ] **2.7** Click **Interfaces → [WAN]**. You should see: the WAN settings page. (If it looks different: **Interfaces → Assignments** → click **WAN**.)

- [ ] **2.8** Find **Block private networks** → click to **untick** it. Leave everything else alone.

- [ ] **2.9** Click **Save** (bottom), then **Apply changes** (top). You should see: a green "changes have been applied" bar.

- [ ] **2.10** Click **Firewall → NAT → Destination NAT**.

- [ ] **2.11** Is there a rule called `Roku to Jellyfin`? Yes: click its **pencil**. No: click **+**.

- [ ] **2.12** **Description**: type `Roku to Jellyfin`

- [ ] **2.13** **Interface**: pick **WAN**.

- [ ] **2.14** **TCP/IP Version**: pick **IPv4**.

- [ ] **2.15** **Protocol**: pick **TCP**. (Do this before the ports: the port boxes reject input while Protocol is "any".)

- [ ] **2.16** **Source**: click **Advanced** (or open the **Source** section) → **Source Address**: pick **Single host or Network** → type `10.0.0.0/24`

- [ ] **2.17** **Destination Address**: pick **WAN address**.

- [ ] **2.18** **Destination Port**: leave the dropdown on **Single port or range** → in the box type:

```
8096
```

- [ ] **2.19** **Redirect Target IP**: type `10.6.9.20`

- [ ] **2.20** **Redirect Target Port**: type `8096`

- [ ] **2.21** **Firewall rule**: pick **Register rule**. (Never Manual: Manual lets nothing through.)

- [ ] **2.22** Click **Save**, then **Apply**. You should see: `Roku to Jellyfin` in the list, with no red error.

- [ ] **2.23** Click **Firewall → Rules** → in the interface selector at the top pick **WAN** → switch **Inspect** on → expand **Automatically generated rules**. You should see: a pass rule `Roku to Jellyfin`, source `10.0.0.0/24`, to `10.6.9.20` port `8096`. Take a screenshot and keep it.

### 2C. Test, then the Roku

- [ ] **2.24** Phone: WireGuard app → switch the tunnel **off**.

- [ ] **2.25** Phone: connect to Wi-Fi **Electronomicon** (or Electronomicon_EXT).

- [ ] **2.26** Phone: Chrome → address bar → type `http://10.0.0.2:8096`. You should see: the Jellyfin login page. (Don't test from the-box: it always times out there, and that's normal.)

- [ ] **2.27** Roku: Jellyfin app → **Add Server** (or Settings → Change server) → type `http://10.0.0.2:8096` → log in. You should see: your Jellyfin home screen.

- [ ] **2.28** Browser on the-box: go to `https://tv.songofeo.com` → **Dashboard → Networking** → **LAN networks**: add `10.0.0.0/24` → **Save**. (This stops Jellyfin lowering the TV's picture quality.)

**The TV is done.**

---

## Part 3. The phone at home without WireGuard (optional)

This lets the phone open `music.songofeo.com` and the other names on home Wi-Fi. Skip it if you're happy using WireGuard at home for now.

### 3A. OPNsense (browser on the-box)

- [ ] **3.1** Click **Services → Unbound DNS → General**. Find **Network Interfaces**. If it says **All**, leave it. If it's a list, click **WAN** to add it (keep the others selected). **Save**, then **Apply**.

- [ ] **3.2** Click **Services → Unbound DNS → Access Lists** → **+**.

- [ ] **3.3** **Name**: type `xfinity-side`. **Action**: pick **Allow**. **Networks**: type `10.0.0.0/24`. **Description**: type `Home Wi-Fi phones and TV`. **Save**, then **Apply**.

- [ ] **3.4** Click **Services → Unbound DNS → Overrides** → **Host Overrides** → **+**.

- [ ] **3.5** **Enabled**: ticked. **Host**: type `gate`. **Domain**: type `songofeo.com`. **Type**: pick **A**. **IP address** (or **Value**): type `10.0.0.2`. **Description**: type `home Wi-Fi`. **Save**.

- [ ] **3.6** Repeat 3.4 and 3.5 for each of these hosts, changing only **Host**. Tick each one off:

`tv` · `music` · `books` · `comedy` · `sessions` · `comics` · `gaming` · `arcade` · `papers` · `metube` · `command` · `forms` · `vip` · `scores` · `radio` · `ha` · `audio` · `talk` · `player` · `ebooks` · `account` · `art` · `auth`

(Never add `archives`, `vault`, `status`, `www`, `vpn`, a blank host, or `*`.)

- [ ] **3.7** Click **Apply** (top of the Overrides page).

- [ ] **3.8** Click **Firewall → Rules** → pick **WAN** in the selector → **+**.

- [ ] **3.9** **Action**: pick **Pass**. **Interface**: pick **WAN**. **Direction**: pick **in**. **TCP/IP Version**: pick **IPv4**. **Protocol**: pick **TCP/UDP**.

- [ ] **3.10** **Source**: pick **Single host or Network** → type `10.0.0.0/24`.

- [ ] **3.11** **Destination**: pick **This Firewall**.

- [ ] **3.12** **Destination port**: one box → type `53`. Two dropdowns (from / to) → pick **DNS** in both.

- [ ] **3.13** **Description**: type `Xfinity side DNS`. **Save**, then **Apply**.

### 3B. Check from the-box

- [ ] **3.14** `windows` tab, type:

```powershell
Resolve-DnsName tv.songofeo.com -Server 10.0.0.2 -DnsOnly
```

You should see: `10.0.0.2` in the IPAddress column.

- [ ] **3.15** `windows` tab, type:

```powershell
Resolve-DnsName tv.songofeo.com -DnsOnly
```

You should see: `10.6.9.10`. (If it says `10.0.0.2`, **stop** and see Help 3.15.)

### 3C. The phone (S21)

- [ ] **3.16** Phone: **Settings → Connections → More connection settings → Private DNS** → pick **Off**.

- [ ] **3.17** Phone: **Settings → Connections → Wi-Fi** → gear next to **Electronomicon** → **View more** → **IP settings**: pick **Static**.

- [ ] **3.18** **IP address**: type `10.0.0.251`. **Gateway**: type `10.0.0.1`. **Network prefix length**: type `24`. **DNS 1**: type `10.0.0.2`. **DNS 2**: delete what's there and leave it empty. **Save**.

- [ ] **3.19** Phone: turn Wi-Fi off, then on.

- [ ] **3.20** Phone: Chrome → **⋮ → Settings → Privacy and security → Use secure DNS** → **off**.

- [ ] **3.21** Phone (WireGuard off): Chrome → `https://music.songofeo.com`. You should see: the gate sign-in. It asks for your password **and** your TOTP code; that's on purpose at home.

---

## Part 4. The Arcade (RomM)

Do this when nobody is watching TV: Jellyfin, music and books go off for about a minute.

- [ ] **4.1** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F11-sgin-arcade-own-pod.sh
```

You should see: `==> 1/5 Look first`, then four diffs, each asking `Write this change ...? [y/N]`.

- [ ] **4.2** Type `y` for each of the 4 diffs.

- [ ] **4.3** At `Restart the stream pod and start the Arcade pod now? [y/N]`, type `y`. You should see: a list of `200`s, then `==> Done. RomM runs in its own pod`.

- [ ] **4.4** Read the last line:
  - `The setup wizard is ON` → browser: `http://10.6.9.20:8080` → make the new admin → save it in Vaultwarden → **Part 4 is done.**
  - `The wizard is off` → go on to 4.5.

- [ ] **4.5** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /usr/bin/podman exec romm-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" romm -e "SELECT username, email, role FROM users;"'
```

You should see: a small table. Write down the **username** on the `admin` line.

- [ ] **4.6** Browser: `http://10.6.9.20:8080` → **Forgot password?** → type that username (or email) → send.

- [ ] **4.7** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /usr/bin/podman logs --tail 40 romm
```

You should see: a line near the end with a temporary password.

- [ ] **4.8** Browser: log in with the username and the temporary password → your profile → set a **new** password → save it in Vaultwarden.

---

## Part 5. The SGIN: Talk Radio, the Archives, Audiobooks, Kavitas

- [ ] **5.1** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F30-sgin-talk-archives.sh
```

You should see: either the first-time setup list at the end, or `ERROR: ... comedy is missing` (then do 5.2).

- [ ] **5.2** (only if 5.1 said a folder is missing) Copy the exact `sudo mkdir ...` line F30 printed → paste it in the `eels@cobra-stream` tab → Enter. Then run 5.1 again.

- [ ] **5.3** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F34-sgin-audiobooks-wall.sh
```

You should see: one diff → type `y` → `200` at the end.

- [ ] **5.4** `eels@cobra-stream` tab, type:

```bash
bash /tmp/cobra-fix/F31-sgin-firewall-talk-archives.sh
```

You should see: `to add: 13379 13380 5001 5002`, a diff, `Load it? [y/N]` → type `y`.

- [ ] **5.5** Press **Ctrl + Shift + T** (4th tab), type:

```powershell
ssh eels@10.6.9.20
```

You should see: `eels@cobra-stream:~$`. Go back to the `eels@cobra-stream` tab → type `y` → `==> Kept.` Close the 4th tab.

- [ ] **5.6** Browser: `http://10.6.9.20:13379` → make the **root** user (new password, save it in Vaultwarden).

- [ ] **5.7** Same page: **Settings → Libraries → Add** → name `Talk Radio`, type **Book**, folder under `/media/comedy/` → **Save**. Again for `Comedy Club`.

- [ ] **5.8** Same page: **Settings → API Keys → Add** → name `eo-account` → copy the token into Vaultwarden.

- [ ] **5.9** Browser: `http://10.6.9.20:13380` → make its **root** user (a different password) → **Settings → Libraries → Add** → `The Archives`, type **Book**, folder `/media/archives` → **Settings → API Keys → Add** `eo-account` → token into Vaultwarden.

- [ ] **5.10** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F50-sgin-kavita-walls.sh
```

You should see: part 1 runs, then it waits with instructions. Do exactly what each pause says (two library deletions in the browser), pressing Enter after each. At the end: `Kavita Books` started on `5001`.

- [ ] **5.11** Browser: `http://10.6.9.20:5001` → make its admin (new password, into Vaultwarden) → **Admin → Libraries → Add**, once per section F50 printed, type **Book**.

---

## Part 6. The gate

- [ ] **6.1** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F20-gate-multipass.sh
```

You should see: `ERROR: ... apps.json is missing`. **That's expected on your gate.** Nothing was changed. Tell Claude, and go on to 6.2.

- [ ] **6.2** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F32-gate-routes.sh
```

You should see: two diffs → `y` to each → `test is successful`. (Everyone gets signed out once.)

- [ ] **6.3** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F35-gate-kavita-routes.sh
```

You should see: one diff → `y` → `test is successful`.

- [ ] **6.4** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F33-gate-feishin.sh
```

You should see: Feishin started, `200`.

- [ ] **6.5** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F36-gate-eo-art.sh
```

You should see: two diffs → `y` to each → a list of walls with `200` or `404`.

- [ ] **6.6** `eels@cobra-stream` tab, type:

```bash
sudo mkdir -p /srv/storage/disks/dock1a/art/ebooks /srv/storage/disks/dock1a/art/archives
```

You should see: nothing (no output means it worked).

---

## Part 7. Health check

- [ ] **7.1** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F40-pod-health.sh
```

You should see: `OK` lines. Expected `DOWN`: `hiscore` (not installed yet).

- [ ] **7.2** `eels@cobra-stream` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F40-pod-health.sh
```

You should see: `OK` lines. Expected `DOWN`: `icecast` and `radio` (never set up).

- [ ] **7.3** Anything else `DOWN`? Take a screenshot and send it to Claude. Don't run `--fix` yourself.

---

## Part 8. Web pages only you can do

- [ ] **8.1** Porkbun → songofeo.com → **DNS** → add a **CNAME**: host `player`, answer `gate.songofeo.com` → **Add**.

- [ ] **8.2** For each friend: tick their Bays at `https://account.songofeo.com` (after Claude fixes 6.1), then make their account with the same username in each app they use.

- [ ] **8.3** Copy `.jpg` covers from the-box into `\\cobra-stream\dock1a\art\ebooks` and `\\cobra-stream\dock1a\art\archives`.

## Part 9. The smart home (ha.songofeo.com) — v3.8 DRAFT

Home Assistant runs as its own virtual machine, **VM 120 `cobra-home`**, on the Latitude (Proxmox). It's the only box plugged into both networks, so it can talk to the Sensi thermostat and the Eufy bulbs on the Xfinity Wi-Fi directly. You open it at `https://ha.songofeo.com` (gate password + TOTP, admins only), and the Multi-Pass gets a **Smart home** window.

### 9A. Before you start

- [ ] **9.1** Porkbun → songofeo.com → **DNS** → add a **CNAME**: host `ha`, answer `gate.songofeo.com` → **Add**. (A DNS record, the same as `player` in 8.1. **Not** a URL forward.)

### 9B. Build the VM (Proxmox, in the browser)

- [ ] **9.2** Browser: `https://10.6.9.2:8006` → log in as `root` → left column: click **cobra-command** → top right: **>_ Shell**. (This is the "Proxmox Shell" below. Paste with **Ctrl + Shift + V**.)

- [ ] **9.3** Proxmox Shell, type:

```bash
scp eels@10.6.9.20:/tmp/cobra-fix/F64-pve-home-vm.sh /root/
```

You should see: `Are you sure you want to continue connecting` (first time only) → type `yes` → eels's password → `F64-pve-home-vm.sh 100%`.

- [ ] **9.4** Browser, new tab: `https://github.com/home-assistant/operating-system/releases` → the top entry marked **Latest** → write down its number (on 2026-11-27 it was `18.5`).

- [ ] **9.5** Proxmox Shell, type (use the number from 9.4 if it's newer than `18.5`):

```bash
bash /root/F64-pve-home-vm.sh create 18.5
```

You should see: `1/6 Look first` → a download bar → `Create VM 120 now?` → `y` → `4/6 Check the imported disk` → `8 partitions` → `Write both files and turn the Proxmox firewall on?` → `y` → `Status: enabled/running` → two MAC addresses at the end. **Write both MACs down.**

- [ ] **9.6** Browser, **new** tab: `https://10.6.9.2:8006`. You should see: the Proxmox login page, the same as before. (If it doesn't load, see Help 9.6 first.)

- [ ] **9.7** Browser: OPNsense → **Services → Dnsmasq DNS & DHCP → Hosts** → **+**.

| Field | Do this |
|---|---|
| Host | Type `cobra-home` |
| Domain | Type `home.arpa` |
| IP addresses | Type `10.6.9.11` |
| Hardware addresses | Type the **net0 MAC** from 9.5, with colons |
| Description | Type `Home Assistant VM 120 (LAN)` |

**Save**, then **Apply**.

- [ ] **9.8** Browser: `http://10.0.0.1` → log in (Xfinity admin password) → **Connected Devices** → **Devices** → **Add Device with Reserved IP**.

| Field | Do this |
|---|---|
| Host Name | Type `cobra-home-iot` |
| MAC Address | Type the **net1 MAC** from 9.5 |
| Reserved IP Address | Type `10.0.0.3` |

**Save**. (If `10.0.0.3` is already in the device list, see Help 9.8.)

- [ ] **9.9** Proxmox Shell, type:

```bash
bash /root/F64-pve-home-vm.sh plug-lan
```

You should see: `net0 plugged in` → `status: running`.

### 9C. First start (browser on the-box)

- [ ] **9.10** Browser: `http://10.6.9.11:8123`. You should see: **Preparing Home Assistant** (up to 20 minutes on the first start), then **Create my smart home**.

- [ ] **9.11** **Create my smart home** → Name: type `Eels` → Username: type `eels` → Password: a **new** password from Vaultwarden's generator (save it there now) → **Create account**.

- [ ] **9.12** Location: drag the pin to your home. Units: pick **US customary** (°F, the same as the thermostat). Analytics: your choice. **Next** → **Finish**.

- [ ] **9.13** Bottom left: click your name → turn on **Advanced mode**.

- [ ] **9.14** Same page → **Security** tab → **Multi-factor authentication modules** → **Authenticator app** → **Enable**. Scan the QR code with your authenticator app on the phone, type the 6-digit code → **Submit**.

### 9D. The second network card (the Xfinity side)

- [ ] **9.15** Settings → **System** → **Network** → **Configure network interfaces** → click the **second** card's tab (usually `enp6s19`; its MAC is the net1 MAC from 9.5).

| Field | Do this |
|---|---|
| IPv4 | Pick **Static** |
| IP address | Type `10.0.0.3/24` |
| Gateway | Leave **empty** |
| DNS servers | Leave **empty** |
| IPv6 | Pick **Disabled** |

**Save**.

- [ ] **9.16** Same page → **Network adapter**: untick **Autoconfigure** → tick **both** cards → **Save**.

- [ ] **9.17** Proxmox Shell, type:

```bash
bash /root/F64-pve-home-vm.sh plug-iot
```

You should see: `Did Home Assistant save net1 as STATIC ...?` → `y` → `net1 plugged in`.

- [ ] **9.18** Home Assistant: Settings → **Add-ons** → **Add-on store** → **Terminal & SSH** → **Install** → **Start** → **Open Web UI**. (This is the "HA terminal" below.)

- [ ] **9.19** HA terminal, type:

```bash
ip -4 route
```

You should see: exactly **one** line starting `default via 10.6.9.1`, and a line starting `10.0.0.0/24 dev` with **no** `via` in it.

- [ ] **9.20** HA terminal, type:

```bash
ip -6 route show default
```

You should see: nothing (no output).

- [ ] **9.21** HA terminal, type:

```bash
ping -c 3 10.0.0.1
```

You should see: `3 packets transmitted, 3 received`.

### 9E. Let the gate in (and only the gate)

- [ ] **9.22** Home Assistant: Settings → **Add-ons** → **Add-on store** → **File editor** → **Install** → **Start** → **Open Web UI**.

- [ ] **9.23** File editor: click the folder icon (top left) → `configuration.yaml`. Click at the very end of the file, press Enter, and paste:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.6.9.10
  ip_ban_enabled: true
  login_attempts_threshold: 5
```

Click the red **Save** icon (top right).

- [ ] **9.24** Home Assistant: Settings → **Developer tools** → **YAML** tab → **Check configuration**. You should see: `Configuration will not prevent Home Assistant from starting!` → click **Restart** → **Restart Home Assistant**.

- [ ] **9.25** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F62-gate-ha-route.sh
```

You should see: `200: Home Assistant answers the gate and trusts it` → two diffs → `y` to each → `test is successful`. (Everyone gets signed out once.)

- [ ] **9.26** Browser, **private window**: `https://ha.songofeo.com`. You should see: the gate sign-in (password + TOTP), then Home Assistant's own login.

### 9F. The devices

- [ ] **9.27** `eels@cobra-gate` tab, type:

```bash
bash /tmp/cobra-fix/F65-gate-eufy-codes.sh
```

You should see: your Eufy email and hidden password prompts, then a table: name, model, IP, local code, **WORKS LOCALLY?**. Leave this tab open (don't screenshot it: the codes are keys).

- [ ] **9.28** Browser: `http://10.0.0.1` → **Connected Devices** → for each row with **yes** in 9.27: **Add Device with Reserved IP** → the device's MAC (shown there under its Eufy name or `ESP_…`) → IP from `10.0.0.20` upward → **Save**. Write each IP next to its name. Then switch each lamp off and on at the wall.

- [ ] **9.29** Any **yes** rows? HA terminal, type (skip 9.29 and 9.30 if none):

```bash
ha backups new --name before-core-2026.9.4
```

You should see: `Command completed successfully.`

- [ ] **9.30** HA terminal, type:

```bash
ha core update --version 2026.9.4
```

You should see: `Command completed successfully.` after a few minutes. (Eufy's local control is broken from 2026.10 on: Help 9.30.)

- [ ] **9.31** File editor → **folder icon** → `secrets.yaml` → at the end, one line per **yes** device (a short name, a colon, its local code from 9.27). Example: `eufy_den_lamp: 0123456789abcdef` → **Save**.

- [ ] **9.32** File editor → `configuration.yaml` → at the end, paste this, then make one `- address:` block per device (its IP from 9.28, its secret name from 9.31, its model, a name) → **Save**:

```yaml
eufy:
  devices:
    - address: 10.0.0.20
      access_token: !secret eufy_den_lamp
      type: T1013
      name: Den lamp
```

- [ ] **9.33** Settings → **Developer tools** → **YAML** → **Check configuration** → **Restart**. Then Settings → **Devices & services** → **Entities**: each Eufy light is listed; clicking it switches the real light within a second.

- [ ] **9.34** The thermostat: pull the Sensi off its wall plate and find the 8-digit **HomeKit code** on its label (looks like `123-45-678`). Write it down. If it was ever added to an Apple Home, remove it there first.

- [ ] **9.35** Home Assistant: Settings → **Devices & services**. You should see: a **Discovered: HomeKit Device** card for the Sensi (within a minute) → **Configure** → type the code **with the dashes** → **Submit**.

### 9G. The Multi-Pass window

- [ ] **9.36** (after 6.1 is fixed) Home Assistant: your name (bottom left) → **Security** → **Long-lived access tokens** → **Create token** → Name: type `eo-account` → **OK** → **Copy**.

- [ ] **9.37** `eels@cobra-gate` tab, type:

```bash
sudo machinectl shell podsvc@ /bin/bash /tmp/cobra-fix/F63-gate-ha-token.sh
```

You should see: paste prompt (nothing shows while you paste) → Enter → `y` → `The Multi-Pass is back`. Then `https://account.songofeo.com` → **Smart home**: your lights and thermostat.

**End of the steps.**

---
---

# Help

Only read this if a step went wrong. Find the step number. If it isn't here, take a screenshot and send it to Claude.

**How to send a screenshot:** the-box → **Windows + Shift + S**, drag around the window, then paste (Ctrl+V) into the Claude chat. Phone → **Power + Volume down**, then share it to the Claude app. TV → take a photo with the phone. For long terminal text: select it with the mouse, right-click to copy, and paste it.

**Red `ERROR:` lines** mean the script stopped by itself and didn't change anything after that point.

**1.4** `can't reach ... :22` → PIA is still on, or the-box isn't on the cobra network. `Cannot find path` → the folder was extracted somewhere else: open it in File Explorer, copy the path from the address bar, and use that in 1.3.

**2.1 to 2.5** `No such file` → do Part 1 again (a server reboot empties `/tmp`). The 4th tab can't log in → **don't** type `y`. Wait 2 minutes and the old rules come back by themselves; send a screenshot.

**2.15 to 2.18** A port box turns red → check Protocol is **TCP**. Then type only `8096`: no "to", dash or colon. Still red: send a screenshot of the error text.

**2.21** No **Firewall rule** field → older OPNsense. Look for **Filter rule association** and pick **Add associated filter rule**.

**2.23** No `Roku to Jellyfin` under the generated rules → the rule is still on **Manual**. Go back to 2.11 and set **Register rule** (2.21).

**2.26 times out on the phone.** Check in this order:
1. Phone: Wi-Fi settings → the IP starts with `10.0.0.`, and WireGuard is off.
2. Browser: **Firewall → Log Files → Live View**, type `8096` in the filter, then reload the page on the phone:
   - nothing appears → 2.8 (Block private networks) isn't saved and applied;
   - a red line → 2.21 isn't **Register rule**;
   - a green line → the SGIN is blocking it: redo 2.1 to 2.5.
3. Send Claude: the Live View screenshot, the 2.23 screenshot, and the 2.1 output.

**2.27** "Unable to connect" on the Roku but the phone works → type the address exactly: `http://` (not https), `10.0.0.2`, then `:8096`.

**3.14** Times out → 3.1 or 3.3 is missing (some OPNsense updates made the Access List default **Deny**, so the Allow entry is required). Shows `73.x.x.x` → the overrides (3.5 to 3.7) aren't applied.

**3.15** Shows `10.0.0.2` → **stop**. The overrides leaked to the cobra network. Untick **Enabled** on each `home Wi-Fi` override, Apply, and tell Claude.

**3.21** Fails for every name → phone DNS 1 isn't `10.0.0.2`, or Private DNS / Chrome secure DNS is still on. One name fails → that host is missing from 3.6.

**4.3** Any `000` → answer `y` to **Put everything back the way it was?** Everything returns to how it was. Send a screenshot.

**4.5** `Access denied` → send a screenshot (nothing was changed).

**4.6** No **Forgot password?** link, or **4.7** no password line → run 4.7 again with `--tail 200` in place of `--tail 40`, then send the output.

**5.1** `address already in use` → send a screenshot.

**5.3** `000` at the end, or audiobooks show as missing → send a screenshot. Nobody's progress is lost; the data folder isn't touched.

**5.4** `already open. Nothing to do.` → fine, go on to 5.6.

**5.6 to 5.11** A page doesn't load → 5.4 wasn't done or kept.

**6.2 / 6.3** `nginx: [emerg]` → the script already put the old file back. Send a screenshot.

**6.4** `player.songofeo.com` doesn't open → 8.1 isn't done yet.

**Why the Arcade needed Part 4:** RomM and Kavita both use port 5000 inside the shared "stream" pod, so RomM's engine kept crashing. F11 gives RomM its own pod at the same address. Your RomM is version 5, which shows its setup wizard only on an empty database, so 4.5 to 4.8 reset the old admin's password instead.

**Why the TV needed both OPNsense and F37:** the Xfinity side (`10.0.0.x`) is outside the cobra network. OPNsense has to let it in (2.8, 2.10 to 2.22), and the SGIN's own firewall has to accept it (F37). Your accepted-risk note, 2026-11-21: home Wi-Fi reaches the station with a password, no WireGuard at home. Only Jellyfin's port 8096 and DNS port 53 are opened, and only to `10.0.0.0/24`. The Archives stays home-network/WireGuard only.

**Undo for Part 3** (when the new access point arrives): untick **Enabled** on the `Xfinity side DNS` rule, the `home Wi-Fi` overrides and the `xfinity-side` access list, then Apply. Set the phone's IP settings back to **DHCP**.

**Checked against (2026-11-21):** OPNsense 26.1 to 26.7.9, Podman 5.4.2, RomM 5.x, Kavita 0.9.1.4, Audiobookshelf 2.38, Jellyfin 10.11/12, Authelia 4.39, Roku OS 15, Android One UI 7/8, Windows 11 PowerShell 5.1.

**Checked against (2026-11-27), Part 9:** Proxmox VE 9.2, Home Assistant OS 18.5, Home Assistant Core 2026.11.3 (held at 2026.9.4 for Eufy), OPNsense 26.7.9 (Dnsmasq Hosts page).

**9.5** `VM 120 already exists` → nothing was changed; send `qm config 120`. `isn't on GitHub` → the number from 9.4 has a typo. `doesn't look like HA OS` → answer `y`: it rewrites only VM 120's new disk. `a firewall file already exists` → send the lines it printed; **don't** do 9.17 until Claude has merged them.

**9.6** Proxmox page doesn't load → Proxmox Shell (the tab that's still open), type `pve-firewall stop`, then send a screenshot. VM 120 is fine either way.

**9.8** `10.0.0.3` already used → pick a free one (like `10.0.0.4`) and use it in 9.8 and 9.15.

**9.10** Still "Preparing" after 30 minutes, or the page never loads → Proxmox → **120** → **Console** and send a screenshot. A different address than `10.6.9.11` on the console → the MAC in 9.7 doesn't match net0.

**9.15** No second tab → VM 120's net1 is missing; send `bash /root/F64-pve-home-vm.sh check` (Proxmox Shell).

**9.17** `firewall isn't on` → 9.5's firewall part was skipped; send `bash /root/F64-pve-home-vm.sh check`.

**9.19** Two `default` lines, or `via 10.0.0.1` → 9.15 has a gateway. Remove it, Save, and check again. **Until it's fixed, Home Assistant skips OPNsense on its way out.**

**9.20** Any output → 9.15's IPv6 isn't **Disabled**.

**9.25** `400` → 9.23 isn't saved, or 9.24's restart didn't happen. Nothing was changed. `no answer` → 9.9 isn't done, or VM 120 is off. `uses 'policy: bypass'` → an old `ha.` rule from manual part 10.7 is in Authelia; you decided on 2026-11-06: one sign-in everywhere, no home bypass. Send a screenshot.

**9.26** `403` / a refusal page after signing in → you're not `eels` or in the `admins` group. Home Assistant shows `400: Bad Request` → same as 9.25.

**9.26 (by design)** On the cobra LAN, `http://10.6.9.11:8123` still opens directly, with Home Assistant's own login + 2FA (9.14). The phone app: on the `cobra` Wi-Fi or with WireGuard on, use the server address `http://10.6.9.11:8123`. On the Xfinity Wi-Fi it can't reach it, on purpose. The app can't get past the gate's sign-in at `ha.songofeo.com`.

**9.27** `Eufy refused the login` (or a verification-code message) → Eufy changed its login. Send the line it printed. Rows with **NO** → those bulbs only work through Eufy's cloud: leave them in the Eufy app (Help 9.33).

**9.30** Why 2026.9.4: Home Assistant's EufyHome integration crashes on 2026.10 and later (`Expected an int, got a boolean`; Home Assistant issue #186877, still open at 2026.11.3). Settings → System → **Updates**: **skip** each new Core update until its notes mention the Eufy fix. HA OS and add-on updates are fine to install. Check monthly. If you have **no** "yes" rows, don't pin, and update normally.

**9.33** A light says **Unavailable** → its IP in 9.32 doesn't match 9.28, or it wasn't switched off and on after 9.28. Cloud-only Eufy bulbs: options for later are Matter-over-Wi-Fi or TP-Link Kasa/Tapo bulbs, both local. Nothing is bought until you decide.

**9.35** No HomeKit card → 9.16 (both cards ticked) or 9.17 isn't done, or the thermostat is on a different Wi-Fi. `Incorrect HomeKit code` with the right code → send a screenshot; there's a known Sensi reset workaround that costs its Sensi app setup, so Claude walks you through it.

**9.36 / 9.37 (CSO decision, not a fault)** The existing Authelia rule for `papers.`, `metube.`, `command.` and `status.` has **no subject line**: any signed-in friend who sets up TOTP can open Paperless (your scanned mail), Homepage and Uptime Kuma. `ha.` doesn't have this problem (9.25 adds admins-only rules). Tell Claude or Grok if those four should be admins-only too.

**9.37** `no Smart home window yet` → 6.1 (F20) hasn't installed this build. `didn't answer` → apps.json was put back by itself; send `podman logs --tail 40 eo-account`. Later, the window says **Token refused** → the token was deleted or mistyped; the Multi-Pass stops asking (5 refused logins would lock the whole gate out of Home Assistant). Make a new token (9.36) and run 9.37 again.
