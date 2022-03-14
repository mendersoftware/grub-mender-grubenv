grub-mender-grubenv
===================

Contains the boot scripts and tools used by
[Mender](https://github.com/mendersoftware/mender) to integrate with the
[GRUB](https://www.gnu.org/software/grub/) bootloader.

Probably you don't want to use this by itself. Check out [our
documentation](https://docs.mender.io/)!


Configuring
-----------

Before installing you will have to provide some configuration. The simplest way
is to copy the `mender_grubenv_defines.example` to `mender_grubenv_defines` and
make the necessary adjustments to the values inside the file. See [our
documentation](https://docs.mender.io/) for more information on what the values
should be.

Installing
----------

After configuration is done, to install the tools and the boot scripts, run:

```
make
make install
```

Install location can be controlled by passing `DESTDIR=<DIR>` before the
`install` target. By default, the installation is integrated with the
`/etc/grub.d` scripts, which means you need to run `grub-install` and
`update-grub` after installation on the platform. This normally has to be done
while running the device, but you can use
[mender-convert](https://github.com/mendersoftware/mender-convert) as a way to
do this at build time.

For more detailed information about how the `/etc/grub.d` integration works, see
the README files in the `grub.d` folder.

### User space tools

The `grub-mender-grubenv-print` and `grub-mender-grubenv-set` commands are used
to modify the Mender environment from user space, and is used by [the Mender
client](https://github.com/mendersoftware/mender) during Rootfs updates.

If you want to install only the tools, or only the script and environment files,
run `make install-tools` or `make install-grub.d-boot-files`, respectively.

### Standalone boot scripts

It is also possible to install standalone boot scripts that do not integrate
with the `/etc/grub.d` scripts. The advantage is that you do not need to run
`grub-install` and `update-grub` on the platform afterwards, and the customized
nature may be better suited for specialized situations, or where `/etc/grub.d`
is not available. Currently this is the mode used when building with
[Yocto](https://www.yoctoproject.org/) and
[meta-mender](https://github.com/mendersoftware/meta-mender). Only use this mode
if you know what you are doing. The standard install target is recommended in
all other cases.

To install this variant, run this:

```
make
make install-standalone
```

You can also control the location of the installed environment files on the
final target with `ENV_DIR`. The default is `/boot/efi/EFI/BOOT` which assumes
that the [EFI
partition](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface)
is mounted on `/boot/efi`.

If you want to install only [the tools](#user-space-tools), or only the script
and environment files, run `make install-tools` or `make
install-standalone-boot-files`, respectively.


License
-------

Licensed under [Apache License version 2.0](LICENSE).
