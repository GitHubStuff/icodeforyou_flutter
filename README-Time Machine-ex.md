# Time Machine Backup Setup — UGREEN NAS

How to set up a UGREEN NAS shared folder as a Time Machine destination for a
Mac. Each Mac gets its own dedicated user and its own dedicated shared folder —
never point two Macs at the same Time Machine share.

## Naming convention

- Shared folder: `tm_<machine>` (e.g. `tm_macair`, `tm_m4studio`)
- User: `tm_<machine>` (e.g. `tm_air`, `tm_m4studio`)

---

## Part 1 — NAS setup (UGOS)

### 1. Create a dedicated user

Control Panel → **Users & Groups → Users → Create**

- Username: `tm_<machine>`
- Strong password (store in password manager)

A dedicated user keeps Time Machine credentials isolated from your main
account.

### 2. Create the shared folder

Control Panel → **Shared Folder → Create**

| Field                                                           | Value                                            |
| --------------------------------------------------------------- | ------------------------------------------------ |
| Name                                                            | `tm_<machine>`                                   |
| Storage location                                                | Volume 1 (only option on single-volume NAS)      |
| Volume usage limit                                               | ✅ Enabled — set to **2× the Mac's SSD** (min)  |
| Hide in "Network"                                                | ❌ Off — Mac needs to discover it via Bonjour   |
| Hide subfolders/files from users who do not have permissions     | ✅ On — cheap security win                      |
| Enable Recycle Bin                                               | ❌ Off — Time Machine manages its own versioning; Recycle Bin would silently double storage usage |

The quota is critical. Without it, Time Machine will eat the entire volume.
Rule of thumb: 2–3× the Mac's internal SSD size.

### 3. Set permissions

Permissions screen for the new shared folder:

- `tm_<machine>` user: **Read & Write**
- `admin`: **Read & Write**
- Everyone else (including `guest`, `everyone`, other users): **No access**

### 4. Enable SMB service

Control Panel → **File Services → SMB**

- Enable SMB service: ✅
- Workgroup: `WORKGROUP` (default — matches macOS)
- Max protocol: SMB3

### 5. Enable Bonjour and Time Machine advertising

Same File Services area:

- Enable Bonjour service: ✅
- Click **Set Time Machine** button → tick each `tm_<machine>` shared folder
  that should be a Time Machine target → save

The Bonjour + Time Machine advertisement is what makes the share show up in
Time Machine's disk picker on the Mac without typing anything.

### 6. (Optional but recommended) Reserve the NAS IP

In your router, set a DHCP reservation for the NAS so its IP doesn't change.
Time Machine remembers the destination, and a wandering IP will eventually
cause failed backups.

---

## Part 2 — Mac setup

### 1. Mount the share once to cache credentials

Finder → **Cmd-K** → enter:

```
smb://<nas-ip>/tm_<machine>
```

Authenticate as the `tm_<machine>` user. Tick **Remember this password in my
keychain**.

This plants the credentials so Time Machine doesn't prompt later. Share can be
unmounted afterwards.

### 2. Add as Time Machine destination

System Settings → **General → Time Machine → Add Backup Disk** (`+`)

- Select `tm_<machine>` from the list (appears via Bonjour)
- Choose **Encrypt Backup** — adds an extra password layer on top of share
  permissions
- Set the encryption password and store it in a password manager. Losing it
  means losing the backups.
- Confirm

### 3. First backup

The first backup is the slow one. For a mostly-full SSD over Wi-Fi, expect
many hours. Use Ethernet via a dongle if available. Subsequent backups are
incremental and quick.

---

## Multiple Macs

For each additional Mac, repeat the entire process with new names:

- New user: `tm_<machine>`
- New shared folder: `tm_<machine>` with its own quota
- Add to Time Machine target list via **Set Time Machine**

Never share a single folder between two Macs — Time Machine sparsebundles
do not coexist in the same folder.

---

## Troubleshooting

| Symptom                                            | Cause                                                                          |
| -------------------------------------------------- | ------------------------------------------------------------------------------ |
| Share doesn't appear in Time Machine disk picker   | Bonjour disabled, or folder not added via **Set Time Machine**                 |
| Sparsebundle corruption after months               | Quota too small, or network dropped mid-write — increase quota                 |
| Time Machine prompts for password repeatedly       | Credentials not cached — repeat Cmd-K mount step                               |
| Backups fail after router replacement / IP change  | NAS IP changed — set DHCP reservation                                          |
