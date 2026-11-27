# Cobra Series Filler (Jellyfin 12 plugin)

Plays 1 to 3 random clips from a filler folder before TV episodes. Movies are left to Local Intros.
Install steps for the Commander: [docs/jellyfin/series-filler-runbook.md](../../docs/jellyfin/series-filler-runbook.md).

## Build (developers)

Needs the .NET 10 SDK.

    dotnet test tests
    dotnet build Jellyfin.Plugin.CobraSeriesFiller -c Release

The plugin is `Jellyfin.Plugin.CobraSeriesFiller/bin/Release/net10.0/Jellyfin.Plugin.CobraSeriesFiller.dll`.
The release zip holds that DLL, `install/install-series-filler.sh` and the runbook as `README.md`,
inside a `series-filler` folder.

## How it works

- `SeriesFillerIntroProvider` is an `IIntroProvider`. Jellyfin asks every provider for intros when an
  app starts an item from the beginning with Cinema mode on; this one answers only for `Episode`s.
- Clips are registered once as plain `Video` items (id derived from the path, provider id
  `CobraSeriesFiller`), the same way Local Intros does it, so the filler folder doesn't need to be a
  Jellyfin library.
- `FillerPicker` has the picking logic (count, no duplicates, avoid recent picks) and is unit tested.
- Tag a series, season or episode `nofiller` (setting) to skip it.

Limits come from the clients, not the plugin: no clips between autoplayed episodes in any app, one
clip on Roku, none on Android TV. Details in the runbook's Help.
