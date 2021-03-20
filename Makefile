BUILDDIR=$(shell pwd)/build
OUTPUTDIR=$(shell pwd)/output

define rootfs
	mkdir -vp $(BUILDDIR)/alpm-hooks/usr/share/libalpm/hooks
	find /usr/share/libalpm/hooks -exec ln -sf /dev/null $(BUILDDIR)/alpm-hooks{} \;

	mkdir -vp $(BUILDDIR)/var/lib/pacman/ $(OUTPUTDIR)
	install -Dm644 /usr/share/devtools/pacman-extra.conf $(BUILDDIR)/etc/pacman.conf
	cat pacman-conf.d-blackarch.conf >> $(BUILDDIR)/etc/pacman.conf

	fakechroot -- fakeroot -- pacman -Sy -r $(BUILDDIR) \
		--noconfirm --dbpath $(BUILDDIR)/var/lib/pacman \
		--config $(BUILDDIR)/etc/pacman.conf \
		--noscriptlet \
		--hookdir $(BUILDDIR)/alpm-hooks/usr/share/libalpm/hooks/ $(2)

	cp --recursive --preserve=timestamps --backup --suffix=.pacnew rootfs/* $(BUILDDIR)/

fakechroot -- fakeroot -- chroot $(BUILDDIR) update-ca-trust
	fakechroot -- fakeroot -- chroot $(BUILDDIR) locale-gen
	fakechroot -- fakeroot -- chroot $(BUILDDIR) sh -c 'pacman-key --init && pacman-key --populate archlinux blackarch && bash -c "rm -rf etc/pacman.d/gnupg/{openpgp-revocs.d/,private-keys-v1.d/,pubring.gpg~,gnupg.S.}*"'

	ln -fs /etc/os-release $(BUILDDIR)/usr/lib/os-release

	# add system users
	fakechroot -- fakeroot -- chroot $(BUILDDIR) /usr/bin/systemd-sysusers --root "/"

	# remove passwordless login for root (see CVE-2019-5021 for reference)
	sed -i -e 's/^root::/root:!:/' "$(BUILDDIR)/etc/shadow"

	# Use BlackArch shell configs and os-release
	fakechroot -- fakeroot -- chroot $(BUILDDIR) cp /etc/skel/{.bashrc,.zshrc,.bash_profile} /root/

	# fakeroot to map the gid/uid of the builder process to root
	fakeroot -- tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(BUILDDIR) -c . -f $(OUTPUTDIR)/$(1).tar

	cd $(OUTPUTDIR); xz -9 -T0 -f $(1).tar; sha256sum $(1).tar.xz > $(1).tar.xz.SHA256
endef

define dockerfile
	sed -e "s|TEMPLATE_ROOTFS_FILE|$(1).tar.xz|" \
	    Dockerfile.template > $(OUTPUTDIR)/Dockerfile.$(1)
endef

.PHONY: clean
clean:
	rm -rf $(BUILDDIR) $(OUTPUTDIR)

$(OUTPUTDIR)/blackarch-base.tar.xz:
	$(call rootfs,blackarch-base,base blackarch-keyring)

$(OUTPUTDIR)/blackarch-base-devel.tar.xz:
	$(call rootfs,blackarch-base-devel,base base-devel blackarch-keyring)

$(OUTPUTDIR)/Dockerfile.base: $(OUTPUTDIR)/blackarch-base.tar.xz
	$(call dockerfile,blackarch-base)

$(OUTPUTDIR)/Dockerfile.base-devel: $(OUTPUTDIR)/blackarch-base-devel.tar.xz
	$(call dockerfile,blackarch-base-devel)

.PHONY: docker-blackarch-base
blackarch-base: $(OUTPUTDIR)/Dockerfile.base
	docker build -f $(OUTPUTDIR)/Dockerfile.blackarch-base -t blackarchlinux/blackarch:base $(OUTPUTDIR)

.PHONY: docker-blackarch-base-devel
blackarch-base-devel: $(OUTPUTDIR)/Dockerfile.base-devel
	docker build -f $(OUTPUTDIR)/Dockerfile.blackarch-base-devel -t blackarchlinux/blackarch:base-devel $(OUTPUTDIR)
