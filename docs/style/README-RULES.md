# How we write READMEs and run lists

Company principle: **clear, easy-to-follow information.** Someone who is tired, has ADHD, or is in the middle of a task must be able to follow it without getting lost.

## The rules

1. **One file.** Everything needed is in it. Never write "see the other README": put the steps from any other guide right into it.
2. **Step 1 first.** The title, at most three short lines (how to tick boxes, where Help is, which tabs), then step 1. No version history, overview tables or philosophy before the steps.
3. **Numbered tick boxes,** for example `- [ ] **2.6** ...`, grouped into short Parts.
4. **One action per step:** one click path, or one field, or one command.
5. **Name where it happens.** Every step starts with the machine or tab: `windows`, `eels@cobra-gate`, `eels@cobra-stream`, Browser, Phone or Roku.
6. **One bare command per grey box.** Nothing else in the box, and no inline comments. Explanations go outside it.
7. **Fields are actions.** Write "**Protocol**: pick **TCP**" or "**Destination port**: type `8096`", never a bare value like "DNS to DNS". Cover both UI layouts if the screen differs between versions.
8. **One "You should see" line** after each step.
9. **No commands outside the numbered steps,** not in summaries and not in Help.
10. **Help goes at the end, by step number.** Reasons, troubleshooting, which screenshot to send, and undo steps all go there.
11. **Current names only.** Check the latest release notes and docs before writing a menu name or setting. For example, OPNsense 26.x says Firewall → NAT → **Destination NAT**, not "Port Forward". End with a "Checked against" line of versions.
12. **the-box first.** If a step can be done on the desktop, do it there, not on the phone.
13. **Never overwrite.** Every update gets a new version name, and the owner picks it.

## Examples

- Good: the v3.6 run list (`cobra-runlist-2026-11-21-v3.6.zip`, its README.md).
- Bad: [examples/bad-readme-v3.5.md](examples/bad-readme-v3.5.md), the v3.5.1 run list, with a list of what's wrong at the top.
