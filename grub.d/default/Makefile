srcdir ?= .
export srcdir
DESTDIR ?= /
export DESTDIR
sysconfdir ?= /etc
export sysconfdir

build:

install:
	install -m 755 -d $(DESTDIR)$(sysconfdir)/default/grub.d
	set -e; for file in $(srcdir)/*.cfg; do \
		echo "Installing $$file"; \
		install -m 644 $$file $(DESTDIR)$(sysconfdir)/default/grub.d; \
	done

install-offline-cfg:
	install -m 755 -d $(DESTDIR)$(sysconfdir)/default/grub.d
	install -m 644 extra/mender-offline-grub-probe-helper.cfg $(DESTDIR)/$(sysconfdir)/default/grub.d

uninstall:
	set -e; for file in $(srcdir)/*.cfg; do \
		rm -f $(DESTDIR)$(sysconfdir)/default/grub.d/$$(basename $$file); \
	done
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(sysconfdir)/default/grub.d

uninstall-offline-cfg:
	rm -f $(DESTDIR)/$(sysconfdir)/default/grub.d/mender-offline-grub-probe-helper.cfg
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(sysconfdir)/default/grub.d

.PHONY: build
.PHONY: install
.PHONY: install-offline-cfg
.PHONY: uninstall
.PHONY: uninstall-offline-cfg
