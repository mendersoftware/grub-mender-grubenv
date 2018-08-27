srcdir ?= .
export srcdir
DESTDIR ?= /
export DESTDIR
prefix ?= /usr
export prefix

BOOT_DIR ?= /boot/efi
BOOT_ENV_DIR ?= /EFI/BOOT
ENV_DIR ?= $(BOOT_DIR)$(BOOT_ENV_DIR)

TMP_DIR ?= tmp-workdir

SCRIPT_SOURCES := $(wildcard $(srcdir)/[0-9][0-9]_*_grub.cfg)

SOURCES = \
	$(SCRIPT_SOURCES) \
	$(srcdir)/blank_grubenv

all: compile

compile: mender_grub.cfg

mender_grub.cfg: $(SOURCES) $(srcdir)/Makefile
	@if [ ! -e mender_grubenv_defines ]; then \
		echo "You need to create mender_grubenv_defines."; \
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
	cp -f mender_grubenv_defines $(TMP_DIR)/00_mender_grubenv_defines_grub.cfg
	cd $(TMP_DIR) && for script in [0-9][0-9]_*_grub.cfg; do \
		echo "# Start of ---------- `basename $$script` ----------"; \
		cat $$script; \
		echo "# End of ---------- `basename $$script` ----------"; \
	done > mender_grub.cfg
	mv $(TMP_DIR)/mender_grub.cfg .
	rm -rf $(TMP_DIR)

	echo "ENV_DIR = $(ENV_DIR)" > mender_grubenv.config

# Environment files.
	$(srcdir)/make-env-and-lock-files


install: install-boot-files install-tools

install-boot-files: compile
	install -d -m 755 $(DESTDIR)$(ENV_DIR)
	install -m 644 mender_grub.cfg $(DESTDIR)$(ENV_DIR)/grub.cfg

	install -m 755 -d $(DESTDIR)$(ENV_DIR)/mender_grubenv1
	install -m 644 mender_grubenv/env $(DESTDIR)$(ENV_DIR)/mender_grubenv1/env
	install -m 644 mender_grubenv/lock $(DESTDIR)$(ENV_DIR)/mender_grubenv1/lock
	install -m 644 mender_grubenv/lock.sha256sum $(DESTDIR)$(ENV_DIR)/mender_grubenv1/lock.sha256sum
	install -m 755 -d $(DESTDIR)$(ENV_DIR)/mender_grubenv2
	install -m 644 mender_grubenv/env $(DESTDIR)$(ENV_DIR)/mender_grubenv2/env
	install -m 644 mender_grubenv/lock $(DESTDIR)$(ENV_DIR)/mender_grubenv2/lock
	install -m 644 mender_grubenv/lock.sha256sum $(DESTDIR)$(ENV_DIR)/mender_grubenv2/lock.sha256sum

install-tools:
	install -d -m 755 $(DESTDIR)$(prefix)/bin
	install -m 755 $(srcdir)/fw_printenv $(DESTDIR)$(prefix)/bin
	ln -sf fw_printenv $(DESTDIR)$(prefix)/bin/fw_setenv

	install -d -m 755 $(DESTDIR)/etc
	install -m 755 mender_grubenv.config $(DESTDIR)/etc


clean:
	rm -f mender_grubenv.config
	rm -f mender_grub.cfg
	rm -f mender_grubenv/env
	rm -f mender_grubenv/lock
	rm -f mender_grubenv/lock.sha256sum
	rm -fd mender_grubenv

distclean: clean
	rm -f mender_grubenv_defines
