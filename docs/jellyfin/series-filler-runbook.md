# Cobra Series Filler v1.0: filler clips before TV episodes

Do the steps in order and tick each box. Every grey box is one thing to type or paste, then press Enter. Help for any step is at the very end, under **Help**, by step number.

Your PowerShell tabs: **`windows`** and **`eels@cobra-stream`**. Browser = your normal browser on the-box.

---

## Part 1. Check Jellyfin

- [ ] **1.1** Browser: open `https://tv.songofeo.com` → sign in → click the **☰** menu (top left) → **Dashboard**. You should see: under the server name at the top left of the Dashboard, a version that starts with `12.` (for example `12.4`).

- [ ] **1.2** Browser: Dashboard → **Plugins** → click the **Installed** chip. You should see: a card for your **Local Intros** plugin. Leave it as it is.

---

## Part 2. Copy the plugin to the SGIN

- [ ] **2.1** the-box: click the PIA tray icon → **Disconnect**. You should see: the PIA icon turns grey.

- [ ] **2.2** File Explorer: open `V:\=ClaudeCode=` → right-click `series-filler-v1.0.zip` → **Extract All** → **Extract**. You should see: a new folder `series-filler-v1.0` with a `series-filler` folder inside.

- [ ] **2.3** `windows` tab, type:

```powershell
cd "V:\=ClaudeCode=\series-filler-v1.0"
```

You should see: the prompt now ends in `\series-filler-v1.0>`.

- [ ] **2.4** `windows` tab, type:

```powershell
scp -r .\series-filler eels@10.6.9.20:/tmp/
```

Type eels's password when it asks. You should see: three lines ending in `100%` (the `.dll`, the `.sh` and `README.md`).

---

## Part 3. Install and set it up

- [ ] **3.1** `eels@cobra-stream` tab, type:

```bash
sudo bash /tmp/series-filler/install-series-filler.sh
```

Type eels's password if sudo asks. You should see, in green: `Found N video clips in /srv/storage/disks/wd1/filler`, then after about a minute `Installed. Jellyfin loaded Cobra Series Filler 1.0.0.0. Next: README step 3.2`.

- [ ] **3.2** Browser: press **Ctrl + F5** → ☰ → **Dashboard** → **Plugins** → **Installed** chip. You should see: a **Cobra Series Filler** card next to Local Intros.

- [ ] **3.3** Browser: click the **Cobra Series Filler** card → **Settings**. You should see: a page titled **Cobra Series Filler** with seven settings.

- [ ] **3.4** **Filler folder**: clear the box, then type `/media/wd1/filler`

- [ ] **3.5** **Include subfolders**: make sure it is **ticked**.

- [ ] **3.6** **Fewest clips**: type `1`

- [ ] **3.7** **Most clips**: type `3`

- [ ] **3.8** **Chance an episode gets filler (%)**: type `100`

- [ ] **3.9** **Don't repeat the last ... clips**: type `10`

- [ ] **3.10** **Skip tag**: type `nofiller`

- [ ] **3.11** Click **Save**. You should see: a short **Settings saved** message.

---

## Part 4. Turn on Cinema mode and test

- [ ] **4.1** Browser: click your **profile picture** (top right) → **Playback** → tick **Cinema mode** → scroll down → **Save**. You should see: **Settings saved**.

- [ ] **4.2** Browser: open any show → open an episode you haven't started → click **Play**. You should see: 1, 2 or 3 filler clips, then the episode.

- [ ] **4.3** Browser: open any movie you haven't started → click **Play**. You should see: one Local Intros pre-roll as before, then the movie (no extra filler).

- [ ] **4.4** Roku: Jellyfin app → **Settings** → **Playback** → **Cinema Mode** → **Enabled**. You should see: Cinema Mode shows **Enabled**.

- [ ] **4.5** Roku: open any show → an episode you haven't started → **Play**. You should see: one filler clip, then the episode.

- [ ] **4.6** `eels@cobra-stream` tab, type:

```bash
sudo bash /tmp/series-filler/install-series-filler.sh --log
```

You should see: lines like `[CobraSeriesFiller] eels -> 'The Simpsons' Bart the Genius: ad12.mp4, psa3.mp4`, one per episode you started.

---

## Part 5. Optional: no filler for one show

- [ ] **5.1** Browser: open the show → **⋮** (three dots) → **Edit metadata**. You should see: the metadata editor.

- [ ] **5.2** **Tags**: click **+** → type `nofiller` → **OK**.

- [ ] **5.3** Click **Save**. You should see: the editor closes. That show's episodes now start without filler (a season or one episode can be tagged the same way).

**Done.**

---

## Help

**What this plugin does and doesn't do.** When an app starts an episode, Jellyfin asks the server for "intros". This plugin answers only for TV episodes, with 1 to 3 random clips from the filler folder. Local Intros keeps answering for movies. The apps ask only once, when you press Play. When the next episode autoplays, nothing is asked, so **no plugin can add clips between autoplayed episodes**. For commercial breaks between episodes, use the **"Show — with breaks"** playlists from cobra-breaks (manual part 6) or an ErsatzTV channel.

| App | Filler before an episode? |
|---|---|
| Browser, Jellyfin Media Player | Yes, 1 to 3 clips (needs Cinema mode, step 4.1) |
| Roku | Yes, **1 clip** (the Roku app plays only the first intro; needs step 4.4) |
| Android TV, Fire TV, Google TV | No: that app asks for intros before movies only |
| Resuming a half-watched episode | No, in every app (on purpose) |

**1.1** The version starts with `10.`: stop here and tell Claude. This build is for Jellyfin 12 only and won't load on 10.x.

**1.2** No Local Intros card: that's fine, the series filler works without it. Movies just won't get a pre-roll.

**2.1** PIA re-connects by itself after a while. If `scp` hangs or says `Connection timed out`, disconnect PIA again and repeat 2.4.

**2.2** No zip in `V:\=ClaudeCode=`: save the `series-filler-v1.0.zip` from the Claude thread into that folder first.

**2.4** `Permission denied`: the password is eels's password on cobra-stream. `Could not resolve` or `timed out`: see 2.1.

**3.1**
- `Another copy is already installed`: nothing was changed. Send that line to Claude; the script never overwrites a copy.
- `This exact version is already installed`: fine, go to 3.2.
- `No folder /srv/storage/disks/wd1/filler`: your filler folder has another name. Find it in File Explorer under `\\cobra-stream\media\wd1`, and use that name in 3.4 (`/media/wd1/<name>`).
- `Found 0 video clips`: put some short videos in `\\cobra-stream\media\wd1\filler` first.
- `doesn't show the plugin loading yet`: wait a minute and do 3.2. If the card is missing after Ctrl + F5, send Claude a screenshot of Dashboard → Plugins.

**3.3** The card shows **Not supported** or **Malfunctioned**: send Claude a screenshot of the card and the Jellyfin version from 1.1.

**3.4** Your ads and PSAs are in their own subfolder: type that subfolder instead, for example `/media/wd1/filler/ads`. `/media/...` is how Jellyfin sees `\\cobra-stream\media\...`.

**3.6–3.7** Both `1` = always exactly one clip. Roku plays one no matter what.

**3.8** `50` = about half of the episodes get filler.

**3.9** Avoids playing the same clip again within the last 10 picked. Keep it below the number of clips you have.

**4.1** Cinema mode is per user and per app. Every person who should see filler turns it on in their own Playback settings, in each app they use. It's probably already on where Local Intros works for you.

**4.2** No filler:
- You clicked **Resume**: intros never play when resuming. Pick an episode you haven't started, or use **Play from beginning**.
- Do step 4.6. `tagged 'nofiller'` = the show has that tag (Part 5). `No video files in '/media/wd1/filler'` = wrong folder in 3.4. No lines at all = Cinema mode is off (4.1).

**4.3** A pre-roll **and** filler before an episode, or filler before a movie: send Claude the 4.6 lines and a screenshot of your Local Intros settings page.

**4.4** On some Roku app versions Settings is in the left-side menu of the home screen. Look for **Playback** → **Cinema Mode**.

**4.5** Only ever one clip: that's how the Roku app works (see the table above).

**Undo:** Browser: Dashboard → Plugins → **Cobra Series Filler** card → **Uninstall**, then Dashboard → **Restart**. Movies and Local Intros are not affected either way.

**Checked against:** Jellyfin Server 12.4.0 (plugin loaded and tested on it: episodes got 1 to 3 clips, movies none, `nofiller` tag skipped, clips survive a restart), jellyfin-web, jellyfin-roku and jellyfin-androidtv source as of 2026-11-27.
