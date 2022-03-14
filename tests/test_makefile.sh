#!/bin/bash

set -e

TMPDIR="$(realpath "$(mktemp -d)")"
SRCDIR="$(dirname "$0")/.."

if [ -z "$TMPDIR" ]; then
    echo "For some reason TMPDIR failed to be set. This should not happen..." 1>&2
    exit 2
fi

function cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

function make_check_clean_target() {
    make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example $1
    if find "$TMPDIR" | egrep -v "^$TMPDIR\$|\.log$" | egrep '^.+$'; then
        echo "$1 target did not clean up!"
        return 1
    fi
}

cd "$SRCDIR"

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-standalone-boot-files

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/EFI/BOOT/grub.cfg
boot/efi/grub-mender-grubenv/mender_grubenv1/env
boot/efi/grub-mender-grubenv/mender_grubenv1/lock
boot/efi/grub-mender-grubenv/mender_grubenv1/lock.sha256sum
boot/efi/grub-mender-grubenv/mender_grubenv2/env
boot/efi/grub-mender-grubenv/mender_grubenv2/lock
boot/efi/grub-mender-grubenv/mender_grubenv2/lock.sha256sum
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-standalone-boot-files

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-standalone

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/EFI/BOOT/grub.cfg
boot/efi/grub-mender-grubenv/mender_grubenv1/env
boot/efi/grub-mender-grubenv/mender_grubenv1/lock
boot/efi/grub-mender-grubenv/mender_grubenv1/lock.sha256sum
boot/efi/grub-mender-grubenv/mender_grubenv2/env
boot/efi/grub-mender-grubenv/mender_grubenv2/lock
boot/efi/grub-mender-grubenv/mender_grubenv2/lock.sha256sum
usr/bin/grub-mender-grubenv-print
usr/bin/grub-mender-grubenv-set
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-standalone

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-grub.d-boot-files

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/grub-mender-grubenv/mender_grubenv1/env
boot/efi/grub-mender-grubenv/mender_grubenv1/lock
boot/efi/grub-mender-grubenv/mender_grubenv1/lock.sha256sum
boot/efi/grub-mender-grubenv/mender_grubenv2/env
boot/efi/grub-mender-grubenv/mender_grubenv2/lock
boot/efi/grub-mender-grubenv/mender_grubenv2/lock.sha256sum
etc/default/grub.d/00_mender_grubenv_defines.cfg
etc/default/grub.d/mender-export-grub_probe.cfg
etc/default/grub.d/mender-os-probe-skip.cfg
etc/default/grub.d/mender-root-device.cfg
etc/default/grub.d/xx_mender_font_and_theme_handling.cfg
etc/grub.d/00_00_mender_grubenv_defines
etc/grub.d/00_04_mender_setup_env_grub_functions
etc/grub.d/00_05_mender_setup_env_grub
etc/grub.d/00_80_mender_choose_partitions_grub
etc/grub.d/00_90_mender_boot_selected_rootfs
etc/grub.d/07_mender_choose_partitions_grub
etc/grub.d/08_mender_rollback
etc/grub.d/50_mender_default
etc/grub.d/90_mender_generate_dual_rootfs_grub
etc/grub.d/README-mender.md
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-grub.d-boot-files

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-standalone-boot-script

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/EFI/BOOT/grub.cfg
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-standalone-boot-script

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-grub.d-boot-scripts

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
etc/default/grub.d/00_mender_grubenv_defines.cfg
etc/default/grub.d/mender-export-grub_probe.cfg
etc/default/grub.d/mender-os-probe-skip.cfg
etc/default/grub.d/mender-root-device.cfg
etc/default/grub.d/xx_mender_font_and_theme_handling.cfg
etc/grub.d/00_00_mender_grubenv_defines
etc/grub.d/00_04_mender_setup_env_grub_functions
etc/grub.d/00_05_mender_setup_env_grub
etc/grub.d/00_80_mender_choose_partitions_grub
etc/grub.d/00_90_mender_boot_selected_rootfs
etc/grub.d/07_mender_choose_partitions_grub
etc/grub.d/08_mender_rollback
etc/grub.d/50_mender_default
etc/grub.d/90_mender_generate_dual_rootfs_grub
etc/grub.d/README-mender.md
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-grub.d-boot-scripts

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-boot-env

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/grub-mender-grubenv/mender_grubenv1/env
boot/efi/grub-mender-grubenv/mender_grubenv1/lock
boot/efi/grub-mender-grubenv/mender_grubenv1/lock.sha256sum
boot/efi/grub-mender-grubenv/mender_grubenv2/env
boot/efi/grub-mender-grubenv/mender_grubenv2/lock
boot/efi/grub-mender-grubenv/mender_grubenv2/lock.sha256sum
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-boot-env

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-legacy-boot-env

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/EFI/BOOT/mender_grubenv1/env
boot/efi/EFI/BOOT/mender_grubenv1/lock
boot/efi/EFI/BOOT/mender_grubenv1/lock.sha256sum
boot/efi/EFI/BOOT/mender_grubenv2/env
boot/efi/EFI/BOOT/mender_grubenv2/lock
boot/efi/EFI/BOOT/mender_grubenv2/lock.sha256sum
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-legacy-boot-env

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-tools

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
usr/bin/grub-mender-grubenv-print
usr/bin/grub-mender-grubenv-set
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-tools

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install-legacy-tools

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
usr/bin/fw_printenv
usr/bin/fw_setenv
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall-legacy-tools

rm -rf "$TMPDIR"/*

################################################################################

make -s DESTDIR="$TMPDIR/install" DEFINES_FILE="$SRCDIR"/mender_grubenv_defines.example install

find "$TMPDIR/install" -type f -o -type l | sed -e "s,^$TMPDIR/install/,," | sort > "$TMPDIR/actual.log"
cat > "$TMPDIR/expected.log" <<EOF
boot/efi/grub-mender-grubenv/mender_grubenv1/env
boot/efi/grub-mender-grubenv/mender_grubenv1/lock
boot/efi/grub-mender-grubenv/mender_grubenv1/lock.sha256sum
boot/efi/grub-mender-grubenv/mender_grubenv2/env
boot/efi/grub-mender-grubenv/mender_grubenv2/lock
boot/efi/grub-mender-grubenv/mender_grubenv2/lock.sha256sum
etc/default/grub.d/00_mender_grubenv_defines.cfg
etc/default/grub.d/mender-export-grub_probe.cfg
etc/default/grub.d/mender-os-probe-skip.cfg
etc/default/grub.d/mender-root-device.cfg
etc/default/grub.d/xx_mender_font_and_theme_handling.cfg
etc/grub.d/00_00_mender_grubenv_defines
etc/grub.d/00_04_mender_setup_env_grub_functions
etc/grub.d/00_05_mender_setup_env_grub
etc/grub.d/00_80_mender_choose_partitions_grub
etc/grub.d/00_90_mender_boot_selected_rootfs
etc/grub.d/07_mender_choose_partitions_grub
etc/grub.d/08_mender_rollback
etc/grub.d/50_mender_default
etc/grub.d/90_mender_generate_dual_rootfs_grub
etc/grub.d/README-mender.md
usr/bin/grub-mender-grubenv-print
usr/bin/grub-mender-grubenv-set
EOF
diff -u "$TMPDIR/expected.log" "$TMPDIR/actual.log"

make_check_clean_target uninstall

rm -rf "$TMPDIR"/*
