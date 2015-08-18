VERSION=1.2.0
ARCH:=$(DEB_HOST_ARCH)

ifeq "$(ARCH)" "amd64"
	ARCH=x86_64
endif

ifeq "$(ARCH)" "i386"
	ARCH=i686
endif

BASE:=$(shell printf "rust-%s-%s-unknown-linux-gnu" $(VERSION) $(ARCH))
FILE:=tmp/$(BASE).tar.gz
DIR:=/tmp/$(BASE)
URL:=https://static.rust-lang.org/dist/$(BASE).tar.gz
SRC:=$(DIR)/$(BASE)

ifeq "$(DESTDIR)" ""
	DESTDIR=target
endif

TARGETDIR=$(DESTDIR)/opt/rust/

all:
	@echo make package to create a package

clean:
	rm -Rf dist

$(FILE):
	mkdir -p tmp
	wget $(URL) -c -O $(FILE).tmp && mv $(FILE).tmp $(FILE)

$(DIR): $(FILE)
	mkdir -p $(DIR).tmp
	tar -zxvf $(FILE) -C $(DIR).tmp && mv $(DIR).tmp $(DIR) && touch $(DIR) || rm -Rf $(DIR)

install: $(DIR)
	mkdir -p $(DESTDIR)/usr/
	# rustc
	cp -R $(SRC)/rustc/bin/ $(SRC)/rustc/lib/ $(SRC)/rustc/share/ $(DESTDIR)/usr/

	# cargo
	cp -R $(SRC)/cargo/bin/ $(SRC)/cargo/lib/ $(SRC)/cargo/share/ $(DESTDIR)/usr/
	cp -R $(SRC)/cargo/etc/ $(DESTDIR)/

	# doc
	cp -R $(SRC)/rust-docs/share/ $(DESTDIR)/usr/


package:
	dpkg-buildpackage -b -us -uc
	mkdir -p dist/package
	mv ../*.deb dist/package/
	rm ../*.changes

test-package:
	make clean
	make package && sudo dpkg -i dist/package/*
