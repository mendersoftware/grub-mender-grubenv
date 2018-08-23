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
`install` target. You can also control the location of the installed environment
files on the final target with `ENV_DIR`. The default is `/boot/efi/EFI/BOOT`
which assumes that the [EFI
partition](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface)
is mounted on `/boot/efi`.

If you want to install only the tools, or only the script and environment files,
run `make install-tools` or `make install-boot-files`, respectively.


License
-------

Licensed under [Apache License version 2.0](LICENSE).
