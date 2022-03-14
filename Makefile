srcdir ?= .
export srcdir
DESTDIR ?= /
export DESTDIR
prefix ?= /usr
export prefix

BOOT_DIR ?= /boot/efi
BOOT_ENV_DIR ?= /grub-mender-grubenv
EFI_DIR ?= /EFI/BOOT
ENV_DIR ?= $(BOOT_DIR)$(BOOT_ENV_DIR)
DEFINES_FILE ?= mender_grubenv_defines

LEGACY_BOOT_ENV_DIR ?= /EFI/BOOT
LEGACY_ENV_DIR ?= $(BOOT_DIR)$(LEGACY_BOOT_ENV_DIR)

TMP_DIR ?= tmp-workdir

SCRIPT_SOURCES := $(wildcard $(srcdir)/[0-9][0-9]_*_grub.cfg)

SOURCES = \
	$(SCRIPT_SOURCES) \
	$(srcdir)/blank_grubenv

all: compile

compile: mender_grub.cfg

mender_grub.cfg: $(SOURCES) $(srcdir)/Makefile
	@if [ ! -e $(DEFINES_FILE) ]; then \
		echo "You need to create $(DEFINES_FILE)."; \
		echo "Take a look at mender_grubenv_defines.example."; \
		echo; \
		exit 1; \
	fi

# Inspired by the way grub-mkconfig and /etc/grub.d works. Note that unlike the
# original, since we are not running on the target, these are dumped as they are
# into a common script, not executed as grub-mkconfig does.
	rm -rf $(TMP_DIR)
	mkdir -p $(TMP_DIR)
	cp -f $(SCRIPT_SOURCES) $(TMP_DIR)
	cp -f $(DEFINES_FILE) $(TMP_DIR)/00_mender_grubenv_defines_grub.cfg
	cd $(TMP_DIR) && for script in [0-9][0-9]_*_grub.cfg; do \
		echo "# Start of ---------- `basename $$script` ----------"; \
		cat $$script; \
		echo "# End of ---------- `basename $$script` ----------"; \
	done > mender_grub.cfg
	mv $(TMP_DIR)/mender_grub.cfg .
	rm -rf $(TMP_DIR)

mender_grubenv/env:
	$(srcdir)/make-env-and-lock-files


check:
	env MAKEFLAGS=-j1 ./tests/test_makefile.sh

install: install-grub.d-boot-files install-tools

install-standalone: install-standalone-boot-files install-tools

install-standalone-boot-files: install-standalone-boot-script install-boot-env

install-grub.d-boot-files: install-grub.d-boot-scripts install-boot-env

install-standalone-boot-script: mender_grub.cfg
	install -d -m 755 $(DESTDIR)$(BOOT_DIR)/$(EFI_DIR)
	install -m 644 mender_grub.cfg $(DESTDIR)$(BOOT_DIR)/$(EFI_DIR)/grub.cfg

# mender_grub.cfg is not really needed, but then we ensure the defines are
# present.
install-grub.d-boot-scripts: mender_grub.cfg
	$(MAKE) -C grub.d install

install-boot-env: mender_grubenv/env
	install -m 755 -d $(DESTDIR)$(ENV_DIR)/mender_grubenv1
	install -m 644 mender_grubenv/env $(DESTDIR)$(ENV_DIR)/mender_grubenv1/env
	install -m 644 mender_grubenv/lock $(DESTDIR)$(ENV_DIR)/mender_grubenv1/lock
	install -m 644 mender_grubenv/lock.sha256sum $(DESTDIR)$(ENV_DIR)/mender_grubenv1/lock.sha256sum
	install -m 755 -d $(DESTDIR)$(ENV_DIR)/mender_grubenv2
	install -m 644 mender_grubenv/env $(DESTDIR)$(ENV_DIR)/mender_grubenv2/env
	install -m 644 mender_grubenv/lock $(DESTDIR)$(ENV_DIR)/mender_grubenv2/lock
	install -m 644 mender_grubenv/lock.sha256sum $(DESTDIR)$(ENV_DIR)/mender_grubenv2/lock.sha256sum

install-legacy-boot-env: mender_grubenv/env
	install -m 755 -d $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1
	install -m 644 mender_grubenv/env $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1/env
	install -m 644 mender_grubenv/lock $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1/lock
	install -m 644 mender_grubenv/lock.sha256sum $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1/lock.sha256sum
	install -m 755 -d $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2
	install -m 644 mender_grubenv/env $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2/env
	install -m 644 mender_grubenv/lock $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2/lock
	install -m 644 mender_grubenv/lock.sha256sum $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2/lock.sha256sum

install-tools:
	install -d -m 755 $(DESTDIR)$(prefix)/bin
	install -m 755 $(srcdir)/grub-mender-grubenv-print $(DESTDIR)$(prefix)/bin
	ln -sf grub-mender-grubenv-print $(DESTDIR)$(prefix)/bin/grub-mender-grubenv-set

install-legacy-tools:
	install -d -m 755 $(DESTDIR)$(prefix)/bin
	install -m 755 $(srcdir)/grub-mender-grubenv-print $(DESTDIR)$(prefix)/bin/fw_printenv
	ln -sf fw_printenv $(DESTDIR)$(prefix)/bin/fw_setenv

install-offline-files:
	$(MAKE) -C grub.d/default install-offline-cfg
	install -m 755 grub-scripts/mender_offline_grub-probe_helper $(DESTDIR)$(prefix)/sbin

uninstall: uninstall-grub.d-boot-files uninstall-tools

uninstall-standalone: uninstall-standalone-boot-files uninstall-tools

uninstall-standalone-boot-files: uninstall-standalone-boot-script uninstall-boot-env

uninstall-grub.d-boot-files: uninstall-grub.d-boot-scripts uninstall-boot-env

uninstall-standalone-boot-script:
	rm -f $(DESTDIR)$(BOOT_DIR)/$(EFI_DIR)/grub.cfg
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(BOOT_DIR)/$(EFI_DIR)

uninstall-grub.d-boot-scripts:
	$(MAKE) -C grub.d uninstall

uninstall-boot-env:
	rm -f $(DESTDIR)$(ENV_DIR)/mender_grubenv1/env
	rm -f $(DESTDIR)$(ENV_DIR)/mender_grubenv1/lock
	rm -f $(DESTDIR)$(ENV_DIR)/mender_grubenv1/lock.sha256sum
	rm -f $(DESTDIR)$(ENV_DIR)/mender_grubenv2/env
	rm -f $(DESTDIR)$(ENV_DIR)/mender_grubenv2/lock
	rm -f $(DESTDIR)$(ENV_DIR)/mender_grubenv2/lock.sha256sum
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(ENV_DIR)/mender_grubenv1
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(ENV_DIR)/mender_grubenv2

uninstall-legacy-boot-env:
	rm -f $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1/env
	rm -f $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1/lock
	rm -f $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1/lock.sha256sum
	rm -f $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2/env
	rm -f $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2/lock
	rm -f $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2/lock.sha256sum
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv1
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(LEGACY_ENV_DIR)/mender_grubenv2

uninstall-tools:
	rm -f $(DESTDIR)$(prefix)/bin/grub-mender-grubenv-print
	rm -f $(DESTDIR)$(prefix)/bin/grub-mender-grubenv-set
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(prefix)/bin

uninstall-legacy-tools:
	rm -f $(DESTDIR)$(prefix)/bin/fw_printenv
	rm -f $(DESTDIR)$(prefix)/bin/fw_setenv
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(prefix)/bin

uninstall-offline-files:
	$(MAKE) -C grub.d/default uninstall-offline-cfg
	rm -f $(DESTDIR)$(prefix)/sbin/mender_offline_grub-probe_helper

clean:
	rm -f mender_grub.cfg
	rm -f mender_grubenv/env
	rm -f mender_grubenv/lock
	rm -f mender_grubenv/lock.sha256sum
	rm -fd mender_grubenv

distclean: clean
	rm -f $(DEFINES_FILE)

.PHONY: all
.PHONY: compile
.PHONY: check
.PHONY: install
.PHONY: install-standalone
.PHONY: install-standalone-boot-files
.PHONY: install-grub.d-boot-files
.PHONY: install-standalone-boot-script
.PHONY: install-grub.d-boot-scripts
.PHONY: install-boot-env
.PHONY: install-legacy-boot-env
.PHONY: install-tools
.PHONY: install-legacy-tools
.PHONY: install-offline-files
.PHONY: uninstall
.PHONY: uninstall-standalone
.PHONY: uninstall-standalone-boot-files
.PHONY: uninstall-grub.d-boot-files
.PHONY: uninstall-standalone-boot-script
.PHONY: uninstall-grub.d-boot-scripts
.PHONY: uninstall-boot-env
.PHONY: uninstall-legacy-boot-env
.PHONY: uninstall-tools
.PHONY: uninstall-legacy-tools
.PHONY: uninstall-offline-files
.PHONY: clean
.PHONY: distclean
