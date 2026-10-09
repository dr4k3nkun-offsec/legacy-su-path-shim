```markdown
# Universal Legacy SU Path Shim & Bridge

A universal systemless and physical partition bridge designed for modern Android devices running modern root managers (Magisk, KernelSU, APatch).

---

## Errors Resolved

This project completely fixes two critical legacy root issues on modern Android environments:

* **ANDRAX Core Execution Failure (Solved):**
  ```text
  exec("/system/bin/su"): No such file or directory

```

Resolves the hardcoded legacy path requirement in ANDRAX's installer and runtime execution engine without modifying system partitions.

* **Magisk Manager Warning (Solved):**
Eliminates the red *"Abnormal state: A 'su' binary not from Magisk has been detected"* banner by creating required sibling signature links.
* **IPC Socket Timeouts (Solved):**
Prevents `Broken pipe (os error 32) / Access denied` socket drops during app-level root elevation.

---

## Architectural Comparison & Context

Modern Android platforms enforce strict security boundaries and dynamic partition schemes. Depending on your system structure and recovery capabilities, choose the deployment method that fits your environment:

```text
Environment A (Custom Recovery / Writable Storage):
[Custom Recovery] ──(adb root)──> [mount -o remount,rw /mnt/system] ──(writable)──> Direct Injection into /system/bin/su

Environment B (Stock Recovery / Immutable EROFS):
[Stock Recovery]  ──(Locked)────> [No adb root / No recovery mount UI]
[Live System]     ──(EROFS)─────> Kernel-level Read-Only (mount fails: '/mnt/system' not in /proc/mounts)
                                         │
                                         ▼
                   [Solution: Systemless Module via post-fs-data boot overlay]

```

* **Method 1 (Universal Module):** Recommended for all setups, especially environments with locked recoveries, live read-only filesystems (EROFS), and dynamic partitions. Requires no physical partition changes.
* **Method 2 (Recovery Injection):** Designed for custom recovery environments with direct partition remount support during clean installations or ROM migrations.

---

## Method 1: Systemless Magisk Module (Zero Partition Modification)

This method dynamically identifies the randomized runtime root directory (`MAGISKTMP`) on every boot, creates a live symlink for `/system/bin/su` to satisfy ANDRAX, and generates a `/system/bin/magisk` sibling link.

> **Why the sibling link is necessary:** Magisk’s internal abnormal-state verification scans directories in `$PATH` for a stray `su` only if no file named `magisk` exists in that directory. Generating both symlinks satisfies manager health probes, eliminates broken pipe socket drops, and prevents the *"Abnormal state"* warning.

### Installation

1. Download `legacy_su-v3.0.zip` from the [Releases](https://www.google.com/search?q=../../releases) tab.
2. Open your Root Manager (Magisk).
3. Navigate to **Modules** $\rightarrow$ **Install from storage**.
4. Select `legacy_su-v3.0.zip` and reboot the device.

---

## Method 2: Direct Recovery Partition Injection

For setups with unlocked custom recovery engines where persistent physical partition modifications are preferred over module frameworks.

### Phase 1: Recovery Preparation

1. Power off the phone completely.
2. Boot into Custom Recovery (typically `Volume Up + Power` or `Volume Down + Power`).
3. Navigate to **Advanced** $\rightarrow$ select **Enable ADB**.
4. Go to **Mount** options $\rightarrow$ check or mount the **System** partition.
5. Connect your device to your PC via USB.

### Phase 2: Terminal Execution

Run these commands from your computer terminal:

```bash
# 1. Start the ADB server with administrative root privileges
adb root

# 2. Enter internal recovery shell
adb shell

# 3. Remount system partition to Read-Write mode
mount -o remount,rw /mnt/system

# 4. Create the target binary directory
mkdir -p /mnt/system/system/bin

# 5. Remove any broken file remnants
rm -f /mnt/system/system/bin/su

# 6. Initialize wrapper script
echo '#!/system/bin/sh' > /mnt/system/system/bin/su

# 7. Append execution redirect pointing to Magisk's socket node
echo 'exec /dev/com.topjohnwu.magisk/su "$@"' >> /mnt/system/system/bin/su

# 8. Grant global execution privileges
chmod 755 /mnt/system/system/bin/su

# 9. Exit recovery shell and restart
exit
adb reboot

```

---

## Verification

Run the following checks from ADB shell after boot:

```bash
adb shell
ls -la /system/bin/su
/system/bin/su -v
/system/bin/su -V

```

* **Expected Results:**
* Displays the symlink pointing cleanly to the active root binary.
* Outputs the native version signature (e.g., `31.0:MAGISKSU` and `31000`).
* ANDRAX and NetHunter Terminal execute immediately without `No such file or directory` or socket closure errors.



> **Note on SELinux:** If a security suite fails to unpack internal payload tarballs during initial initialization, temporarily switch SELinux to Permissive:
> ```bash
> adb shell su -c "setenforce 0"
> 
> ```
> 
> 

---

## Tested & Confirmed Environments

* **OxygenOS A16**
* **LineageOS v23.2**
* **Magisk v31.0+ (31000)**

---

## Author

* **DRAKEN**

```

```