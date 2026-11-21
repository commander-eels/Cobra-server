# Roku TV: watch Jellyfin from the Xfinity side

The TV stays plugged into the Xfinity router (or on Xfinity Wi-Fi). It reaches Jellyfin through
one Destination NAT rule on OPNsense, open only to the home Xfinity network. Nothing is opened to the internet.

| Item | Value |
|---|---|
| TV network | Xfinity, `10.0.0.x` |
| OPNsense WAN address | `10.0.0.2` |
| Jellyfin (SGIN) | `10.6.9.20:8096` |
| Address to type on the Roku | `http://10.0.0.2:8096` |
| Allowed source | `10.0.0.0/24` only |

Do every step on **the-box**, in the OPNsense web page.

## 0. SGIN firewall first

The SGIN only accepts 8096 from the cobra LAN and WireGuard. Run `F37-sgin-firewall-roku-tv.sh` from the cobra-fix v3.1 zip first (see [home-wifi 7b](../home-wifi/README.md#7b-roku-stays-on-the-xfinity-router-or-wi-fi)).

## 1. Let private addresses in on WAN

Interfaces > WAN: untick **Block private networks**, then **Save** and **Apply**.

If you skip this, OPNsense drops everything coming from `10.0.0.x`.

## 2. Add the Destination NAT rule

Firewall > NAT > Destination NAT, then **+**.

| Field | How to set it |
|---|---|
| Interface | Dropdown: pick **WAN** |
| Protocol | Dropdown: pick **TCP** |
| Source | Type `10.0.0.0/24` (if Source is hidden, click **Advanced** first; if it's a dropdown, pick **Single host or Network** and type `10.0.0.0/24` next to it) |
| Destination | Dropdown: pick **WAN address** |
| Destination port | **One box:** type `8096`. **Two dropdowns ("from" and "to"):** pick **(other)** in both and type `8096` in both |
| Redirect target IP | Type `10.6.9.20` (if it's a dropdown, pick **Single host or Network** first) |
| Redirect target port | Type `8096` (or pick **(other)** and type `8096`) |
| Firewall rule (26.1+, replaces "Filter rule association") | Dropdown: pick **Register rule**. The default, Manual, makes no pass rule, and the TV stays blocked |
| Description | Type `Roku to Jellyfin` |

**Save**, then **Apply**.

## 3. Check the rule

Firewall > Rules, with WAN selected and **Inspect** on: **Roku to Jellyfin** appears under the automatically generated rules. If it's missing, the Destination NAT rule is still on Manual.

## 4. Test from the phone on Electronomicon

Not from the-box: it's on the LAN side, where `10.0.0.2:8096` doesn't loop back. With WireGuard off on the phone, open:

```
http://10.0.0.2:8096
```

You should see the Jellyfin login. If it does not load, check steps 1 to 3 again before trying the TV.

## 5. On the Roku

In the Jellyfin app, choose **Add Server**, enter the address below, then log in.

```
http://10.0.0.2:8096
```

## 6. In Jellyfin

Dashboard > Networking: make sure **Allow remote connections** is on. Jellyfin counts the TV as
remote, because its `10.0.0.x` address is not one of the SGIN's own networks.

## Notes

| Question | Answer |
|---|---|
| Why not `tv.songofeo.com` on the TV? | The Xfinity router cannot loop traffic back in to your own server, so the name fails from the Xfinity side. Use `10.0.0.2` directly. |
| Does this affect the work laptop? | No. Nothing on the Xfinity router changes, and the DMZ stays as it is. |
| Is anything open to the internet? | No. The forward only accepts sources in `10.0.0.0/24`. |
