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

## 2026-11-28: Code Home copies of the repos live in the house, GitHub stays the workbench

| Field | Entry |
|---|---|
| Decision | Forgejo on the SGIN keeps an hourly pull mirror of each GitHub repo (owner chose "GitHub first"). Claude and Grok keep working on GitHub. Availability and integrity (a second, owned copy) over keeping the code in one place only. |
| Threat | Someone reaches `code.songofeo.com` and reads private code, or the house loses both drives (fire, theft) at once. |
| Likelihood | Low. Assessed by Claude for the owner; owner to confirm. |
| Controls | Authelia sign-in + TOTP for `eels` only, then Forgejo's own login with 2FA; signups off; every repo forced private; git over SSH only on the LAN and WireGuard; the GitHub token is read-only; nightly dumps on two drives (vault and dock1a), mode 600; GitHub itself is the off-site copy. |
| How | [code-home/README.md](../code-home/README.md) (includes the undo list). |
| Review | 2027-06-28, before Forgejo 15 LTS support ends (2027-07-15). |

## 2026-11-21: Home Wi-Fi reaches the gate without WireGuard

| Field | Entry |
|---|---|
| Decision | Devices on the Xfinity Wi-Fi/LAN (`Electronomicon`, `10.0.0.0/24`) reach the gate and pods directly, with the Authelia sign-in, no WireGuard at home. Availability over a full tunnel lockdown. |
| Threat | A neighbor joins or sniffs the Xfinity Wi-Fi and reaches the gate's sign-in page or the TV's Jellyfin port. |
| Likelihood | Low. Assessed by the owner as CSO: older, non-technical neighbors; their own networks are mostly default or open. |
| Controls | WPA password on the Wi-Fi; Authelia sign-in on every app except `tv.` (Jellyfin's own login); HTTPS with a valid cert; OPNsense rules accept only source `10.0.0.0/24` (DNS 53, 443, Roku 8096), nothing new open to the internet; `vault.`/`status.` stay LAN/WireGuard only; WireGuard kept for remote use. |
| How | [home-wifi/README.md](../home-wifi/README.md) (includes the undo list). |
| Review | 2027-05-21, or sooner when the EAP772 access point arrives. |
