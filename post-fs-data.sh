#!/system/bin/sh
MODDIR=${0%/*}

# Resolve the live magisk binary. MAGISKTMP rotates every boot, so this
# has to run fresh at each post-fs-data rather than being baked in once.
MAGISK="$(magisk --path 2>/dev/null)/magisk"
[ -x "$MAGISK" ] || MAGISK=/debug_ramdisk/magisk
[ -x "$MAGISK" ] || MAGISK=/sbin/magisk

mkdir -p "$MODDIR/system/bin"
rm -f "$MODDIR/system/bin/su" "$MODDIR/system/bin/magisk"
ln -s "$MAGISK" "$MODDIR/system/bin/su"
ln -s "$MAGISK" "$MODDIR/system/bin/magisk"

# Magisk's own abnormal-state check (MainActivity.kt, showUnsupportedMessage):
# for each PATH dir, it's exempted ONLY if a file literally named "magisk"
# also exists there -- only non-exempt dirs get scanned for a stray "su".
# A su-only symlink in /system/bin never qualified for that exemption.
