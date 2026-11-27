# ErsatzTV live TV field guide (CR-ETV)

- Source: `ersatztv-live-tv-guide.html` (single self-contained file, Step 1 first, Help at the end).
- PDF copy for reading: project files `ersatztv/cobra-ersatztv-live-tv-guide-v1.pdf`.
- Rebuild: `NODE_PATH=$(npm root -g) node docs/ersatztv/build.mjs out.pdf` (needs Playwright + Chromium).
- Style: flat colours, borders and tables only (no glow, grain, gradients or faces). Check render time stays ~1 s.
- New versions get a new file name (v2, v3...). Never overwrite an older PDF.
- Checked against ErsatzTV 26.14.0 and Jellyfin 12.3 on 2026-11-27. Labels flagged "check on screen" in the footer were not in the official docs; fix them once the owner confirms what the screen shows.
