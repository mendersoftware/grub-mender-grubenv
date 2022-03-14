`grub.d` integration
====================

When Mender is used in a dual root filesystem setup, it needs to insert some special GRUB boot code
in order to facilitate installation and rollback by switching between two rootfs partitions. It does
this by using the boot scripts in this directory to do some special steps:

1. It generates two copies of `grub.cfg` instead of one. The first copy is placed on the EFI
   partition, and the job of this script is to determine the correct rootfs partition. The second
   copy is placed on the root filesystem partition, and this carries out, for the most part, the
   usual steps that the GRUB boot scripts do. Note that due to how scripts are generated, both
   copies contain most of the boot code, even that which will not be used. If-conditions are used to
   make sure the right sections are entered.

2. The first copy of `grub.cfg` is normally installed on
   `/boot/efi/grub-mender-grubenv/grub.cfg`. Due to how GRUB installs new scripts, the `/boot/grub`
   folder needs to be a symlink to `/boot/efi/grub-mender-grubenv`, so that it will be put on the
   EFI partition, not on the rootfs partition, where GRUB normally puts it. This is important so
   that rollback will work even if deploying a Mender Artifact with broken boot scripts.

3. Inside this first copy of `grub.cfg`, the special mender boot variables are loaded from the boot
   environment and then the special variable `mender_kernel_root` is set, which contains the root
   filesystem partition index.

4. Inside the second copy, which is normally installed in `/boot/grub-mender-grubenv.cfg` on the
   rootfs partition, most of the normal boot code from Debian is carried out, but the currently
   active partition is replaced with `${mender_kernel_root}` by setting the `root=` GRUB variable
   and providing the `root=` kernel argument.

5. If the second configuration file returns without having booted correctly, this returns control to
   the original script, which will trigger rollback steps.


Naming
------

The scripts are using special indexing to make sure that several of them are executed before the
`00_header` file installed by GRUB, which normally executes first. All of the mender files that
start with two indexes, like `00_10`, are meant to be executed from the first copy of `grub.cfg`,
the one on the EFI partition. The other scripts with only one index are meant to be executed from
the second copy on the root filesystem. This is to ensure that the Mender scripts only take the
necessary steps before delegating the rest of the steps to the script on the rootfs. This ensures
that most of the boot script logic can be upgraded by deploying a new Mender Artifact, since the
majority of the steps are executed from the currently active root filesystem.
