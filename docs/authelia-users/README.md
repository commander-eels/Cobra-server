# Authelia users: quick steps

How to add, change, pause or remove a person who signs in at `gate.songofeo.com`.
The full setup is manual part 5.4 ([05-final-touches.md](../manual/05-final-touches.md)).
This page is only the day-to-day steps.

| What | Where |
|---|---|
| Machine | **cobra-gate**, Proxmox VM 110, `10.6.9.10` |
| Run from | **the-box**, Windows Terminal |
| Users file | `/srv/gate/authelia/users.yml` (not in git, never copy it into the repo) |
| Config file | `/srv/gate/authelia/configuration.yml` |
| One-time codes | `/srv/gate/authelia/notification.txt` |
| Container / service | `authelia` (Quadlet, `systemctl --user`) |

Two things to know before you start:

- **Every restart of Authelia signs everyone out once.** They just sign in again (tick Remember me).
- Authelia does not reread `users.yml` on its own. A change only takes effect after the restart in step 5.

## 1. Get to the gate as podsvc

On the-box, open Windows Terminal and connect to the gate. The prompt should become `eels@cobra-gate:~$`.

```bash
ssh eels@10.6.9.10
```

Switch to podsvc. Authelia runs as this user, so every step below is done here.
The prompt should become `podsvc@cobra-gate:~$`. Type `exit` to go back to eels when you are done.

```bash
sudo machinectl shell podsvc@
```

## 2. Back up the users file

Do this every time, before any edit. It makes a dated copy next to the file.

```bash
cp -p /srv/gate/authelia/users.yml /srv/gate/authelia/users.yml.bak-$(date +%Y%m%d-%H%M%S)
```

Check the copy is there (the newest is at the top):

```bash
ls -lt /srv/gate/authelia/users.yml*
```

## 3. Make a password hash (new person, or a new password)

Skip this step if you are only pausing, removing or changing groups.

This asks for the password twice without showing it, and prints one line starting with `Digest:`.

```bash
podman exec -it authelia authelia crypto hash generate argon2
```

Copy everything after `Digest: ` (it starts with `$argon2id$`). You paste it in the next step.
Do not paste it into chat, a note, or git.

## 4. Edit the users file

```bash
nano /srv/gate/authelia/users.yml
```

In nano: right-click (or Ctrl+Shift+V in Windows Terminal) pastes. Ctrl+O then Enter saves. Ctrl+X quits.
Indent with **spaces only**, never Tab. Each level is two spaces.

### Add a person

Add a block under `users:`, lined up with the others. The username (the line ending in `:`) is
what they type at sign-in. Use lowercase, and the **same username** they have in Navidrome.

```yaml
  newname:
    displayname: New Name
    email: their@email.example
    password: "$argon2id$PASTE_THE_WHOLE_DIGEST_HERE"
    groups:
      - music
```

- Keep the double quotes around the hash.
- `groups: - music` lets them open `music.` and `mustang.`. Leave the `groups` lines out if they
  should **not** see music. Everything else on the station (books, comics, comedy, sessions,
  arcade, art) is open to anyone who can sign in.
- `tv.` (Jellyfin) does not use this file. Give them a Jellyfin user separately
  ([gate-sso-tv-runbook.md](../gate-sso-tv-runbook.md), step 3).

### Change a password

Find the person's block and replace only the text inside the quotes on the `password:` line with
the new digest from step 3.

They can also do it themselves: **Forgot password?** on the sign-in page. The reset code is written
to `notification.txt` instead of being emailed, so you read it out to them (step 7).

### Change groups

Add or remove the `- music` line under their `groups:`. If `groups:` would end up empty, delete
the `groups:` line too.

### Pause a person (keep their account, block sign-in)

Add this line inside their block, lined up with `displayname:`:

```yaml
    disabled: true
```

Delete the line again to let them back in.

### Remove a person

Delete their whole block: the username line and every indented line under it. Their session ends
at the restart.

## 5. Restart Authelia and check it came back

```bash
systemctl --user restart authelia
```

Wait about 5 seconds, then:

```bash
systemctl --user is-active authelia
```

It must print `active`. If it prints anything else, go to step 8 (undo).

Count the hashes. The number must equal the number of people in the file:

```bash
grep -c 'argon2id' /srv/gate/authelia/users.yml
```

## 6. Test the sign-in

On the-box, open a **private window** and go to `https://gate.songofeo.com`.
Sign in with the username and password. For someone with `music`, also open
`https://music.songofeo.com`: it should load Navidrome, not say *forbidden*.

A brand-new music user: that first visit to `music.` creates their Navidrome account with no
libraries. Then, as eels in Navidrome: user menu (top right) → **Users** → the person → tick their
libraries and set a password for phone apps ([music.md](../music.md), "Someone new").

## 7. Two-factor (TOTP) for the admin apps

Only for people who use `papers.`, `metube.`, `command.` or `status.`. Do it on the-box.

1. In the-box's browser open one of those names, sign in, choose **Register device** →
   **One-Time Password**.
2. Authelia says it sent a code by email. Read it in the podsvc terminal:

```bash
tail -n 20 /srv/gate/authelia/notification.txt
```

3. Type the code into the browser. A QR code appears on the-box's screen. Scan it with the
   authenticator app on the phone (Aegis, 2FAS, Google Authenticator or Bitwarden).
4. Empty the codes file afterwards:

```bash
: > /srv/gate/authelia/notification.txt
```

### Lost phone: reset someone's TOTP

This deletes their registered device so they can register a new one (step 7 again). Replace
`USERNAME` with theirs.

```bash
podman exec authelia authelia storage user totp delete USERNAME --config /config/configuration.yml
```

No restart is needed for this one.

## 8. Undo (Authelia did not come back)

See why first. The last lines usually name the line in `users.yml` that is wrong
(almost always a Tab, a missing space, or a missing quote).

```bash
podman logs --tail 30 authelia
```

Find the newest backup (top of the list):

```bash
ls -t /srv/gate/authelia/users.yml.bak-*
```

Copy it back. Replace `BACKUP_NAME` with the name from the list.

```bash
cp -p /srv/gate/authelia/BACKUP_NAME /srv/gate/authelia/users.yml
```

Restart and check again:

```bash
systemctl --user restart authelia
```

```bash
systemctl --user is-active authelia
```

## 9. Save a snapshot (optional, recommended)

The nightly timer does this at 03:10 anyway. Run it now if you made a big change.
It copies `users.yml`, the TOTP database and `configuration.yml` into `/srv/backups/personal-state/authelia/`
(manual part 13).

```bash
~/cobra-server/scripts/podman/gate/state-backup.sh
```

Then `exit` twice: once to leave podsvc, once to leave the gate.

## Old backups

Each edit leaves one `users.yml.bak-<date>` file. They hold password hashes, so delete old ones
once you are happy, one at a time by name:

```bash
ls -lt /srv/gate/authelia/users.yml.bak-*
```

```bash
rm /srv/gate/authelia/BACKUP_NAME
```

## Notes

- The live file name comes from `authentication_backend.file.path` in `configuration.yml`. This
  repo sets `/config/users.yml`. If yours says `users_database.yml`, use
  `/srv/gate/authelia/users_database.yml` everywhere above. Check with:

```bash
grep -n 'path:' /srv/gate/authelia/configuration.yml
```

- Five wrong passwords in 10 minutes locks that username for 1 hour (`regulation` in
  `configuration.yml`). Restarting Authelia does not clear that, and waiting does.
- Who may open what is in `access_control` in `configuration.yml`, not in this file. The music
  wall allows `user:eels`, `user:rachel` and `group:music`.
