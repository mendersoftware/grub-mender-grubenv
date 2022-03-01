srcdir ?= .
export srcdir
DESTDIR ?= /
export DESTDIR
sysconfdir ?= /etc
export sysconfdir

build:

install:
	install -m 755 -d "$(DESTDIR)$(sysconfdir)/grub.d"
	set -e; for file in "$(srcdir)"/[0-9][0-9]_*; do \
		echo "Installing $$file"; \
		case "$$file" in \
		*.cfg) \
			dest="$(DESTDIR)$(sysconfdir)/grub.d/$$(basename "$$file")"; \
			dest="$${dest%.cfg}"; \
			echo "cat <<'END_OF_MENDER_GRUBENV_CFG_FILE'" > "$$dest"; \
			cat $$file >> "$$dest"; \
			echo >> "$$dest"; \
			echo "END_OF_MENDER_GRUBENV_CFG_FILE" >> "$$dest"; \
			chmod 755 "$$dest"; \
			;; \
		*) \
			install -m 755 "$$file" "$(DESTDIR)$(sysconfdir)/grub.d/"; \
			;; \
		esac; \
	done
	install -m 644 "$(srcdir)/README-mender.md" "$(DESTDIR)$(sysconfdir)/grub.d/"
	$(MAKE) -C default install

uninstall:
	set -e; for file in "$(srcdir)"/[0-9][0-9]_*; do \
		rm -f "$(DESTDIR)$(sysconfdir)/grub.d/$$(basename "$${file%.cfg}")"; \
	done
	rm -f "$(DESTDIR)$(sysconfdir)/grub.d/README-mender.md"
	rmdir -p --ignore-fail-on-non-empty "$(DESTDIR)$(sysconfdir)/grub.d"
	$(MAKE) -C default uninstall

.PHONY: build
.PHONY: install
.PHONY: uninstall
