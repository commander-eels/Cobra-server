# Security decision log

One short entry per risk the owner (CSO) knowingly accepts. Security is always a trade between the
three goals of the CIA triad: **Confidentiality** (only the right people see it), **Integrity**
(nobody changes it without permission) and **Availability** (it's there and easy to use when you
need it). Writing each trade down is normal CSO practice: it shows the risk was weighed on purpose,
names what still protects you, and sets a date to look at it again instead of letting it drift.

Newest first. Don't edit an old entry's decision; add a new entry that replaces it.

| Field | Meaning |
|---|---|
| Decision | What was chosen, in one line |
| Threat | What could go wrong |
| Likelihood | Low / medium / high, and who judged it |
| Controls | What still protects you |
| Review | When to look again |

---

## 2026-11-21: Home Wi-Fi reaches the gate without WireGuard

| Field | Entry |
|---|---|
| Decision | Devices on the Xfinity Wi-Fi/LAN (`Electronomicon`, `10.0.0.0/24`) reach the gate and pods directly, with the Authelia sign-in, no WireGuard at home. Availability over a full tunnel lockdown. |
| Threat | A neighbor joins or sniffs the Xfinity Wi-Fi and reaches the gate's sign-in page or the TV's Jellyfin port. |
| Likelihood | Low. Assessed by the owner as CSO: older, non-technical neighbors; their own networks are mostly default or open. |
| Controls | WPA password on the Wi-Fi; Authelia sign-in on every app except `tv.` (Jellyfin's own login); HTTPS with a valid cert; OPNsense rules accept only source `10.0.0.0/24` (DNS 53, 443, Roku 8096), nothing new open to the internet; `vault.`/`status.` stay LAN/WireGuard only; WireGuard kept for remote use. |
| How | [home-wifi/README.md](../home-wifi/README.md) (includes the undo list). |
| Review | 2027-05-21, or sooner when the EAP772 access point arrives. |
