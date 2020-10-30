#!/bin/bash

set -e

TMPDIR="$(realpath "$(mktemp -d)")"
SRCDIR="$(dirname "$0")/.."

function cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

cd "$SRCDIR"

################################################################################
# Normal install.
################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/EFI/BOOT/grub.cfg
boot/efi/EFI/BOOT/mender_grubenv1/env
boot/efi/EFI/BOOT/mender_grubenv1/lock
boot/efi/EFI/BOOT/mender_grubenv1/lock.sha256sum
boot/efi/EFI/BOOT/mender_grubenv2/env
boot/efi/EFI/BOOT/mender_grubenv2/lock
boot/efi/EFI/BOOT/mender_grubenv2/lock.sha256sum
etc/mender_grubenv.config
usr/bin/grub-mender-grubenv-print
usr/bin/grub-mender-grubenv-set
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

rm -rf "$TMPDIR"/*

################################################################################
# Install legacy tools.
################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-legacy-tools

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
etc/mender_grubenv.config
usr/bin/fw_printenv
usr/bin/fw_setenv
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

rm -rf "$TMPDIR"/*
