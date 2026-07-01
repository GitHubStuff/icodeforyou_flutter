# Touch — Update Modified Date

A macOS Quick Action (Service) that lets you right-click any file or folder in Finder and update its **Date Modified** to the current date and time.

Works on single files, single folders, and multi-selections. Native Finder integration — no third-party apps required.

---

## What You'll Build

A Finder Quick Action named **Touch — Update Modified Date** that appears in the right-click menu under **Quick Actions**. Selecting it runs the Unix `touch` command on every selected item, setting its modification timestamp to right now.

---

## Requirements

- macOS (any modern version — Big Sur or later confirmed)
- Automator (pre-installed at `/Applications/Automator.app`)
- About 2 minutes

---

## Step 1 — Open Automator

Launch Automator by one of:

- Opening **Applications → Automator**, or
- Pressing **⌘ Space** and typing `Automator`, then pressing **Return**.

---

## Step 2 — Create a New Quick Action

1. In Automator, choose **File → New** (or press **⌘ N**).
2. In the document-type picker, select **Quick Action**.
3. Click **Choose**.

A blank Quick Action workflow opens.

---

## Step 3 — Configure the Workflow Header

At the top of the workflow pane, set the following three fields:

| Field | Value |
|---|---|
| Workflow receives current | `files or folders` |
| in | `Finder` |
| Image *(optional)* | `clock` or `refresh` (helps you spot it in menus) |

Leave the **Color** field at its default unless you have a preference.

---

## Step 4 — Add the "Run Shell Script" Action

1. In the **left-hand actions panel**, type `Run Shell Script` into the search box.
2. Drag the **Run Shell Script** action into the empty workflow area on the right.

A configuration block appears for the action.

---

## Step 5 — Configure the Shell Script

Set these two options on the Run Shell Script block:

| Option | Value |
|---|---|
| Shell | `/bin/zsh` |
| Pass input | **`as arguments`** ← critical, **not** "to stdin" |

> ⚠️ **Important:** If "Pass input" is set to `to stdin`, the script will not receive the selected files correctly. Make sure it reads **as arguments**.

---

## Step 6 — Enter the Script

Delete the default script content and paste in:

```zsh
for f in "$@"; do
  /usr/bin/touch -- "$f"
done
```

### What this does

- `for f in "$@"` iterates over every selected file/folder passed in by Finder.
- `"$f"` (quoted) handles paths containing spaces or special characters.
- `--` tells `touch` to stop parsing flags, so filenames beginning with `-` are treated as paths.
- `/usr/bin/touch` updates both access and modification times to the current moment.

---

## Step 7 — Save the Quick Action

1. Choose **File → Save** (or **⌘ S**).
2. Name it: **`Touch — Update Modified Date`**
3. Click **Save**.

Automator saves it to `~/Library/Services/`. It is now available in Finder immediately — **no restart, no logout required**.

---

## Step 8 — Use It

1. Open **Finder**.
2. Select one or more files and/or folders.
3. **Right-click** (or **Ctrl-click**) the selection.
4. Choose **Quick Actions → Touch — Update Modified Date**.

The **Date Modified** column updates to the current date and time.

---

## Optional — Promote It Out of the Submenu

If you'd rather not dig through **Quick Actions →** every time:

1. Open **System Settings → Privacy & Security → Extensions → Finder**
   *(on older macOS: System Preferences → Extensions → Finder)*
2. Make sure **Touch — Update Modified Date** is checked.

Some macOS versions promote frequently used Quick Actions to the top level of the right-click menu automatically.

---

## Optional — Assign a Keyboard Shortcut

1. Open **System Settings → Keyboard → Keyboard Shortcuts → Services**.
2. Scroll to **Files and Folders**.
3. Find **Touch — Update Modified Date**.
4. Click **Add Shortcut** and press your preferred key combo (e.g. **⌃⌥⌘ T**).

Now selected items in Finder can be touched with a keystroke.

---

## How It Behaves on Folders

Running `touch` on a folder updates **only the folder's own modification time**. It does **not** recurse into the folder's contents. This matches what Finder shows in the **Date Modified** column for that folder.

If you ever want a recursive version (touch a folder *and* everything inside it), create a second Quick Action with this script instead:

```zsh
for f in "$@"; do
  /usr/bin/find "$f" -exec /usr/bin/touch -- {} +
done
```

Keep the two as separate Quick Actions so you don't accidentally rewrite timestamps across a whole tree.

---

## Managing / Removing the Quick Action

Quick Actions live at:

```
~/Library/Services/
```

Your file will be named:

```
Touch — Update Modified Date.workflow
```

- **To edit:** double-click the `.workflow` file — it reopens in Automator.
- **To remove:** drag the `.workflow` file to the Trash.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| Quick Action doesn't appear in the right-click menu | Saved with the wrong "receives" type | Reopen in Automator, confirm `files or folders` / `in Finder` |
| Action runs but timestamp doesn't change | "Pass input" set to `to stdin` | Change to `as arguments` and re-save |
| Works on files but not folders (or vice versa) | "Receives" set to only one type | Set it to `files or folders` |
| Filenames with spaces fail | `"$f"` was unquoted | Restore the double-quotes around `"$f"` in the loop |
| Nothing happens on multi-select | Script uses `$1` instead of looping `"$@"` | Use the `for f in "$@"` loop as shown |

---

## Summary

You now have a native Finder Quick Action that updates Date Modified on demand, works with single or multiple selections, handles spaces and special characters in paths, and can optionally be triggered by a keyboard shortcut. Total cost: one Automator workflow and four lines of shell script.
