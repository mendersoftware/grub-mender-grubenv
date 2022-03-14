`grub.d` integration
====================

These files will be installed in the `/etc/grub.d` folder, to be used by `update-grub` and
`grub-mkconfig` to update the boot scripts automatically on upgrades. `grub-mender-grubenv` and
`grub.d` differ in how they use the numbered scripts to generate boot code. Mender simply
concatenates the scripts as they are, in order. GRUB executes them instead, and uses the output as
boot code.

In order to accomodate both styles, the files in this directory will be installed in a special way:
Files that end in `.cfg` will be installed with a special header and footer so that executing it
outputs its own content. Other files are installed as they are, so they need to be scripts and
follow the `grub.d` execution style. Put shortly: `.cfg` files are run during boot, other files are
run during installation. This enables both `grub.d` specific scripts, as well as code sharing with
the non-`grub.d` boot script files.

Note that the `cfg` naming does not apply to the files inside `default`, where all files have `cfg`
extensions. These scripts will be installed in `/etc/default/grub.d`, and are sourced as scripts,
but are expected to only contain configuration settings.

Specific files
--------------

Note in particular that `80_mender_choose_partitions_grub.cfg` from the root folder is included
twice. This is because we need to run it once early on, in the
`/boot/efi/grub-mender-grubenv/grub.cfg` script, and later we need to run it again in
`/boot/grub-mender-grubenv.cfg` because `00_header` from GRUB overwrites the `root` variable in the
meantime.
