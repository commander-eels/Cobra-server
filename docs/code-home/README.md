# Code Home runbook (Forgejo at code.songofeo.com) — DRAFT

Uses PowerShell on **the-box** with its 3 tabs: **windows**, **eels@cobra-gate**, **eels@cobra-stream**. Every web step is in **Chrome on the-box**.

## Part A: SGIN (tab eels@cobra-stream)

1. Check the Seagate vault is mounted.

   ```bash
   findmnt /srv/storage/vault
   ```

   You should see one line with `/srv/storage/vault` and `ext4`. Nothing printed: stop (Appendix A1).

2. Check the new folder does not exist yet.

   ```bash
   ls -ld /srv/storage/vault/code
   ```

   You should see `No such file or directory`. Anything else: stop (Appendix A2).

3. Make the folder.

   ```bash
   sudo mkdir /srv/storage/vault/code
   ```

4. Give it to podsvc.

   ```bash
   sudo chown podsvc: /srv/storage/vault/code
   ```

5. Lock it to podsvc only.

   ```bash
   sudo chmod 700 /srv/storage/vault/code
   ```

   You should see no output from steps 3 to 5.

6. Save a copy of the firewall file.

   ```bash
   sudo cp /etc/nftables.conf /etc/nftables.conf.bak-before-code
   ```

7. Show the firewall's port line.

   ```bash
   grep -n "tcp dport" /etc/nftables.conf
   ```

   You should see a line ending in `13378 } accept`. A different ending: stop (Appendix A7).

8. Add ports 2222 and 3000 to that line.

   ```bash
   sudo sed -i 's/13378 } accept/13378, 2222, 3000 } accept/' /etc/nftables.conf
   ```

9. Test the file before loading it.

   ```bash
   sudo nft -c -f /etc/nftables.conf
   ```

   You should see no output. An error: Appendix A9.

10. Load it.

    ```bash
    sudo systemctl restart nftables
    ```

11. Confirm the new ports are live.

    ```bash
    sudo nft list ruleset | grep 3000
    ```

    You should see the port list with `2222, 3000` in it.

12. Keep this tab open. In the **windows** tab, check SSH to the SGIN still works.

    ```powershell
    ssh eels@10.6.9.20
    ```

    You should see the `eels@cobra-stream` prompt. Type `exit` to close it. If it fails: Appendix A12.

13. Back in tab **eels@cobra-stream**, log in as podsvc.

    ```bash
    sudo machinectl shell podsvc@
    ```

    You should see the prompt `podsvc@cobra-stream`.

14. Get the new scripts.

    ```bash
    git -C ~/cobra-server pull
    ```

    You should see `forgejo.sh` and `forgejo-backup.sh` in the list of changed files. Error: Appendix A14.

15. Go to the SGIN scripts.

    ```bash
    cd ~/cobra-server/scripts/podman/sgin
    ```

16. Start the Code Home.

    ```bash
    ./forgejo.sh
    ```

    You should see `generated random password is '...'` (the part inside the quotes is the password), then `forgejo is running`.

17. Copy that password into Vaultwarden now (name it `Code Home first password`). It is shown only once.

18. Check it runs.

    ```bash
    podman ps --pod --filter pod=code
    ```

    You should see `forgejo` with `Up` and pod `code`.

19. Leave podsvc.

    ```bash
    exit
    ```

## Part B: Gate (tab eels@cobra-gate)

20. Log in as podsvc.

    ```bash
    sudo machinectl shell podsvc@
    ```

    You should see the prompt `podsvc@cobra-gate`.

21. Get the new files.

    ```bash
    git -C ~/cobra-server pull
    ```

22. Check there is no `code.conf` yet.

    ```bash
    ls /srv/gate/nginx/conf.d/code.conf
    ```

    You should see `No such file or directory`. Anything else: stop (Appendix B22).

23. Copy the nginx file in (`-n` never overwrites).

    ```bash
    cp -n ~/cobra-server/apps/code-home/gate/code.conf /srv/gate/nginx/conf.d/code.conf
    ```

24. Save a copy of Authelia's settings.

    ```bash
    cp /srv/gate/authelia/configuration.yml /srv/gate/authelia/configuration.yml.bak-before-code
    ```

25. Open Authelia's settings.

    ```bash
    nano /srv/gate/authelia/configuration.yml
    ```

26. Find the line `rules:` under `access_control:`. Put the cursor at the start of the line just below `rules:`.

27. Paste these lines there (right-click pastes in PowerShell). Keep the 4 spaces in front of each `-`.

    ```yaml
        - domain: code.songofeo.com
          subject: ["user:eels"]
          policy: two_factor
        - domain: code.songofeo.com
          policy: deny
    ```

28. Save and close: press `Ctrl+O`, then `Enter`, then `Ctrl+X`.

29. Test nginx.

    ```bash
    podman exec nginx nginx -t
    ```

    You should see `syntax is ok` and `test is successful`. Error: Appendix B29.

30. Load the nginx change.

    ```bash
    podman exec nginx nginx -s reload
    ```

31. Restart Authelia.

    ```bash
    systemctl --user restart authelia
    ```

32. Check Authelia came back.

    ```bash
    systemctl --user is-active authelia
    ```

    You should see `active`. Anything else: Appendix B32.

33. Run the gate check.

    ```bash
    ~/cobra-server/scripts/podman/gate/check.sh
    ```

    You should see `OK  code.songofeo.com  302 to the sign-in (Forgejo)` under **Code Home**.

34. Leave podsvc.

    ```bash
    exit
    ```

## Part C: DNS (Chrome on the-box)

35. Open `https://porkbun.com` → sign in → **Domain Management** → `songofeo.com` → **DNS**.

36. Fill in the new record:

    | Field | Action |
    |---|---|
    | Type | Dropdown: pick `CNAME` |
    | Host | Type `code` |
    | Answer | Type `gate.songofeo.com` |
    | TTL | Leave `600` |

37. Click **Add**. You should see `code.songofeo.com CNAME gate.songofeo.com` in the list.

38. Open OPNsense (`https://10.6.9.1`) → **Services → Unbound DNS → Overrides** → **+** under Hosts.

39. Fill in the override (it lets the home Wi-Fi reach the name):

    | Field | Action |
    |---|---|
    | Enabled | Tick it |
    | Host | Type `code` |
    | Domain | Type `songofeo.com` |
    | Type | Dropdown: pick `A` |
    | Value | Type `10.0.0.2` |
    | Description | Type `Code Home` |

40. Click **Save**, then **Apply**.

41. In the **windows** tab, check the name.

    ```powershell
    Resolve-DnsName code.songofeo.com -DnsOnly
    ```

    You should see `10.6.9.10`.

## Part D: First sign-in (Chrome on the-box)

42. Open `https://code.songofeo.com`. You should see the gate sign-in. Sign in as `eels` with your TOTP code.

43. You should see **Code Home** with a **Sign in** button. Click it.

44. Username: type `eels`. Password: paste the first password from Vaultwarden (step 17). Click **Sign in**.

45. You should see **Change password**. Type a new password twice and click **Update password**. Save it in Vaultwarden as `Code Home` (replace the first password).

46. Top right: your avatar → **Settings** → **Security** → **Two-factor authentication** → **Enroll**.

47. Scan the QR code with your authenticator app, type the 6-digit code, click **Verify**. Save the scratch code in Vaultwarden.

## Part E: Hourly copies from GitHub (Chrome on the-box)

48. Open `https://github.com/settings/personal-access-tokens/new`.

49. Fill in the token:

    | Field | Action |
    |---|---|
    | Token name | Type `code-home-mirror` |
    | Resource owner | Dropdown: pick `agent61636` |
    | Expiration | Dropdown: pick `366 days` (or the longest offered) |
    | Repository access | Click **Only select repositories**, then pick `formidable-flow` |
    | Permissions → Repositories → Contents | Dropdown: pick `Read-only` |

50. Click **Generate token**, then copy the token. Save it in Vaultwarden as `GitHub code-home-mirror token`.

51. Open `https://code.songofeo.com/repo/migrate?service_type=2` (Forgejo's **New migration → GitHub** page).

52. Fill in the form:

    | Field | Action |
    |---|---|
    | Migrate / Clone from URL | Type `https://github.com/agent61636/formidable-flow` |
    | Access token | Paste the token from step 50 |
    | This repository will be a mirror | Tick it |
    | LFS | Tick it |
    | Owner | Dropdown: pick `eels` |
    | Repository name | Type `formidable-flow` |
    | Visibility | Leave **Private** (it is locked on) |

53. Click **Migrate repository**. You should see the repo page with `mirror of https://github.com/agent61636/formidable-flow` under its name.

54. Open the repo → **Settings** → **Mirror settings**. You should see **Mirror interval** `1h0m0s`.

## Part F: Nightly backup (tab eels@cobra-stream)

55. Log in as podsvc.

    ```bash
    sudo machinectl shell podsvc@
    ```

56. Go to the SGIN scripts.

    ```bash
    cd ~/cobra-server/scripts/podman/sgin
    ```

57. Run the first backup.

    ```bash
    ./forgejo-backup.sh
    ```

    You should see `backup done` and `daily Code Home backup enabled (03:40, as podsvc)`.

58. Check the timer.

    ```bash
    systemctl --user list-timers cobra-code-backup.timer
    ```

    You should see one line with tomorrow's date and `03:4`.

59. Leave podsvc.

    ```bash
    exit
    ```

Done. The Code Home is at `https://code.songofeo.com`, copies GitHub every hour, and backs up every night.

---

## Appendix (keyed by step)

**What this is.** Forgejo 15 (the LTS line, supported until 15 July 2027) in its own pod `code` on the SGIN. Web on `10.6.9.20:3000`, git over SSH on `10.6.9.20:2222`, both LAN and WireGuard only. The gate's `code.songofeo.com` adds the sign-in + TOTP in front. Data: `/srv/storage/vault/code` on the Seagate. Backups: `forgejo-YYYYMMDD-HHMMSS.zip`, 14 kept in `/srv/storage/vault/code/data/dumps` and 14 in `dock1a/backups/code`. Mirrors are read-only copies: changes still go to GitHub, and the Code Home picks them up within the hour. Scripts: `scripts/podman/sgin/forgejo.sh`, `forgejo-backup.sh`; nginx: `apps/code-home/gate/code.conf`.

**A1.** The vault isn't mounted. Run `lsblk -f` and look for the Seagate (UUID `02f0a4af-…`). Don't make the folder on the SSD: the script refuses to run unless the vault is mounted.

**A2.** The folder already exists. Don't change or delete it. Run `ls -la /srv/storage/vault/code` and send Claude the output.

**A7.** Your port line has a different end (ports were added since the manual). Run `sudo nano /etc/nftables.conf`, add `, 2222, 3000` just before the `}` on the `tcp dport` line, save, then continue at step 9.

**A9.** The test found a typo. Put the saved file back with `sudo cp /etc/nftables.conf.bak-before-code /etc/nftables.conf`, then redo steps 7 and 8 (or A7).

**A12.** SSH stopped working. In the still-open eels@cobra-stream tab run `sudo cp /etc/nftables.conf.bak-before-code /etc/nftables.conf`, then `sudo systemctl restart nftables`, then send Claude the step 7 output.

**A14.** `~/cobra-server` isn't there for podsvc. Run `git clone https://github.com/commander-eels/Cobra-server ~/cobra-server`, then continue at step 15.

**16, update later.** `UPDATE=1 ./forgejo.sh` pulls the newest 15.x and keeps the data. Read the release notes first. If `codeberg.org` is down, `FORGEJO_IMAGE=data.forgejo.org/forgejo/forgejo:15-rootless ./forgejo.sh` uses Forgejo's own mirror.

**16, lost the first password.** As podsvc: `podman exec forgejo forgejo admin user change-password --username eels --password '<new>' --must-change-password`.

**B22.** A `code.conf` already exists. Don't overwrite it. Send Claude `cat /srv/gate/nginx/conf.d/code.conf`.

**B29.** nginx refused the file. Move it aside with `mv /srv/gate/nginx/conf.d/code.conf ~/code.conf.off`, run `podman exec nginx nginx -t` again (it must pass), and send Claude the error.

**B32.** Authelia didn't start: usually the pasted lines lost their spaces. Put the copy back with `cp /srv/gate/authelia/configuration.yml.bak-before-code /srv/gate/authelia/configuration.yml`, run `systemctl --user restart authelia`, then redo steps 25 to 32.

**36.** If Porkbun already has a `code` record (or the `*` wildcard points at cPanel), edit that one instead of adding a second.

**39.** Field names are from OPNsense 26.7. A newer build may label **Type** as **Record type**.

**49.** A fine-grained token can't be made without an expiry. Put a reminder in your calendar a week before it ends. When it does, mirrors stop updating (the copies stay). Make a new token and paste it in each repo's **Settings → Mirror settings → Authorization**.

**52.** If **This repository will be a mirror** is greyed out, the token is wrong. Check it has Contents: Read-only on that repo.

**52, more repos.** Each new repo (DE, Babelforms, anything later) is steps 51 to 53 again with its URL. A fine-grained token covers one GitHub owner only: a repo under another owner (for example `commander-eels/Cobra-server`) needs its own token from step 48 with that owner picked.

**Git over SSH (optional, for repos that live only at home).** In the windows tab: `ssh-keygen -t ed25519 -f $HOME\.ssh\code-home`, then paste `$HOME\.ssh\code-home.pub` into Forgejo → **Settings → SSH / GPG keys → Add key**. Test with `ssh -i $HOME\.ssh\code-home -p 2222 git@10.6.9.20`; you should see `Hi there, eels!`. Mirrors stay read-only, so this is for new home-only repos.

**Restore a backup.** Stop and ask Claude first. The dump holds every repo, the database and `app.ini` (with the secret key that unlocks the saved token and 2FA), so it is readable by podsvc only.

**Undo everything.** Porkbun: delete the `code` record. OPNsense: untick the `code` override, Apply. Gate as podsvc: `mv /srv/gate/nginx/conf.d/code.conf ~/code.conf.off` and reload nginx; remove the two Authelia lines and restart it. SGIN as podsvc: `podman pod rm -f code` (the data on the vault stays). SGIN as eels: `sudo cp /etc/nftables.conf.bak-before-code /etc/nftables.conf` and restart nftables.

**Sources (checked 2026-11-28).** [Forgejo release schedule](https://forgejo.org/docs/v15.0/admin/release-schedule/), [Forgejo v15 Docker install](https://forgejo.org/docs/v15.0/admin/installation/docker/), [Forgejo v17.0 notes](https://forgejo.org/2026-10-release-v17-0/).
