# HandBrake movie guide

MakeMKV rip -> HandBrake -> web-optimized MP4 -> Jellyfin direct play.
Turns 5-10 GB MKVs into 2-4 GB MP4s.

| File | What it is |
|---|---|
| `handbrake-movie-guide.html` | Source of the PDF (every HandBrake tab, MakeMKV, subtitles, bitrate tables) |
| `cobra-handbrake-presets.json` | Import into HandBrake on the-box: Presets > Import. Adds a "Cobra" folder |

Presets: Cobra 1080p HEVC (~2 GB, default), Cobra 4K HDR (~4 GB, 2-pass 3800 kbps),
Cobra 1080p NVENC Fast (RTX 3070), Cobra 1080p H.264 Compatibility.

The x265 and x264 presets were test-encoded with HandBrakeCLI 1.7.2 (output: HEVC Main10 /
H.264 High, AAC stereo + AC3 5.1 passthru, mov_text subs, moov atom first). The NVENC preset
is schema-checked only (no NVIDIA GPU on the test machine).

PDF copy: project files `handbrake/cobra-handbrake-guide-v2.pdf` (v1 kept as `cobra-handbrake-guide.pdf`). v2 adds section 17, other apps.

Rebuild the PDF (Chromium print, flat colours only, no glow/grain):

```
node -e "const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();const p=await b.newPage();await p.goto('file://'+process.cwd()+'/handbrake-movie-guide.html');await p.pdf({path:'cobra-handbrake-guide.pdf',printBackground:true,preferCSSPageSize:true});await b.close()})()"
```
