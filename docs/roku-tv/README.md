# Roku TV: watch Jellyfin from the Xfinity side

The TV stays plugged into the Xfinity router (or on Xfinity Wi-Fi). It reaches Jellyfin through
one port forward on OPNsense, open only to the home Xfinity network. Nothing is opened to the internet.

| Item | Value |
|---|---|
| TV network | Xfinity, `10.0.0.x` |
| OPNsense WAN address | `10.0.0.2` |
| Jellyfin (SGIN) | `10.6.9.20:8096` |
| Address to type on the Roku | `http://10.0.0.2:8096` |
| Allowed source | `10.0.0.0/24` only |

Do every step on **the-box**, in the OPNsense web page.

## 1. Let private addresses in on WAN

Interfaces > WAN: untick **Block private networks**, then **Save** and **Apply**.

If you skip this, OPNsense drops everything coming from `10.0.0.x`.

## 2. Add the port forward

Firewall > NAT > Port Forward, then **+**.

| Field | Set to |
|---|---|
| Interface | WAN |
| Protocol | TCP |
| Source | `10.0.0.0/24` |
| Destination | WAN address |
| Destination port | `8096` |
| Redirect target IP | `10.6.9.20` |
| Redirect target port | `8096` |
| Filter rule association | Add associated filter rule |
| Description | `Roku to Jellyfin` |

**Save**, then **Apply**.

## 3. Check the rule

Firewall > Rules > WAN should list **Roku to Jellyfin** above any block rules.

## 4. Test from the-box

Turn PIA off first (it moves traffic off the local network). Then open:

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
