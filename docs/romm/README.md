# RomM arcade field guide

`romm-field-guide.html` is the source of the owner's RomM how-to (reset to the setup wizard, MariaDB, metadata keys, scanning, in-browser play, BIOS folder, players). PDF copy: project files `romm/cobra-romm-field-guide.pdf`.

Checked against RomM 5.4.1 and its 5.4.0 docs (2026-11-27).

Rebuild the PDF (Chromium print, flat colours only):

```
node -e "const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();const p=await b.newPage();await p.goto('file://'+process.cwd()+'/romm-field-guide.html');await p.pdf({path:'cobra-romm-field-guide.pdf',printBackground:true,preferCSSPageSize:true});await b.close()})()"
```
