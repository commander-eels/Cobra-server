# Home Wi-Fi to the gate, no WireGuard

Phones and the TV on the Xfinity side (`Electronomicon`, `10.0.0.x`) open the station's normal
`https://<name>.songofeo.com` addresses and get the gate sign-in (Authelia), the same as everyone
else. WireGuard stays for when you're away from home.

Risk accepted by the owner on 2026-11-21: on the home Wi-Fi a password (Authelia) is the protection,
not a tunnel. When the EAP772 access point arrives ([manual 2.10b](../manual/02-networking.md)),
the phone moves to the cobra Wi-Fi and the "Undo" list at the bottom closes this again.

## How it works

| Piece | What it does |
|---|---|
| Problem | On the Xfinity side, `tv.songofeo.com` resolves to the public IP, and the Xfinity router can't loop traffic for its own public IP back inside (no NAT loopback). |
| DNS fix | OPNsense's Unbound answers the station's names with `10.0.0.2` (OPNsense's Xfinity-side address), but only for devices that ask it. The phone is told to ask it. |
| Traffic | Phone → `10.0.0.2:443` → the existing port forward → gate `10.6.9.10:443` → Authelia → the app. |
| Who can ask Unbound on WAN | Only `10.0.0.0/24`. The internet can't (WAN rule + Unbound access list). |
| LAN | Unchanged. Pi-hole still answers `10.6.9.10` for LAN and WireGuard devices; it never asks Unbound about app names. |
| Work laptop | Untouched. Nothing on the Xfinity router changes; it keeps Xfinity's DNS. |

| Item | Value |
|---|---|
| OPNsense WAN | `10.0.0.2` (reserved in the Xfinity app) |
| Xfinity DHCP pool | `10.0.0.10`–`10.0.0.250` (manual 2.2) |
| Phone's fixed address | `10.0.0.251` (outside the pool, so nothing else gets it) |
| Gate | `10.6.9.10`, existing forward WAN TCP 443 → gate |
| Jellyfin | `10.6.9.20:8096` |

Do steps 1 to 5 on **the-box**, in the OPNsense page at `https://10.6.9.1` in your normal browser.
Step 6 is the phone. Step 7 is the TV, two ways.

## 1. Look first (read-only)

Write down what you see; change nothing yet.

- [ ] **Interfaces → [WAN]**: is **Block private networks** ticked? Is **Block bogon networks** ticked?
- [ ] **Firewall → NAT → Port Forward**: the 443 → `10.6.9.10` rule. **Destination** should be **WAN address**
      (covers both the public IP and `10.0.0.2`). **Source** should be **any**.
- [ ] **Firewall → Rules → WAN**: "Allow 443 to gate" has **Source any**. Note any rule with port 53 already there.
- [ ] **Services → Unbound DNS → General → Network Interfaces**: *All*, or a list (which ones?).
- [ ] **Services → Unbound DNS → Access Lists**: note any entries.
- [ ] **Services → Unbound DNS → Overrides**: note any `songofeo.com` entries.

On the-box, open **Windows Terminal → PowerShell**. If PIA is connected, disconnect it first (it answers
DNS itself and hides the real result). This asks Pi-hole, the way every LAN device does:

```powershell
Resolve-DnsName tv.songofeo.com -DnsOnly
```

It must say `10.6.9.10`. This one asks OPNsense's Unbound at its WAN address:

```powershell
Resolve-DnsName tv.songofeo.com -Server 10.0.0.2 -DnsOnly
```

Today it prints the public IP, or times out if Unbound doesn't listen on WAN.

## 2. Let the Xfinity side in on WAN

- [ ] **Interfaces → [WAN]**: untick **Block private networks**. Leave **Block bogon networks** as it was.
      **Save**, then **Apply changes**.

Why this is safe: the internet's traffic arrives through the DMZ with public source addresses;
only devices on the Xfinity side have `10.0.0.x` sources. Everything not passed by a WAN rule is
still dropped by the default deny.

## 3. Unbound: listen on WAN, allow only 10.0.0.0/24

- [ ] **Services → Unbound DNS → General → Network Interfaces**: if it's a list, add **WAN** (keep the others).
      If it's *All*, leave it. **Save**, then **Apply**.
- [ ] **Services → Unbound DNS → Access Lists → +**: Name `xfinity-side`, Action **Allow**, Networks `10.0.0.0/24`,
      Description `Home Wi-Fi phones and TV`. **Save**, then **Apply**.

## 4. Unbound: the station's names → 10.0.0.2

**Services → Unbound DNS → Overrides → Host Overrides → +**, one entry per name below.
Each: Enabled ticked, Host = the name, Domain `songofeo.com`, Type **A**, Value `10.0.0.2`,
Description `home Wi-Fi`. **Save** after each; **Apply** once at the end.

| Host | Opens |
|---|---|
| `gate` | Authelia sign-in |
| `tv` | Jellyfin (its own login) |
| `music` | Navidrome |
| `books` | Audiobookshelf |
| `comedy` | Audiobookshelf |
| `sessions` | Audiobookshelf (The Ward) |
| `comics` | Kavita |
| `gaming` | RPG books |
| `arcade` | RomM |
| `papers` | Paperless |
| `metube` | MeTube |
| `command` | Homepage |
| `forms` | forms |
| `vip` | Music Bay keypad |
| `scores` | hiscore board |
| `radio` | radio |
| `ha` | Home Assistant |

Leave these **out**:

- `songofeo.com` itself, `www`: Porkbun hosts them, and Pi-hole forwards them to Unbound. An override would break them for the LAN too.
- `vpn`: Pi-hole forwards it to Unbound too.
- `vault`, `status`: LAN and WireGuard only, on purpose.
- Never a `*` wildcard, for the same reason as `www`.

A name added to Porkbun later (a new Bay) needs a host override here too, or it won't open on the home Wi-Fi.

Check from the-box's PowerShell. This one must now print `10.0.0.2`:

```powershell
Resolve-DnsName tv.songofeo.com -Server 10.0.0.2 -DnsOnly
```

This one must still print `10.6.9.10`. If it changed, stop and tell Claude (LAN devices would hit OPNsense instead of the gate):

```powershell
Resolve-DnsName tv.songofeo.com -DnsOnly
```

And the station's own site must still be Porkbun's address, not `10.0.0.2` or `10.6.9.10`:

```powershell
Resolve-DnsName www.songofeo.com -DnsOnly
```

## 5. WAN rule: DNS from the Xfinity side only

- [ ] **Firewall → Rules → WAN → +**:

| Field | Set to |
|---|---|
| Action | Pass |
| Interface | WAN |
| Direction | in |
| TCP/IP Version | IPv4 |
| Protocol | TCP/UDP |
| Source | Single host or Network, `10.0.0.0/24` |
| Destination | This Firewall |
| Destination port range | DNS to DNS |
| Description | `Xfinity side DNS` |

**Save**, then **Apply changes**.

The 443 forward and "Allow 443 to gate" already cover the web traffic. Nothing else is opened.

## 6. Phone (S21) on Electronomicon

On the phone:

- [ ] Turn WireGuard **off**. In Settings → Connections → More connection settings → VPN → the gear by
      WireGuard: **Always-on VPN off**. Keep the profiles; you still use them away from home.
- [ ] Settings → Connections → More connection settings → **Private DNS**: **Off** (or Automatic).
      A named provider (dns.google, Cloudflare) would skip `10.0.0.2`.
- [ ] Settings → Connections → Wi-Fi → the gear by **Electronomicon** → **View more** → **IP settings**: **Static**.

| Field | Set to |
|---|---|
| IP address | `10.0.0.251` |
| Gateway | `10.0.0.1` |
| Network prefix length | `24` |
| DNS 1 | `10.0.0.2` |
| DNS 2 | empty (delete whatever is there) |

**Save**. Turn Wi-Fi off and on once.

Why no DNS 2: Android uses the second server at random, and a public one answers with the public IP,
which fails at home. The cost: if OPNsense is down, the phone has no DNS on Electronomicon. Switch the
phone to mobile data, or set IP settings back to DHCP, until it's back.

- [ ] In Chrome on the phone: ⋮ → Settings → Privacy and security → **Use secure DNS**: **off**, or
      "Use current service provider". A named provider skips `10.0.0.2`.

### Test on the phone (WireGuard off, on Electronomicon)

- [ ] Chrome: `https://tv.songofeo.com` → Jellyfin login, padlock shown.
- [ ] Chrome: `https://music.songofeo.com` → gate sign-in → Navidrome.
- [ ] A normal site (news, YouTube) still loads.
- [ ] Reload `https://music.songofeo.com` a few times over a minute. It must work every time.
      If it fails now and then, the phone is also using Xfinity's IPv6 DNS: tell Claude. Don't turn
      IPv6 off on the Xfinity router; the work laptop is on it.

On the-box, OPNsense **Firewall → Log Files → Live View**, filter `10.0.0.251`: you should see
green passes to port 53 (This Firewall) and 443 (`10.6.9.10`).

## 7. The TV

Pick the one that matches where the Roku is plugged in.

### 7a. Roku on the Omada switch (50 ft cable, any port except 6)

- [ ] Plug it in. It gets a `10.6.9.x` address and Pi-hole DNS from OPNsense, like the-box.
- [ ] Jellyfin app on the Roku → **Add Server** → `https://tv.songofeo.com` → your Jellyfin login.
- [ ] Nothing to change in OPNsense. If the 8096 forward from 7b was added earlier, **disable** it
      (Firewall → NAT → Port Forward, untick Enabled; don't delete) and Apply.

### 7b. Roku stays on the Xfinity router or Wi-Fi

A Roku can't set its own DNS, so it can't use the names. It goes straight to Jellyfin through one
forward open only to `10.0.0.0/24`: follow [roku-tv/README.md](../roku-tv/README.md) steps 1, 2, 3, 5, 6
(step 1 is already done by step 2 here).

Test from the **phone on Electronomicon**, not from the-box (the-box is on the LAN side, where
`10.0.0.2:8096` doesn't loop back):

```
http://10.0.0.2:8096
```

Jellyfin's login page means the Roku will work. Then on the Roku: **Add Server** → `http://10.0.0.2:8096`.

Optional, so Jellyfin doesn't cap the TV's bitrate as "remote": Jellyfin Dashboard → Networking →
**LAN networks**, add `10.0.0.0/24`.

## Troubleshooting

| Symptom | Check |
|---|---|
| Phone: "site can't be reached" for every station name | Step 2 (Block private networks still ticked), step 5 rule, phone DNS 1 = `10.0.0.2`, Private DNS off. |
| Phone: one name fails, others work | That name has no host override (step 4). |
| Phone: certificate warning | You typed `https://10.0.0.2`. Use the name. |
| Phone: works on data, not at home, WireGuard on | Turn WireGuard off at home; the tunnel's DNS is Pi-hole, which answers `10.6.9.10`, and the cellular tunnel only carries `10.6.9.0/24`. Either state works, but don't mix. |
| the-box or other LAN devices broke | Step 4's second check. Disable the overrides and tell Claude. |
| Work laptop | Nothing here touches it. If it has a problem, it isn't from this. |

## Undo (when the EAP772 arrives)

Disable, don't delete, so each one can be turned back on:

1. Phone: Electronomicon IP settings back to **DHCP**; join the cobra Wi-Fi instead.
2. OPNsense: Firewall → Rules → WAN → `Xfinity side DNS`: disable. Apply.
3. Unbound → Overrides: disable the `home Wi-Fi` entries. Unbound → Access Lists: disable `xfinity-side`. Apply.
4. Unbound → General → Network Interfaces: remove WAN (only if you added it in step 3).
5. Interfaces → [WAN]: tick **Block private networks** again, but only once nothing on the Xfinity side needs
   OPNsense (Roku 7b forward, Cobra1's home WireGuard profile). Save, Apply.
